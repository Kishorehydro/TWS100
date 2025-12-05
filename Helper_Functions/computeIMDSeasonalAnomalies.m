function pr_seasonal_anom = computeIMDSeasonalAnomalies(app, IMD_masked, IMD_datetime)
            % computeIMDSeasonalAnomalies
            % -------------------------------------------------------------------------
            % Compute basin-averaged, seasonal precipitation anomalies (2002-2018)
            % Optimized version with vectorized operations
            %
            % INPUTS:
            %   IMD_masked   - Precipitation data masked to basin (lat×lon×time or pts×time)
            %   IMD_datetime - datetime vector for the time dimension
            %
            % OUTPUT:
            %   pr_seasonal_anom - Table with columns: Date, Year, Season, Anomaly
            % -------------------------------------------------------------------------

            try
                % --- Step 1: Compute basin mean (vectorized) ---
                IMD_basin_mean = mean(IMD_masked, 1, 'omitnan');
                IMD_basin_mean = squeeze(IMD_basin_mean); % Remove singleton dimensions

                % --- Step 2: Select period (2002-2024) ---
                startDate = datetime(2002,1,1);
                endDate   = datetime(2024,12,31);
                selIdx = IMD_datetime >= startDate & IMD_datetime <= endDate;
                IMD_sel = IMD_basin_mean(selIdx);
                time_sel = IMD_datetime(selIdx);

                % --- Step 3: Climatology (2004-2009) ---
                climIdx = time_sel >= datetime(2004,1,1) & time_sel <= datetime(2009,12,31);
                clim_mean = mean(IMD_sel(climIdx), 'omitnan');

                % --- Step 4: Anomalies ---
                IMD_anom = IMD_sel - clim_mean;

                % --- Step 5: Shift December to next year's January (vectorized) ---
                time_shifted = time_sel;
                dec_months = month(time_sel) == 12;
                time_shifted(dec_months) = dateshift(time_sel(dec_months), 'start', 'month', 1);

                % --- Step 6: Map to Seasons (vectorized) ---
                months = month(time_shifted);
                seasons = strings(size(months));

                % Vectorized season assignment
                seasons(ismember(months, [1, 12])) = "JAN";
                seasons(ismember(months, [2, 3, 4, 5])) = "MAY";
                seasons(ismember(months, [6, 7, 8])) = "AUG";
                seasons(ismember(months, [9, 10, 11])) = "NOV";

                years = year(time_shifted);

                % --- Step 7: Group by Year + Season ---
                T = table(years(:), seasons(:), IMD_anom(:), time_shifted(:), ...
                    'VariableNames', {'Year','Season','Anomaly','Time'});
                seasonalSummary = groupsummary(T, {'Year','Season'}, 'mean', 'Anomaly');

                % --- Step 8: Create chronological season date (vectorized) ---
                season_map = containers.Map({'JAN','MAY','AUG','NOV'}, [1, 5, 8, 11]);
                months_vector = zeros(height(seasonalSummary), 1);

                for i = 1:height(seasonalSummary)
                    months_vector(i) = season_map(seasonalSummary.Season{i});
                end

                seasonalSummary.Date = datetime(seasonalSummary.Year, months_vector, 1);

                % --- Step 9: Sort chronologically ---
                seasonalSummary = sortrows(seasonalSummary, 'Date');
                seasonalSummary.Date.Format = 'MM-yyyy';

                % --- Step 10: Final output table ---
                pr_seasonal_anom = table(seasonalSummary.Date, seasonalSummary.Year, ...
                    seasonalSummary.Season, seasonalSummary.mean_Anomaly, ...
                    'VariableNames', {'Date','Year','Season','Anomaly'});

            catch ME
                warning(ME.identifier,'Error in computeIMDSeasonalAnomalies: %s', ME.message);
                % Return empty table on error
                pr_seasonal_anom = table('Size', [0, 4], ...
                    'VariableTypes', {'datetime', 'double', 'string', 'double'}, ...
                    'VariableNames', {'Date', 'Year', 'Season', 'Anomaly'});
            end
        end