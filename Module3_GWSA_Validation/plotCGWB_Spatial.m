function plotCGWB_Spatial(app)
            try
                % Check if CGWB data has coordinates
                if ~any(contains(app.CGWBData.Properties.VariableNames, {'Latitude', 'Longitude', 'LAT', 'LON', 'lat', 'lon'}))
                    % If no coordinates, show message
                    text(app.UIAxes, 0.5, 0.5, 'CGWB coordinates not available', ...
                        'HorizontalAlignment', 'center', 'Units', 'normalized', ...
                        'FontSize', 14);
                    title(app.UIAxes, 'CGWB Data - Coordinates Required for Spatial Plot');
                    return;
                end

                % Extract coordinates
                if ismember('Latitude', app.CGWBData.Properties.VariableNames)
                    well_lats = app.CGWBData.Latitude;
                    well_lons = app.CGWBData.Longitude;
                elseif ismember('LAT', app.CGWBData.Properties.VariableNames)
                    well_lats = app.CGWBData.LAT;
                    well_lons = app.CGWBData.LON;
                else
                    % Try to find coordinate columns by pattern matching
                    lat_col = find(contains(app.CGWBData.Properties.VariableNames, {'lat', 'Lat'}, 'IgnoreCase', true), 1);
                    lon_col = find(contains(app.CGWBData.Properties.VariableNames, {'lon', 'Lon'}, 'IgnoreCase', true), 1);
                    if ~isempty(lat_col) && ~isempty(lon_col)
                        well_lats = app.CGWBData{:, lat_col};
                        well_lons = app.CGWBData{:, lon_col};
                    else
                        msgbox('Could not find coordinate columns in CGWB data');
                    end
                end

                % Plot well locations
                scatter(app.UIAxes, well_lons, well_lats, 50, 'filled', ...
                    'MarkerFaceColor', [0.620, 0.482, 0.710], ... % #9e7bb5
                    'MarkerEdgeColor', 'k', ...
                    'DisplayName', 'CGWB Wells');

                % Add basin boundary
                hold(app.UIAxes, 'on');
                for i = 1:length(app.Basins)
                    if strcmpi(app.Basins(i).RIVER_BASI, 'GODAVARI')
                        plot(app.UIAxes, app.Basins(i).X, app.Basins(i).Y, ...
                            'k-', 'LineWidth', 2, 'DisplayName', 'Basin Boundary');
                    end
                end
                hold(app.UIAxes, 'off');

                title(app.UIAxes, 'CGWB Well Locations');
                axis(app.UIAxes, 'equal');
                xlabel(app.UIAxes, 'Longitude');
                ylabel(app.UIAxes, 'Latitude');
                legend(app.UIAxes, 'show', 'Location', 'best');

            catch ME
                uialert(app.UIFigure, sprintf('Error plotting CGWB spatial: %s', ME.message), 'Plot Error');
            end
        end