function [trendLine, slope, intercept, r2, pval] = calculateTrend(app, x, y, method)
            % Calculate trend line and statistics based on selected method
            trendLine = [];
            slope = NaN;
            intercept = NaN;
            r2 = NaN;
            pval = NaN;

            n = length(x);
            if n < 2
                return;
            end

            switch method
                case 'linear'
                    % Linear regression
                    p = polyfit(x, y, 1);
                    slope = p(1);
                    intercept = p(2);
                    trendLine = polyval(p, x);

                case 'polynomial'
                    % Polynomial fit (2nd degree)
                    p = polyfit(x, y, 2);
                    trendLine = polyval(p, x);
                    % For polynomial, use linear slope for consistency in reporting
                    p_linear = polyfit(x, y, 1);
                    slope = p_linear(1);
                    intercept = p_linear(2);

                case 'loess'
                    % LOESS smoothing
                    span = 0.5; % Span parameter
                    if length(x) > 5
                        trendLine = smooth(x, y, span, 'loess');
                        % Calculate linear trend of the LOESS curve for slope
                        p_linear = polyfit(x, trendLine, 1);
                        slope = p_linear(1);
                        intercept = p_linear(2);
                    else
                        % Fallback to linear for small datasets
                        p = polyfit(x, y, 1);
                        slope = p(1);
                        intercept = p(2);
                        trendLine = polyval(p, x);
                    end

                case 'sens slope'
                    % Sen's slope (non-parametric)
                    slopes = zeros(n*(n-1)/2, 1);
                    k = 0;

                    for i = 1:n-1
                        for j = i+1:n
                            k = k + 1;
                            slopes(k) = (y(j) - y(i)) / (x(j) - x(i));
                        end
                    end

                    % Sen's slope is the median of all slopes
                    slope = median(slopes, 'omitnan');

                    % Calculate intercept using median of y - slope*x
                    intercepts = y - slope * x;
                    intercept = median(intercepts, 'omitnan');

                    trendLine = slope * x + intercept;
            end

            % Calculate R-squared and p-value (for all methods)
            if ~isempty(trendLine)
                % R-squared calculation
                y_fit = trendLine;
                y_mean = mean(y);
                ss_res = sum((y - y_fit).^2);
                ss_tot = sum((y - y_mean).^2);
                if ss_tot > 0
                    r2 = 1 - (ss_res / ss_tot);
                else
                    r2 = NaN;
                end

                % p-value calculation (using linear model for consistency)
                if n > 2
                    [~, ~, ~, ~, stats] = regress(y(:), [ones(length(x), 1), x(:)]);
                    if ~isempty(stats)
                        pval = stats(3);
                    else
                        pval = NaN;
                    end
                else
                    pval = NaN;
                end
            end
        end