function plotSpatialBasinMap(app, lonPts, latPts, values, basinPolygon, plotTitle)
            % % Get dropdown selection
            screenSize = get(0,'ScreenSize');

            % Design size (from your UIFigure in Design View)
            designWidth = 1212;
            designHeight = 764;

            % Compute scale factor relative to screen size
            scale = min(screenSize(3)/designWidth, screenSize(4)/designHeight);
            % 1. Define fine grid
            res = 0.025;
            lonRange = min(basinPolygon(:,1)):res:max(basinPolygon(:,1));
            latRange = min(basinPolygon(:,2)):res:max(basinPolygon(:,2));
            [LonGrid, LatGrid] = meshgrid(lonRange, latRange);

            % 2. Interpolate
            F = scatteredInterpolant(lonPts, latPts, values, 'natural','linear');
            GridVals = F(LonGrid, LatGrid);

            % 3. Mask outside
            inMask = inpolygon(LonGrid, LatGrid, basinPolygon(:,1), basinPolygon(:,2));
            GridVals(~inMask) = NaN;

            % 4. Plot
            cla(app.UIAxes);
            pcolor(app.UIAxes, LonGrid, LatGrid, GridVals);
            shading(app.UIAxes,'flat');

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

            % Normalize to [0,1]
            baseColors = baseColors ./ 255;

            % --- Interpolate colormap ---
            x  = linspace(0, 1, size(baseColors,1));
            xi = linspace(0, 1, 256);
            cmap = interp1(x, baseColors, xi, 'linear');
            colormap(app.UIAxes, cmap);

            % --- Symmetric color axis ---
            cmin = min(values(:));
            cmax = max(values(:));
            cabs = max(abs([cmin cmax]));
            clim(app.UIAxes, [-cabs cabs]);

            % --- Colorbar below, centered ---
            c = colorbar(app.UIAxes,'southoutside');
            c.Label.String     = 'TWSA (mm/month)';
            c.Label.FontWeight = 'bold';
            c.Label.FontName   = 'Times New Roman';
            c.Label.FontSize   = 12;

            % Center the colorbar (adjust numbers if needed)
            cpos = c.Position;   % [x y w h]
            cpos(1) = 0.35;      % shift horizontally
            cpos(2) = cpos(2)-0.06;
            cpos(3) = 0.3;       % shrink width
            c.Position = cpos;


            % Labels & title
            xlabel(app.UIAxes,'Longitude','FontWeight','bold');
            ylabel(app.UIAxes,'Latitude','FontWeight','bold');
            %title(app.UIAxes, plotTitle,'FontWeight','bold');

            % Fix aspect
            axis(app.UIAxes,'equal','tight');

            % Overlay polygon
            hold(app.UIAxes,'on');
            plot(app.UIAxes, basinPolygon(:,1), basinPolygon(:,2), 'k-', 'LineWidth',2);
            hold(app.UIAxes,'off');

            % Format ticks (°E/°W, °N/°S)
            xticks = get(app.UIAxes,'XTick');
            yticks = get(app.UIAxes,'YTick');
            xticklabels = arrayfun(@(x) sprintf('%.1f°%s', abs(x), ternary(app,x>=0,'E','W')), xticks, 'UniformOutput', false);
            yticklabels = arrayfun(@(y) sprintf('%.1f°%s', abs(y), ternary(app,y>=0,'N','S')), yticks, 'UniformOutput', false);
            set(app.UIAxes,'XTickLabel',xticklabels,'YTickLabel',yticklabels);
            % ✅ Rotate Y-axis labels and set font
            %app.UIAxes.XAxis.TickLabelRotation = 90;         % rotate 90 degrees
            app.UIAxes.XAxis.FontName = 'Times New Roman';   % font style
            app.UIAxes.XAxis.FontSize = 12;                  % (optional) font size
            app.UIAxes.XAxis.FontWeight = 'normal';          % or 'bold' if you want bold
            % ✅ Rotate Y-axis labels and set font
            app.UIAxes.YAxis.TickLabelRotation = 90;         % rotate 90 degrees
            app.UIAxes.YAxis.FontName = 'Times New Roman';   % font style
            app.UIAxes.YAxis.FontSize = 12;                  % (optional) font size
            app.UIAxes.YAxis.FontWeight = 'normal';          % or 'bold' if you want bold
        end