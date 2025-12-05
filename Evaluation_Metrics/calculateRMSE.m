function rmse = calculateRMSE(app,observed, simulated)
            % Calculate Root Mean Square Error with robust error handling

            % Input validation
            if isempty(observed) || isempty(simulated)
                rmse = NaN;
                return;
            end

            % Ensure both inputs are vectors of the same size
            observed = observed(:);
            simulated = simulated(:);

            if length(observed) ~= length(simulated)
                warning('Observed and simulated data have different lengths. Using common valid indices.');
                % Find common non-NaN indices
                valid_obs = ~isnan(observed);
                valid_sim = ~isnan(simulated);
                valid_idx = valid_obs & valid_sim;

                if sum(valid_idx) < 1
                    rmse = NaN;
                    return;
                end

                observed = observed(valid_idx);
                simulated = simulated(valid_idx);
            else
                % Remove NaN pairs
                valid_idx = ~isnan(observed) & ~isnan(simulated);
                if sum(valid_idx) < 1
                    rmse = NaN;
                    return;
                end
                observed = observed(valid_idx);
                simulated = simulated(valid_idx);
            end

            % Check if we have enough data points
            if length(observed) < 2
                rmse = NaN;
                return;
            end

            try
                % Calculate RMSE
                squared_errors = (observed - simulated).^2;
                mean_squared_error = mean(squared_errors, 'omitnan');
                rmse = sqrt(mean_squared_error);
            catch ME
                warning(ME.identifier,'Error calculating RMSE: %s', ME.message);
                rmse = NaN;
            end
        end