function plotCGWB_Temporal(app)
        try
            Use your loaded CGWB data
            plot(app.UIAxes, app.CGWBTime, app.CGWBAvg, ...
                'o--', 'Color', [0.620, 0.482, 0.710], ... % #9e7bb5
                'LineWidth', 2, ...
                'MarkerSize', 6, ...
                'DisplayName', 'CGWB Groundwater Level');
        
        catch ME
            warning(ME.identifier,'Could not plot CGWB data: %s', ME.message);
        end
end