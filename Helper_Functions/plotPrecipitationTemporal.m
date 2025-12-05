  function plotPrecipitationTemporal(app)
            try
                % Use your existing precipitation data
                % Filter to 2002-2018 period
                time_mask = app.IMDTime >= datetime(2002,1,1) & app.IMDTime <= datetime(2018,12,31);
                precip_time = app.IMDTime(time_mask);

                % Calculate basin average and anomalies (you might want to precompute this)
                [precip_masked, ~, ~] = app.applyBasinMaskWithCoords(...
                    app.IMDData, app.IMDLat, app.IMDLon);
                precip_basin_avg = mean(precip_masked, 1, 'omitnan');
                precip_basin_avg = precip_basin_avg(time_mask);

                % Calculate anomalies relative to 2004-2009 baseline
                baseline_idx = precip_time >= datetime(2004,1,1) & precip_time <= datetime(2009,12,31);
                clim_mean = mean(precip_basin_avg(baseline_idx), 'omitnan');
                precip_anom = precip_basin_avg - clim_mean;

                % Separate positive and negative values
                pos_idx = precip_anom >= 0;
                neg_idx = precip_anom < 0;

                % Plot positive bars
                if any(pos_idx)
                    bar(app.UIAxes, precip_time(pos_idx), precip_anom(pos_idx), ...
                        'FaceColor', [0.627, 0.800, 0.910], ... % #a0cce8
                        'EdgeColor', 'none', ...
                        'BarWidth', 1, ...
                        'DisplayName', 'Precip. Anomaly (+)');
                end

                % Plot negative bars
                if any(neg_idx)
                    bar(app.UIAxes, precip_time(neg_idx), precip_anom(neg_idx), ...
                        'FaceColor', [0.949, 0.733, 0.733], ... % #F2BBBB
                        'EdgeColor', 'none', ...
                        'BarWidth', 1, ...
                        'DisplayName', 'Precip. Anomaly (–)');
                end

            catch ME
                warning(ME.identifier,'Could not plot precipitation: %s', ME.message);
            end
        end