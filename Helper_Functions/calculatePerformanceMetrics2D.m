function [train_rmse, test_rmse, train_corr, test_corr] = calculatePerformanceMetrics2D(~, y_train, y_pred_train, y_test, y_pred_test)
            % Calculate performance metrics for 2D data - CORRECTED VERSION
            n_points = size(y_train, 2);
            train_rmse = zeros(1, n_points);
            test_rmse = zeros(1, n_points);
            train_corr = zeros(1, n_points);
            test_corr = zeros(1, n_points);

            for point_idx = 1:n_points
                % Training metrics
                valid_train = ~isnan(y_train(:, point_idx)) & ~isnan(y_pred_train(:, point_idx));
                if sum(valid_train) > 2
                    train_actual = y_train(valid_train, point_idx);
                    train_pred = y_pred_train(valid_train, point_idx);

                    train_rmse(point_idx) = sqrt(mean((train_actual - train_pred).^2));

                    % Correlation with safety check
                    if length(train_actual) > 1 && ~all(train_actual == train_actual(1))
                        corr_matrix = corrcoef(train_actual, train_pred, 'Rows', 'complete');
                        if all(size(corr_matrix) == [2, 2]) && ~any(isnan(corr_matrix(:)))
                            train_corr(point_idx) = corr_matrix(1, 2);
                        else
                            train_corr(point_idx) = NaN;
                        end
                    else
                        train_corr(point_idx) = NaN;
                    end
                else
                    train_rmse(point_idx) = NaN;
                    train_corr(point_idx) = NaN;
                end

                % Testing metrics
                valid_test = ~isnan(y_test(:, point_idx)) & ~isnan(y_pred_test(:, point_idx));
                if sum(valid_test) > 2
                    test_actual = y_test(valid_test, point_idx);
                    test_pred = y_pred_test(valid_test, point_idx);

                    test_rmse(point_idx) = sqrt(mean((test_actual - test_pred).^2));

                    % Correlation with safety check
                    if length(test_actual) > 1 && ~all(test_actual == test_actual(1))
                        corr_matrix = corrcoef(test_actual, test_pred, 'Rows', 'complete');
                        if all(size(corr_matrix) == [2, 2]) && ~any(isnan(corr_matrix(:)))
                            test_corr(point_idx) = corr_matrix(1, 2);
                        else
                            test_corr(point_idx) = NaN;
                        end
                    else
                        test_corr(point_idx) = NaN;
                    end
                else
                    test_rmse(point_idx) = NaN;
                    test_corr(point_idx) = NaN;
                end
            end

            % Display summary statistics
            fprintf('=== PERFORMANCE SUMMARY ===\n');
            fprintf('Training - Mean RMSE: %.4f, Mean Correlation: %.4f\n', ...
                nanmean(train_rmse), nanmean(train_corr));
            fprintf('Testing  - Mean RMSE: %.4f, Mean Correlation: %.4f\n', ...
                nanmean(test_rmse), nanmean(test_corr));

            % Warn if testing correlation is poor
            if nanmean(test_corr) < 0.3
                fprintf('WARNING: Testing correlation is low. Model may not be generalizing well.\n');
            end
        end