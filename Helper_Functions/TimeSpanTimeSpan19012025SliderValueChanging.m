function TimeSpanTimeSpan19012025SliderValueChanging(app, event)
            timescales = app.TimescaleDropDown.Value;
            %Callback function for TimeSpanSlider value changing
            %Get the current timescale selection
            switch timescales
                case 'Monthly'
                    % Define the starting and ending dates for the slider scale
                    startDate = datetime(1901, 1, 1);
                    endDate   = datetime(2025, 12, 1);

                    % Generate all months between the start and end dates
                    allTimeDates = startDate:calmonths(1):endDate;
                    totalMonths = numel(allTimeDates);

                    % Slider limits
                    app.TimeSpan19012025Slider.Limits = [1, totalMonths];

                    % --- Compute tick positions ---
                    years = year(startDate):year(endDate);

                    % Choose step (e.g., every 10 years to avoid overlap)
                    tickStep = 10;
                    yearsShown = years(mod(years, tickStep) == 0);  % pick 1910, 1920, ...

                    % Find January positions for chosen years
                    yearDates = datetime(yearsShown,1,1);
                    [~, yearTicks] = ismember(yearDates, allTimeDates);

                    % Assign ticks and labels
                    app.TimeSpan19012025Slider.MajorTicks = yearTicks;
                    app.TimeSpan19012025Slider.MajorTickLabels = string(yearsShown);

                    % --- Update slider value safely ---
                    currentSliderValue = round(event.Value);
                    currentSliderValue(1) = max(currentSliderValue(1), app.TimeSpan19012025Slider.Limits(1));
                    currentSliderValue(2) = min(currentSliderValue(2), app.TimeSpan19012025Slider.Limits(2));
                    app.TimeSpan19012025Slider.Value = currentSliderValue;

                    % --- Map back to month-year strings ---
                    app.selectedStartTime = datestr(allTimeDates(currentSliderValue(1)), 'yyyy');
                    app.selectedEndTime   = datestr(allTimeDates(currentSliderValue(2)), 'yyyy');

                    % --- Update UI labels ---
                    app.StartTimeLabel.Text = app.selectedStartTime;
                    app.EndTimeLabel.Text   = app.selectedEndTime;

                case 'Annual'
                    % Show error message and revert to Monthly
                    uialert(app.UIFigure, 'Annual timescale is not available.', 'Feature Not Available');
                    %app.TimescaleDropDown.Value = 'Monthly';
                    % The callback will trigger again with 'Monthly' selection

                case 'Decadal'
                    % Show error message and revert to Monthly
                    uialert(app.UIFigure, 'Decadal timescale is not available.', 'Feature Not Available');
                    %app.TimescaleDropDown.Value = 'Monthly';
                    % The callback will trigger again with 'Monthly' selection
            end
            updateAllPlots(app);
        end