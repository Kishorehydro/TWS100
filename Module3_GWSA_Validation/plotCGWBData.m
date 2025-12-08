function success = plotCGWBData(app, plotType)
            success = false;
            try
                switch plotType
                    case 'Temporal'
                        if ~isempty(app.CGWBTime) && ~isempty(app.CGWBAvg) && ...
                                length(app.CGWBTime) == length(app.CGWBAvg)
                            plot(app.DynamicAxes, app.CGWBTime, app.CGWBAvg, ...
                                'Color', [0.62, 0.482, 0.71], 'DisplayName', 'CGWB_GWSA', 'LineWidth', 1.5);
                            success = true;
                        end
                    case 'Spatial'
                        if ~isempty(app.CGWBAnomalies) && ...
                                ~isempty(app.CGWBLat) && ...
                                ~isempty(app.CGWBLon) && ...
                                ~isempty(app.CGWBTime)

                            % === Calculate trends ===
                            numPoints = size(app.CGWBAnomalies, 1);
                            trendValues = zeros(numPoints, 1);

                            if isdatetime(app.CGWBTime)
                                timeNum = datenum(app.CGWBTime);
                            else
                                timeNum = app.CGWBTime;
                            end
                            timeNum = timeNum - min(timeNum);

                            for i = 1:numPoints
                                y = squeeze(app.CGWBAnomalies(i, :));
                                validIdx = ~isnan(y);
                                if sum(validIdx) > 1
                                    p = polyfit(timeNum(validIdx), y(validIdx), 1);
                                    trendValues(i) = p(1);
                                else
                                    trendValues(i) = NaN;
                                end
                            end

                            % === Plot trend points ===
                            scatter(app.DynamicAxes, app.CGWBLon, app.CGWBLat, 40, trendValues, ...
                                'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 0.5);

                            % Colormap & colorbar
                            redBlueMap = [linspace(0,1,64)' zeros(64,1) linspace(1,0,64)'];
                            colormap(app.DynamicAxes, redBlueMap);
                            c = colorbar(app.DynamicAxes, 'southoutside');
                            c.Label.String = 'CGWB GWSA (mm/year)';

                            maxAbs = max(abs(trendValues), [], 'omitnan');
                            if maxAbs > 0
                                caxis(app.DynamicAxes, [-maxAbs, maxAbs]);
                            end

                            % === Retrieve and plot basin polygon ===
                            selectedBasin = app.BasinSelectionButton.Value;
                            basins = app.Basins;

                            basinPolygon = [];
                            for i = 1:length(basins)
                                if strcmpi(basins(i).RIVER_BASI, selectedBasin)
                                    basinPolygon = [basins(i).X', basins(i).Y'];
                                    break;
                                end
                            end

                            % Clean polygon
                            basinPolygon = basinPolygon(~any(isnan(basinPolygon), 2), :);

                            % === Plot polygon ===
                            hold(app.DynamicAxes, 'on');

                            if ~isempty(basinPolygon)
                                plot(app.DynamicAxes, basinPolygon(:,1), basinPolygon(:,2), ...
                                    'k-', 'LineWidth', 2, 'DisplayName', selectedBasin);
                            else
                                warning('No polygon found for basin: %s', selectedBasin);
                            end

                            % Optional: also check alternate boundary source
                            if isprop(app, 'BasinBoundaries') && ~isempty(app.BasinBoundaries)
                                basinIdx = strcmp({app.BasinBoundaries.Name}, selectedBasin);
                                if any(basinIdx)
                                    basinData = app.BasinBoundaries(basinIdx);
                                    plot(app.DynamicAxes, basinData.Lon, basinData.Lat, ...
                                        'k-', 'LineWidth', 2, 'DisplayName', [selectedBasin ' (Boundary)']);
                                end
                            end

                            hold(app.DynamicAxes, 'off');

                            % === Final formatting ===
                            xlabel(app.DynamicAxes, 'Longitude');
                            ylabel(app.DynamicAxes, 'Latitude');
                            title(app.DynamicAxes, 'CGWB Spatial Trends');
                            grid(app.DynamicAxes, 'on');
                            axis(app.DynamicAxes, 'equal');

                            % Force axes to show both scatter & polygon
                            axis(app.DynamicAxes, 'tight');

                            % Add legend only if polygon exists
                            if exist('basinPolygon','var') && ~isempty(basinPolygon)
                                legend(app.DynamicAxes, 'show', 'Location', 'best');
                            end

                            success = true;

                        else
                            warning('Spatial data for CGWB is incomplete (missing anomalies, coordinates, or time).');
                        end
                end
            catch ME
                warning(ME.identifier,'Failed to plot CGWB data: %s', ME.message);
            end
        end