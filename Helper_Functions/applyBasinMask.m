function maskedData = applyBasinMask(app, data, lat, lon)
    % Applies a spatial mask for the selected basin and retains the timespan
    % Organizes output data where each column corresponds to the time series
    % for a point inside the selected basin.

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
    % Convert data longitudes from 0–360 to -180–180
    if any(lon > 180)
        lon = lon - 360;
    end

    % Convert basin polygon longitudes to -180–180
    basinPolygon(:,1) = mod(basinPolygon(:,1) + 180, 360) - 180;

    % ===================== BUILD MESHGRID AND MASK =====================
    [Long, Lat] = meshgrid(lon, lat);
    Long = Long(:);
    Lat  = Lat(:);

    % Determine points inside the basin
    inBasin = inpolygon(Long, Lat, basinPolygon(:,1), basinPolygon(:,2));

    % ===================== VALIDATE AND FORMAT INPUT DATA =====================
    dataSize = size(data);

    if length(dataSize) == 3
        if dataSize(1) == numel(lon) && dataSize(2) == numel(lat)
            % Data arranged as lon–lat–time → convert to lat–lon–time
            data = permute(data, [2, 1, 3]);
        elseif dataSize(1) ~= numel(lat) || dataSize(2) ~= numel(lon)
            msgbox('Unexpected data dimensions. Ensure data matches lat, lon, and time.');
            return;
        end
    else
        msgbox('Data must be 3D with dimensions matching lat, lon, and time.');
        return;
    end

    % Reshape data into 2D (space × time)
    data2D = reshape(data, [], dataSize(3));

    % ===================== EXTRACT FINAL MASKED DATA =====================
    maskedData = data2D(inBasin, :);
end