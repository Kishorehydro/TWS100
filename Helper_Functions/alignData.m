function [y1_aligned, y2_aligned] = alignData(app,y1, y2)
            % Align two datasets by removing time points where either has NaN
            validMask = ~isnan(y1) & ~isnan(y2);
            y1_aligned = y1(validMask);
            y2_aligned = y2(validMask);
        end