function plotGRACE_Spatial(app)
            try
                [grace_masked, grace_lat, grace_lon] = app.applyBasinMaskWithCoords(...
                    app.JPLTWSData, app.JPLTWSLat, app.JPLTWSLon);

                % Take temporal mean for spatial pattern (2002-2018 period)
                time_mask = app.JPLTWSTime >= datetime(2002,1,1) & app.JPLTWSTime <= datetime(2018,12,31);
                grace_spatial = mean(grace_masked(:, time_mask), 2, 'omitnan');

                % Create spatial grid
                [unique_lat, ~, lat_idx] = unique(grace_lat);
                [unique_lon, ~, lon_idx] = unique(grace_lon);
                spatial_grid = NaN(length(unique_lat), length(unique_lon));

                for i = 1:length(grace_lat)
                    spatial_grid(lat_idx(i), lon_idx(i)) = grace_spatial(i);
                end

                % Plot spatial data
                imagesc(app.UIAxes, unique_lon, unique_lat, spatial_grid);
                colorbar(app.UIAxes);
                title(app.UIAxes, 'GRACE TWSA Spatial Distribution');

                % Add basin boundary
                hold(app.UIAxes, 'on');
                for i = 1:length(app.Basins)
                    if strcmpi(app.Basins(i).RIVER_BASI, 'GODAVARI')
                        plot(app.UIAxes, app.Basins(i).X, app.Basins(i).Y, ...
                            'k-', 'LineWidth', 2, 'DisplayName', 'Basin Boundary');
                    end
                end
                hold(app.UIAxes, 'off');

                axis(app.UIAxes, 'equal');
                xlabel(app.UIAxes, 'Longitude');
                ylabel(app.UIAxes, 'Latitude');

            catch ME
                uialert(app.UIFigure, sprintf('Error plotting GRACE spatial: %s', ME.message), 'Plot Error');
            end
        end