function success = plotGRACEData(app, plotType)
            success = false;
            try
                [JPL_masked, latJPL, lonJPL] = applyBasinMaskWithCoords(app, ...
                    app.JPLTWSData, app.JPLTWSLat, app.JPLTWSLon);
                [GLDASSM_masked, latGLDAS, lonGLDAS] = applyBasinMaskWithCoords(app, ...
                    app.GLDAS_SMData, app.GLDAS_SMLat, app.GLDAS_SMLon);

                % --- Compute GLDAS anomalies ---
                climYears = 2004:2009;
                climIdx = ismember(year(app.GLDAS_datetime), climYears);
                climMean = mean(GLDASSM_masked(:, climIdx), 2, 'omitnan');
                GLDASSM_anom = GLDASSM_masked - climMean;

                % --- Get datetime arrays ---
                JPL_time = dateshift(app.JPL_datetime, 'start', 'month');
                GLDAS_time = dateshift(app.GLDAS_datetime, 'start', 'month');

                % Remove duplicate months from JPL_time
                [JPL_time_unique, uniqueIdx] = unique(JPL_time, 'stable');
                JPL_masked = JPL_masked(:, uniqueIdx);
                JPL_time = JPL_time_unique;

                % --- Find overlap period ---
                startDate = max([min(JPL_time), min(GLDAS_time)]);
                endDate = min([max(JPL_time), max(GLDAS_time)]);

                % --- Create continuous common time vector ---
                common_time = (dateshift(startDate, 'start', 'month') : calmonths(1) : dateshift(endDate, 'start', 'month'))';

                % --- Initialize matrices with NaN ---
                JPL_full = nan(size(JPL_masked,1), length(common_time));
                GLDAS_full = nan(size(GLDASSM_anom,1), length(common_time));

                % --- Map existing data into common_time ---
                [~, ia_jpl, ib_jpl] = intersect(common_time, JPL_time);
                JPL_full(:, ia_jpl) = JPL_masked(:, ib_jpl);

                [~, ia_gldas, ib_gldas] = intersect(common_time, GLDAS_time);
                GLDAS_full(:, ia_gldas) = GLDASSM_anom(:, ib_gldas);

                % --- Compute spatial mean ---
                JPL_mean = mean(JPL_full, 1, 'omitnan');
                GLDAS_mean = mean(GLDAS_full, 1, 'omitnan');

                switch plotType
                    case 'Temporal'
                        GWSA = JPL_mean*10 - GLDAS_mean;

                        % --- Select representative months (Jan, May, Aug, Nov) ---
                        targetMonths = [1, 5, 8, 11];
                        selIdx = ismember(month(common_time), targetMonths);

                        % Filter time and GWSA data
                        common_time_filtered = common_time(selIdx);
                        GWSA_filtered = GWSA(selIdx);

                        % --- Plot filtered GWSA ---
                        plot(app.DynamicAxes, common_time_filtered, GWSA_filtered, ...
                            'Color', 'black', 'DisplayName', 'GRACE_GWSA', 'LineWidth', 1.5, 'LineStyle', '--');
                        success = true;

                    case 'Spatial'
                        GWSA = JPL_full*10 - GLDAS_full;
                        nPoints = size(GWSA, 1);
                        trend = nan(nPoints, 1);

                        for p = 1:nPoints
                            y = GWSA(p, :);
                            t = (1:length(y))';
                            validIdx = ~isnan(y);
                            if sum(validIdx) >= 2
                                coeffs = polyfit(t(validIdx), y(validIdx), 1);
                                trend(p) = coeffs(1);
                            else
                                trend(p) = NaN;
                            end
                        end

                        % Retrieve the selected basin
                        selectedBasin = app.BasinSelectionButton.Value;
                        basins = app.Basins;

                        % Find the polygon corresponding to the selected basin
                        basinPolygon = [];
                        for i = 1:length(basins)
                            if strcmpi(basins(i).RIVER_BASI, selectedBasin)
                                basinPolygon = [basins(i).X', basins(i).Y'];
                                break;
                            end
                        end

                        % Clean polygon (remove NaNs)
                        basinPolygon = basinPolygon(~any(isnan(basinPolygon), 2), :);

                        % Call your spatial plotting function
                        plotSpatialBasinMapDynamic(app, lonJPL, latJPL, trend, basinPolygon, 'GRACE_GWSA');
                        success = true;
                end
            catch ME
                warning(ME.identifier,'Failed to plot GRACE data: %s', ME.message);
            end
        end