function plotOnDynamicAxes(app, checkedTexts)
            if isempty(app.DynamicAxes) || ~isvalid(app.DynamicAxes)
                return;
            end

            % Clear previous plots
            cla(app.DynamicAxes);
            hold(app.DynamicAxes, 'on');

            colors = lines(3); % Get different colors for each dataset
            plotType = app.PlotTypeDropDown.Value;

            hasPlots = false;

            % Plot CGWB data
            if any(strcmp(checkedTexts, 'CGWB'))
                hasPlots = plotCGWBData(app, plotType) || hasPlots;
            end

            % Plot GRACE data
            if any(strcmp(checkedTexts, 'GRACE'))
                hasPlots = plotGRACEData(app, plotType) || hasPlots;
            end

            % Plot Precipitation data
            if any(strcmp(checkedTexts, 'Precipitation'))
                hasPlots = plotPrecipitationData(app, plotType) || hasPlots;
            end

            hold(app.DynamicAxes, 'off');

            % Add legend only if we have plots
            if hasPlots
                legend(app.DynamicAxes, 'show', 'Location', 'best');
            else
                legend(app.DynamicAxes, 'off');
            end
        end