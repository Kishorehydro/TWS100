function plotGRACE_Temporal(app)
            try
                % Filter GRACE data to 2002-2018 period
                time_mask = app.JPLTWSTime >= datetime(2002,1,1) & app.JPLTWSTime <= datetime(2018,12,31);
                grace_time = app.JPLTWSTime(time_mask);

                % Calculate basin average (you might want to precompute this)
                [grace_masked, ~, ~] = app.applyBasinMaskWithCoords(...
                    app.JPLTWSData, app.JPLTWSLat, app.JPLTWSLon);
                grace_basin_avg = mean(grace_masked, 1, 'omitnan');
                grace_basin_avg = grace_basin_avg(time_mask);

                plot(app.UIAxes, grace_time, grace_basin_avg, ...
                    's--', 'Color', 'black', ...
                    'LineWidth', 2, ...
                    'MarkerSize', 6, ...
                    'DisplayName', 'GRACE TWSA');

            catch ME
                warning(ME.identifier,'Could not plot GRACE data: %s', ME.message);
            end
        end