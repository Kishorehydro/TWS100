 function plotSpatialBasinMapDynamic(app, lonPts, latPts, values, basinPolygon, plotTitle)
            % 1. Define fine grid
            res = 0.025;
            lonRange = min(basinPolygon(:,1)):res:max(basinPolygon(:,1));
            latRange = min(basinPolygon(:,2)):res:max(basinPolygon(:,2));
            [LonGrid, LatGrid] = meshgrid(lonRange, latRange);

            % 2. Interpolate scattered points
            F = scatteredInterpolant(lonPts, latPts, values, 'natural', 'linear');
            GridVals = F(LonGrid, LatGrid);

            % 3. Mask outside the basin
            inMask = inpolygon(LonGrid, LatGrid, basinPolygon(:,1), basinPolygon(:,2));
            GridVals(~inMask) = NaN;

            % 4. Plot on dynamic axes
            cla(app.DynamicAxes);
            pcolor(app.DynamicAxes, LonGrid, LatGrid, GridVals);
            shading(app.DynamicAxes, 'flat');

            % 5. Custom colormap
            baseColors = [...
                103 0   31;   % dark red
                178 24  43;   % medium red
                214 96  77;   % light red
                244 165 130;  % very light red
                247 247 247;  % white
                146 197 222;  % light blue
                67  147 195;  % medium blue
                33  102 172;  % darker blue
                5   48  97];  % darkest blue

            baseColors = baseColors ./ 255;
            x  = linspace(0, 1, size(baseColors,1));
            xi = linspace(0, 1, 256);
            cmap = interp1(x, baseColors, xi, 'linear');
            colormap(app.DynamicAxes, cmap);

            % 6. Symmetric color axis
            cmin = min(values(:));
            cmax = max(values(:));
            cabs = max(abs([cmin cmax]));
            clim(app.DynamicAxes, [-cabs cabs]);

            % 7. Colorbar
            c = colorbar(app.DynamicAxes, 'southoutside');
            c.Label.String = 'TWSA (mm/month)';
            c.Label.FontWeight = 'bold';
            c.Label.FontName   = 'Times New Roman';
            c.Label.FontSize   = 12;
            % Adjust position
            cpos = c.Position;
            cpos(1) = 0.35;
            cpos(2) = cpos(2)-0.06;
            cpos(3) = 0.3;
            c.Position = cpos;

            % 8. Labels & title
            xlabel(app.DynamicAxes, 'Longitude');
            ylabel(app.DynamicAxes, 'Latitude');
            title(app.DynamicAxes, plotTitle);

            % 9. Grid & aspect
            grid(app.DynamicAxes, 'on');
            axis(app.DynamicAxes, 'equal');

            % 10. Overlay polygon
            hold(app.DynamicAxes, 'on');
            plot(app.DynamicAxes, basinPolygon(:,1), basinPolygon(:,2), 'k-', 'LineWidth', 2);
            hold(app.DynamicAxes, 'off');

            % 11. Tick labels formatting
            xticks = get(app.DynamicAxes,'XTick');
            yticks = get(app.DynamicAxes,'YTick');
            xticklabels = arrayfun(@(x) sprintf('%.1f°%s', abs(x), ternary(app,x>=0,'E','W')), xticks, 'UniformOutput', false);
            yticklabels = arrayfun(@(y) sprintf('%.1f°%s', abs(y), ternary(app,y>=0,'N','S')), yticks, 'UniformOutput', false);
            set(app.DynamicAxes,'XTickLabel',xticklabels,'YTickLabel',yticklabels);

            app.DynamicAxes.XAxis.TickLabelRotation = 0;  % optional
            app.DynamicAxes.XAxis.FontName = 'Times New Roman';
            app.DynamicAxes.XAxis.FontSize = 12;
            app.DynamicAxes.XAxis.FontWeight = 'normal';
            app.DynamicAxes.YAxis.TickLabelRotation = 90;
            app.DynamicAxes.YAxis.FontName = 'Times New Roman';
            app.DynamicAxes.YAxis.FontSize = 12;
            app.DynamicAxes.YAxis.FontWeight = 'normal';
        end