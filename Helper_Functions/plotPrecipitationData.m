function success = plotPrecipitationData(app, plotType)
            success = false;
            try
                switch plotType
                    case 'Temporal'
                        % --- IMD file path ---
                        IMDFile = "./Data/Precipitation/IMD/IMD_Precipitation_1901_2023_Godavari.nc";


                        [IMD_masked, latIMD, lonIMD] = applyBasinMaskWithCoords(app, app.IMDData, app.IMDLat, app.IMDLon);

                        pr_seasonal_anom = computeIMDSeasonalAnomalies(app, IMD_masked, app.IMD_datetime);

                        % Make sure the target axes is active
                        axes(app.DynamicAxes);
                        hold(app.DynamicAxes, 'on');

                        xVals = pr_seasonal_anom.Date;
                        yVals = pr_seasonal_anom.Anomaly;

                        % Plot bars with different colors for positive and negative anomalies
                        for i = 1:length(xVals)
                            if yVals(i) >= 0
                                bar(app.DynamicAxes, xVals(i), yVals(i), ...
                                    'FaceColor', [0.627, 0.80, 0.91], 'EdgeColor', 'none', 'BarWidth', 75);
                            else
                                bar(app.DynamicAxes, xVals(i), yVals(i), ...
                                    'FaceColor', [0.949, 0.733, 0.733], 'EdgeColor', 'none', 'BarWidth', 75);
                            end
                        end

                        % Add zero reference line
                        yline(app.DynamicAxes, 0, 'k--', 'LineWidth', 1);

                        % Format axes for datetime
                        datetick(app.DynamicAxes, 'x', 'mmm-yyyy', 'keeplimits');
                        set(app.DynamicAxes, 'XTickLabelRotation', 45);
                        grid(app.DynamicAxes, 'on');

                        % Create legend manually
                        hPos = bar(app.DynamicAxes, NaT, 0, 'FaceColor', [0.627, 0.80, 0.91], 'EdgeColor', 'none', 'Visible', 'off');
                        hNeg = bar(app.DynamicAxes, NaT, 0, 'FaceColor', [0.949, 0.733, 0.733], 'EdgeColor', 'none', 'Visible', 'off');
                        legend(app.DynamicAxes, [hPos, hNeg], {'Positive', 'Negative'}, 'Location', 'best');

                        hold(app.DynamicAxes, 'off');
                        success = true;

                    case 'Spatial'
                        uialert(app.UIFigure, 'Please use other precipitation option', "Invalid Selection", "Icon", "error");
                end
            catch ME
                warning(ME.identifier,'Failed to plot Precipitation data: %s', ME.message);
            end
        end