function [maskedData, latInBasin, lonInBasin] = applyBasinMaskWithCoords(app, data, lat, lon)
    % Applies a spatial mask for the selected basin and retains the timespan.
    % Returns:
    %   maskedData   -> time series inside basin [nPoints x nTime]
    %   latInBasin   -> latitudes of points inside basin
    %   lonInBasin   -> longitudes of points inside basin

    % ===================== BASIN SELECTION VALIDATION =====================
    selectedBasin = app.BasinSelectionButton.Value;

    if isempty(app.Basins)
        uialert(app.UIFigure, ...
            {'No basin shapefile data found.', ...
            'Please upload data before proceeding.'}, ...
            'Data Missing', 'Icon', 'warning');
        return;
    end

    if strcmpi(selectedBasin, 'Select Basin') || isempty(selectedBasin)
        uialert(app.UIFigure, ...
            {'Please select a basin from the dropdown before proceeding.'}, ...
            'No Basin Selected', 'Icon', 'warning');
        return;
    end

    % ===================== EXTRACT BASIN POLYGON =====================
    basins = app.Basins;
    basinPolygon = [];

    for i = 1:length(basins)
        if strcmpi(basins(i).RIVER_BASI, selectedBasin)
            basinPolygon = [basins(i).X', basins(i).Y'];
            break;
        end
    end

    if ~isempty(basinPolygon)
        basinPolygon = basinPolygon(~any(isnan(basinPolygon), 2), :);
    end

    if isempty(basinPolygon)
        uialert(app.UIFigure, ...
            {['The selected basin "', selectedBasin, '" is not available in the shapefile.'], ...
            'Please check your selection or upload the correct shapefile.'}, ...
            'Basin Not Found', 'Icon', 'warning');
        return;
    end

    % ===================== LONGITUDE RANGE FIX =====================
    % Convert model/data longitudes from 0–360 → −180–180
    if any(lon > 180)
        lon = lon - 360;
    end

    % Convert polygon longitudes to same range
    basinPolygon(:,1) = mod(basinPolygon(:,1) + 180, 360) - 180;

    % ===================== MESHGRID & POINT CLASSIFICATION =====================
    [Long, Lat] = meshgrid(lon, lat);
    Long = Long(:);
    Lat  = Lat(:);

    % Determine points inside polygon
    inBasin = inpolygon(Long, Lat, basinPolygon(:, 1), basinPolygon(:, 2));

    % Extract coordinates inside basin
    lonInBasin = Long(inBasin);
    latInBasin = Lat(inBasin);

    % ===================== DATA DIMENSION FIX =====================
    dataSize = size(data);

    if length(dataSize) == 3
        if dataSize(1) == numel(lon) && dataSize(2) == numel(lat)
            % lon-lat-time → convert to lat-lon-time
            data = permute(data, [2, 1, 3]);
        elseif dataSize(1) ~= numel(lat) || dataSize(2) ~= numel(lon)
            msgbox('Unexpected data dimensions. Ensure data matches lat, lon, and time.');
            return;
        end
    else
        msgbox('Data must be 3D with dimensions matching lat, lon, and time.');
        return;
    end

    % ===================== EXTRACT MASKED TIME SERIES =====================
    data2D = reshape(data, [], dataSize(3));
    maskedData = data2D(inBasin, :);
end