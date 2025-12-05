function nse = calculateNSE(app,observed, simulated)
            % Calculate Nash-Sutcliffe Efficiency
            % NSE = 1 - (sum((observed - simulated)^2) / sum((observed - mean(observed))^2))
            if length(observed) < 2
                nse = NaN;
                return;
            end
            numerator = sum((observed - simulated).^2);
            denominator = sum((observed - mean(observed)).^2);

            if denominator == 0
                nse = NaN;
            else
                nse = 1 - (numerator / denominator);
            end
        end