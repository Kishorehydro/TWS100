 function formatTemporalPlot(app)
            xlabel(app.UIAxes, 'Time', 'FontSize', 14, 'FontWeight', 'bold');
            ylabel(app.UIAxes, 'Anomaly (mm)', 'FontSize', 14, 'FontWeight', 'bold');

            % Set x-axis limits to match CGWB data period
            xlim(app.UIAxes, [datetime(2002,1,1), datetime(2018,12,31)]);

            % Yearly ticks
            years = 2002:2018;
            xticks(app.UIAxes, datetime(years, 1, 1));
            xticklabels(app.UIAxes, arrayfun(@num2str, years, 'UniformOutput', false));

            grid(app.UIAxes, 'on');
            legend(app.UIAxes, 'show', 'Location', 'best');
            title(app.UIAxes, 'Temporal Analysis: GRACE vs CGWB vs Precipitation');
        end