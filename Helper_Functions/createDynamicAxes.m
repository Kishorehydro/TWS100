function createDynamicAxes(app)
            % Store original position ONLY if not already stored
            if isempty(app.MainAxesOriginalPosition)
                app.MainAxesOriginalPosition = app.UIAxes.Position;
                app.MainAxesOriginalUnits = app.UIAxes.Units;
            end

            % Ensure we have valid figure dimensions
            drawnow;

            % Convert to pixels for consistent calculations
            originalAxesUnits = app.UIAxes.Units;
            originalFigureUnits = app.UIFigure.Units;

            app.UIAxes.Units = 'pixels';
            app.UIFigure.Units = 'pixels';

            % Get current layout information
            figPos = app.UIFigure.Position;
            figWidth = figPos(3);
            currentMainPos = app.UIAxes.Position;

            % Calculate new positions
            padding = 15;
            availableSpace = figWidth - currentMainPos(1) - padding;

            % Split available space: 60% for main, 40% for dynamic
            mainWidth = round(availableSpace * 0.60);
            dynamicWidth = round(availableSpace * 0.40);

            % Enforce minimum sizes
            minMainWidth = 400;
            minDynamicWidth = 250;

            if mainWidth < minMainWidth
                mainWidth = minMainWidth;
                dynamicWidth = availableSpace - mainWidth - padding;
            end

            if dynamicWidth < minDynamicWidth
                dynamicWidth = minDynamicWidth;
                mainWidth = availableSpace - dynamicWidth - padding;
                if mainWidth < minMainWidth
                    mainWidth = minMainWidth;
                    totalNeeded = minMainWidth + minDynamicWidth + padding;
                    if availableSpace < totalNeeded
                        scale = availableSpace / totalNeeded;
                        mainWidth = round(minMainWidth * scale);
                        dynamicWidth = round(minDynamicWidth * scale);
                    end
                end
            end

            % Position main axes
            newMainPos = [currentMainPos(1), currentMainPos(2), mainWidth, currentMainPos(4)];
            app.UIAxes.Position = newMainPos;

            % Create or update dynamic axes
            xPos = currentMainPos(1) + mainWidth + padding;
            yPos = currentMainPos(2);
            axHeight = currentMainPos(4);

            if isempty(app.DynamicAxes) || ~isvalid(app.DynamicAxes)
                app.DynamicAxes = uiaxes(app.UIFigure);
            end

            app.DynamicAxes.Units = 'pixels';
            app.DynamicAxes.Position = [xPos, yPos, dynamicWidth, axHeight];
            app.DynamicAxes.Visible = 'on';
            app.DynamicAxes.Parent = app.UIAxes.Parent;

            % Configure dynamic axes appearance
            title(app.DynamicAxes, 'Validation Results');
            xlabel(app.DynamicAxes, 'Time');
            ylabel(app.DynamicAxes, 'Value');
            app.DynamicAxes.Box = 'on';

            % Restore original units
            app.UIAxes.Units = originalAxesUnits;
            app.UIFigure.Units = originalFigureUnits;
        end