function shap_results = performSHAPanalysis2D(app, rf_models, X_train, y_train, feature_names, n_points)
            % Perform SHAP analysis for 2D data - CORRECTED VERSION

            shap_results = cell(1, n_points);

            try
                % Check if Python is available
                try
                    py.importlib.import_module('numpy');
                    py.importlib.import_module('shap');
                    py.importlib.import_module('sklearn.ensemble');
                    python_available = true;
                catch
                    python_available = false;
                    fprintf('Python not available for SHAP, using MATLAB feature importance instead\n');
                end

                if python_available
                    % Standardize training features for SHAP (interpretability only)
                    X_train_scaled = X_train;
                    if ~isempty(X_train)
                        X_train_scaled = (X_train - mean(X_train, 1, 'omitnan')) ./ std(X_train, 0, 1, 'omitnan');
                        % Replace NaN std with 1 to avoid division issues
                        s = std(X_train, 0, 1, 'omitnan');
                        s(s==0 | isnan(s)) = 1;
                        X_train_scaled = (X_train - mean(X_train, 1, 'omitnan')) ./ s;
                    end

                    for point_idx = 1:n_points
                        if ~isempty(rf_models{point_idx})
                            % Get valid data for this point
                            valid_train = ~isnan(y_train(:, point_idx)) & ~any(isnan(X_train_scaled), 2);

                            if sum(valid_train) > 10
                                X_train_point = X_train_scaled(valid_train, :);
                                y_train_point = y_train(valid_train, point_idx);

                                try
                                    % Convert to Python arrays
                                    X_train_py = py.numpy.array(double(X_train_point));
                                    y_train_py = py.numpy.array(double(y_train_point));

                                    % Retrain a Python RF with similar config for SHAP analysis
                                    rf_py = py.sklearn.ensemble.RandomForestRegressor(...
                                        pyargs('n_estimators', int32(100), ...
                                        'random_state', int32(42), ...
                                        'max_depth', int32(10)));

                                    rf_py.fit(X_train_py, y_train_py);

                                    % Calculate SHAP values
                                    explainer = py.shap.TreeExplainer(rf_py);
                                    shap_vals = explainer.shap_values(X_train_py);

                                    % Convert to MATLAB array
                                    shap_values_mat = double(py.numpy.array(shap_vals));

                                    % Take mean absolute SHAP per feature
                                    mean_abs_shap = mean(abs(shap_values_mat), 1);
                                    shap_results{point_idx} = mean_abs_shap;
                                catch
                                    % Fallback to MATLAB feature importance
                                    if ~isempty(rf_models{point_idx}.OOBPermutedPredictorDeltaError)
                                        shap_results{point_idx} = rf_models{point_idx}.OOBPermutedPredictorDeltaError;
                                    else
                                        shap_results{point_idx} = [];
                                    end
                                end
                            else
                                shap_results{point_idx} = [];
                            end
                        else
                            shap_results{point_idx} = [];
                        end

                        if mod(point_idx, 10) == 0
                            fprintf('SHAP analysis completed for %d/%d points\n', point_idx, n_points);
                        end
                    end
                else
                    % Use MATLAB feature importance as fallback
                    for point_idx = 1:n_points
                        if ~isempty(rf_models{point_idx}) && ~isempty(rf_models{point_idx}.OOBPermutedPredictorDeltaError)
                            shap_results{point_idx} = rf_models{point_idx}.OOBPermutedPredictorDeltaError;
                        else
                            shap_results{point_idx} = [];
                        end
                    end
                end

            catch MEshap
                fprintf('SHAP analysis failed: %s\n', MEshap.message);
                % Fallback to MATLAB feature importance
                for point_idx = 1:n_points
                    if ~isempty(rf_models{point_idx}) && ~isempty(rf_models{point_idx}.OOBPermutedPredictorDeltaError)
                        shap_results{point_idx} = rf_models{point_idx}.OOBPermutedPredictorDeltaError;
                    else
                        shap_results{point_idx} = [];
                    end
                end
            end
        end