function saveSHAPToExcel2D(app, shap_results, feature_names, point_names, reconstructionType)
            % Save SHAP analysis results to Excel - CORRECTED VERSION

            if isempty(shap_results) || all(cellfun(@isempty, shap_results))
                fprintf('No SHAP results to save\n');
                return;
            end

            % Determine number of features from first non-empty result
            n_features = 0;
            for i = 1:length(shap_results)
                if ~isempty(shap_results{i})
                    n_features = length(shap_results{i});
                    break;
                end
            end

            if n_features == 0
                fprintf('No valid SHAP results found\n');
                return;
            end

            % Create feature names with lags (assuming 2 months lag)
            full_feature_names = {};
            lag_months = 2;
            for lag = 1:lag_months  % Note: starting from 1, not 0
                for i = 1:length(feature_names)
                    full_feature_names{end+1} = sprintf('%s_lag%d', feature_names{i}, lag);
                end
            end

            % Ensure we don't exceed available features
            if length(full_feature_names) > n_features
                full_feature_names = full_feature_names(1:n_features);
            elseif length(full_feature_names) < n_features
                % Add generic names for extra features
                for i = (length(full_feature_names)+1):n_features
                    full_feature_names{end+1} = sprintf('Feature_%d', i);
                end
            end

            % Create SHAP data table
            shap_data = table();
            shap_data.Point = point_names';

            for f = 1:n_features
                % Extract SHAP values for this feature across all points
                shap_values = zeros(length(point_names), 1);
                for p = 1:length(point_names)
                    if ~isempty(shap_results{p}) && length(shap_results{p}) >= f
                        shap_values(p) = shap_results{p}(f);
                    else
                        shap_values(p) = NaN;
                    end
                end
                shap_data.(full_feature_names{f}) = shap_values;
            end

            if strcmp(reconstructionType, 'basin_average')
                filename = 'SHAP_Analysis_Results_BasinAverage.xlsx';
            else
                filename = 'SHAP_Analysis_Results_AllPoints.xlsx';
            end

            writetable(shap_data, filename);
            fprintf('SHAP analysis results saved to %s\n', filename);
        end