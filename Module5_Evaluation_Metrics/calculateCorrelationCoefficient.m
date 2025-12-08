function cc = calculateCorrelationCoefficient(app,y1, y2)
            % Calculate correlation coefficient
            if length(y1) < 2
                cc = NaN;
                return;
            end
            R = corrcoef(y1, y2);
            cc = R(1,2);
        end