function updateAllPlots(app)
            % % Get dropdown selection
            screenSize = get(0,'ScreenSize');

            % Design size (from your UIFigure in Design View)
            designWidth = 1212;
            designHeight = 764;

            % Compute scale factor relative to screen size
            scale = min(screenSize(3)/designWidth, screenSize(4)/designHeight);
            %
            % % Apply new scaled size (use 85% of available screen for safety)
            % newWidth = round(designWidth * scale* 0.85);% * 0.85
            % newHeight = round(designHeight * scale* 0.85);
            %
            % % Update UIFigure size
            % app.UIFigure.Position = [50 50 newWidth newHeight];
            cla(app.UIAxes, 'reset');
            legendItems = {};
            plotType = app.PlotTypeDropDown.Value;  % 'Temporal' or 'Spatial'


            switch plotType

                case 'Temporal'
                    % ===== Temporal Plot =====

                    timescales = app.TimescaleDropDown.Value;
                    switch timescales
                        %case 'Daily'
                        case 'Monthly'
                            cla(app.UIAxes, 'reset');
                            hold(app.UIAxes,'on'); % clear axes before plotting anything
                            % Define the starting and ending dates for the slider scale
                            startDate = datetime(1901, 1, 1); % Start date (01-1901)
                            endDate = datetime(2025, 12, 1);  % End date (12-2025)
                            % Generate all months between the start and end dates
                            allTimeDates = startDate:calmonths(1):endDate;
                            % Get selected time range from slider
                            sIdx = round(app.TimeSpan19012025Slider.Value(1));
                            eIdx = round(app.TimeSpan19012025Slider.Value(2));
                            sIdx = max(sIdx,1);
                            eIdx = min(eIdx, numel(allTimeDates));
                            selectedTimeRange = allTimeDates(sIdx:eIdx);
                            x = sIdx:eIdx;
                            % Get start & end years of current visible time range
                            tStart = year(selectedTimeRange(1));
                            tEnd   = year(selectedTimeRange(end));
                            xlim(app.UIAxes, [sIdx eIdx]);
                            % Calculate total span in years
                            spanYears = tEnd - tStart;

                            % Choose a step size dynamically (prevent overlap)
                            if spanYears > 40
                                step = 10;   % e.g., large range → coarser ticks
                            elseif spanYears > 20
                                step = 5;
                            elseif spanYears > 10
                                step = 2;
                            else
                                step = 1;    % short range → finer ticks
                            end

                            % Define ticks
                            tickYears = tStart:step:tEnd;

                            % % Axis ticks every 2 years
                            % tickYears = year(selectedTimeRange(1)) : 2 : year(selectedTimeRange(end));
                            xt = datetime(tickYears, 1, 1);
                            % Convert datetime to indices relative to allTimeDates
                            [~, idxTicks] = ismember(xt, allTimeDates);
                            % Apply ticks and labels
                            app.UIAxes.XTick = idxTicks;
                            app.UIAxes.XTickLabel = cellstr(datestr(xt, 'yyyy'));
                            % Set axis limits (numeric)
                            xlim(app.UIAxes, [sIdx eIdx]);
                            timescales = app.TimescaleDropDown.Value;
                            legendItems = {};

                            %% ==================== RECONSTRUCTED TREE ====================
                            selectedNodes = app.RTWSA.CheckedNodes;
                            % Colors for different reconstructions (normalized keys)
                            colors = struct('hg19', [0.0 0.60 0.50], ...   % teal
                                'p25',[0.95 0.60 0.20], ...  % golden orange
                                'l21',       [0.35 0.70 0.90], ...  % light blue
                                'd23',     [0.90 0.10 0.15], ...  % red
                                'm25',   [0.60 0.40 0.20]);     % brown

                            for i = 1:numel(selectedNodes)
                                % Skip parent nodes
                                if ~isempty(selectedNodes(i).Children), continue; end

                                rawName = strtrim(selectedNodes(i).Text); % clean up
                                nodeKey = lower(rawName); % normalize to lowercase

                                REC = [];
                                switch nodeKey
                                    %% HUMPHREY (6 datasets)
                                    case 'hg19'
                                        Hp_REC = NaN(6,1500);
                                        Hp_REC(1,[app.Hp_GERECMN]) = mean(applyBasinMask(app, app.Hp_GERECData, app.Hp_GERECLat, app.Hp_GERECLon),1);
                                        Hp_REC(2,[app.Hp_GGRECMN]) = mean(applyBasinMask(app, app.Hp_GGRECData, app.Hp_GGRECLat, app.Hp_GGRECLon),1);
                                        Hp_REC(3,[app.Hp_GMRECMN]) = mean(applyBasinMask(app, app.Hp_GMRECData, app.Hp_GMRECLat, app.Hp_GMRECLon),1);
                                        Hp_REC(4,[app.Hp_JERECMN]) = mean(applyBasinMask(app, app.Hp_JERECData, app.Hp_JERECLat, app.Hp_JERECLon),1);
                                        Hp_REC(5,[app.Hp_JGRECMN]) = mean(applyBasinMask(app, app.Hp_JGRECData, app.Hp_JGRECLat, app.Hp_JGRECLon),1);
                                        Hp_REC(6,[app.Hp_JMRECMN]) = mean(applyBasinMask(app, app.Hp_JMRECData, app.Hp_JMRECLat, app.Hp_JMRECLon),1);

                                        REC = [
                                            min(Hp_REC, [], 1,'omitnan');
                                            max(Hp_REC, [], 1,'omitnan');
                                            mean(Hp_REC, 1,'omitnan')
                                            ];

                                        %% PALAZZOLI (4 datasets)
                                    case 'p25'
                                        Pl_REC = NaN(4,1500);
                                        Pl_REC(1,[app.PalazzoliLSTMMN])        = 10*mean(applyBasinMask(app, app.PalazzoliLSTMData, app.PalazzoliLSTMLat, app.PalazzoliLSTMLon),1);
                                        Pl_REC(2,[app.PalazzoliLSTMnoLCSIFMN]) = 10*mean(applyBasinMask(app, app.PalazzoliLSTMnoLCSIFData, app.PalazzoliLSTMnoLCSIFLat, app.PalazzoliLSTMnoLCSIFLon),1);
                                        Pl_REC(3,[app.PalazzoliBiLSTMMN])      = 10*mean(applyBasinMask(app, app.PalazzoliBiLSTMData, app.PalazzoliBiLSTMLat, app.PalazzoliBiLSTMLon),1);
                                        Pl_REC(4,[app.PalazzoliBiLSTMnoLCSIFMN]) = 10*mean(applyBasinMask(app, app.PalazzoliBiLSTMnoLCSIFData, app.PalazzoliBiLSTMnoLCSIFLat, app.PalazzoliBiLSTMnoLCSIFLon),1);

                                        REC = [
                                            min(Pl_REC, [], 1,'omitnan');
                                            max(Pl_REC, [], 1,'omitnan');
                                            mean(Pl_REC, 1,'omitnan')
                                            ];

                                        %% LI (single)
                                    case 'l21'
                                        Li_BA = 10*mean(applyBasinMask(app, app.LiRECData, app.LiRECLat, app.LiRECLon),1);
                                        Li_REC = NaN(1,1500);
                                        Li_REC(1,[app.LiRECMN]) = Li_BA;
                                        REC = repmat(Li_REC,3,1);

                                        %% DENG (single)
                                    case 'd23'
                                        Deng_BA = mean(applyBasinMask(app, app.DengRECData, app.DengRECLat, app.DengRECLon),1);
                                        Deng_REC = NaN(1,1500);
                                        Deng_REC(1,[app.DengRECMN]) = Deng_BA;
                                        REC = repmat(Deng_REC,3,1);

                                        %% MANDAL (single)
                                    case 'm25'
                                        Mandal_BA = mean(applyBasinMask(app, app.MandalRECData, app.MandalRECLat, app.MandalRECLon),1);
                                        Mandal_REC = NaN(1,1500);
                                        Mandal_REC(1,[app.MandalRECMN]) = Mandal_BA;
                                        REC = repmat(Mandal_REC,3,1);
                                end

                                % Pick color safely
                                if isfield(colors,nodeKey)
                                    c = colors.(nodeKey);
                                else
                                    c = [0.5 0.5 0.5];
                                end

                                % Fill band (flat since single dataset)
                                hold(app.UIAxes, 'on');  % Hold once at the beginning

                                if strcmp(nodeKey, 'hg19') || strcmp(nodeKey, 'p25')
                                    % Plot filled area
                                    fill(app.UIAxes, [x fliplr(x)], [REC(2, x) fliplr(REC(1, x))],c, 'FaceAlpha', 0.2, 'EdgeColor', 'none','DisplayName', strcat(rawName," Range"));
                                end

                                % Plot main line
                                plot(app.UIAxes, x, REC(3, x), 'Color', c, 'LineWidth',1.5,'LineStyle','--','DisplayName', strcat(rawName));

                            end


                            % Get selected GRACE datasets
                            selectedNodes = app.TWSA.CheckedNodes;
                            hold(app.UIAxes,'on');
                            % Colors for GRACE datasets (normalized keys)
                            colors = struct( ...
                                'jpl',  [0.2 0.2 0.2], ...  % dark gray
                                'csr',  [0.5 0.5 0.5], ...  % medium gray
                                'gsfc', [0.8 0.8 0.8]);     % light gray
                            markers= struct( ...
                                'jpl',  "o", ...  % dark gray
                                'csr',  "+", ...  % medium gray
                                'gsfc', '*' );     % light gray

                            for i = 1:numel(selectedNodes)
                                % Skip non-leaf nodes
                                if ~isempty(selectedNodes(i).Children), continue; end

                                rawName = strtrim(selectedNodes(i).Text);  % remove spaces
                                nodeKey = lower(rawName);

                                REC = [];
                                switch nodeKey
                                    case 'jpl'
                                        JPL_BA = 10*mean(applyBasinMask(app, app.JPLTWSData, app.JPLTWSLat, app.JPLTWSLon),1);
                                        REC = repmat(NaN,3,1500);
                                        REC(:,app.JPLTWSMN) = [JPL_BA; JPL_BA; JPL_BA];

                                    case 'csr'
                                        CSR_BA = 10*mean(applyBasinMask(app, app.CSRTWSData, app.CSRTWSLat, app.CSRTWSLon),1);
                                        REC = repmat(NaN,3,1500);
                                        REC(:,app.CSRTWSMN) = [CSR_BA; CSR_BA; CSR_BA];

                                    case 'gsfc'
                                        GSFC_BA = 10*mean(applyBasinMask(app, app.GFSCTWSData, app.GFSCTWSLat, app.GFSCTWSLon),1);
                                        REC = repmat(NaN,3,1500);
                                        REC(:,app.GFSCTWSMN) = [GSFC_BA; GSFC_BA; GSFC_BA];

                                    otherwise
                                        disp(['[TWSA] Skipping unhandled node: "', rawName, '"']);
                                        continue;
                                end

                                if isempty(REC), continue; end
                                eIdx = min(eIdx, size(REC,2));
                                x = sIdx:eIdx;

                                % Choose dataset color (fallback if missing)
                                if isfield(colors, nodeKey)
                                    c = colors.(nodeKey);
                                else
                                    c = [0.5 0.5 0.5];
                                end

                                if isfield(markers, nodeKey)
                                    d = markers.(nodeKey);
                                else
                                    d = 'square';
                                end

                                plot(app.UIAxes, x, REC(3,x), 'Color', c, 'LineWidth', 2,'Marker',d, 'DisplayName', strcat(upper(nodeKey)));%," TWSA"
                            end

                            % Use one of these values: '+' | 'o' | '*' | '.' | 'x' | 'square' | 'diamond' | 'v' | '^' | '>' | '<' | 'pentagram' |
                            % 'hexagram' | '|' | '_' | 'none'.
                            %% ==================== THIS STUDY TREE ====================
                            selectedNodes = app.This_Study.CheckedNodes;
                            hold(app.UIAxes,'on');
                            % Colors for each of your models
                            colors = struct( ...
                                'rf_imd',     [0.0 0.45 0.70], ...   % strong blue
                                'ann_g',      [0.85 0.33 0.10], ...  % bright orange
                                'ann_imd',     [0.93 0.69 0.13], ...  % yellow
                                'rf_g',       [0.49 0.18 0.56]);     % purple

                            for i = 1:numel(selectedNodes)
                                % Skip parent nodes
                                if ~isempty(selectedNodes(i).Children), continue; end

                                rawName = strtrim(selectedNodes(i).Text); % "Best", "ANN", etc.
                                nodeKey = lower(rawName);                 % normalize to lowercase

                                REC = [];
                                switch nodeKey
                                    %% BEST
                                    case 'rf_imd'
                                        Best_BA = mean(applyBasinMask(app, app.ThisStudyBestData, ...
                                            app.ThisStudyBestLat, app.ThisStudyBestLon),1);
                                        Best_REC = NaN(1,1500);
                                        Best_REC(1,[app.ThisStudyBestMN]) = Best_BA;
                                        REC = repmat(Best_REC,3,1);

                                        %% ANN
                                    case 'ann_g'
                                        ANN_BA = mean(applyBasinMask(app, app.ThisStudyANNData, ...
                                            app.ThisStudyANNLat, app.ThisStudyANNLon),1);
                                        ANN_REC = NaN(1,1500);
                                        ANN_REC(1,[app.ThisStudyANNMN]) = ANN_BA;
                                        REC = repmat(ANN_REC,3,1);

                                        %% LSTM
                                    case 'ann_imd'
                                        LSTM_BA = mean(applyBasinMask(app, app.ThisStudyLSTMData, ...
                                            app.ThisStudyLSTMLat, app.ThisStudyLSTMLon),1);
                                        LSTM_REC = NaN(1,1500);
                                        LSTM_REC(1,[app.ThisStudyLSTMMN]) = LSTM_BA;
                                        REC = repmat(LSTM_REC,3,1);

                                        %% RF
                                    case 'rf_g'
                                        RF_BA = mean(applyBasinMask(app, app.ThisStudyRFData, ...
                                            app.ThisStudyRFLat, app.ThisStudyRFLon),1);
                                        RF_REC = NaN(1,1500);
                                        RF_REC(1,[app.ThisStudyRFMN]) = RF_BA;
                                        REC = repmat(RF_REC,3,1);
                                end

                                if isempty(REC), continue; end
                                % Pick dataset color safely
                                if isfield(colors,nodeKey)
                                    c = colors.(nodeKey);
                                else
                                    c = [0.5 0.5 0.5]; % fallback gray
                                end

                                % Fill band (flat since single dataset)
                                % fill(app.UIAxes, [x fliplr(x)], [REC(2,x) fliplr(REC(1,x))], ...
                                %     c, 'FaceAlpha',0.2, 'EdgeColor','none');
                                hold(app.UIAxes,'on');

                                % Mean line
                                plot(app.UIAxes, x, REC(3,x), 'Color', c, 'LineWidth',1.5,'DisplayName', strcat(rawName));%," RTWSA"

                            end
                            % Axes settings
                            grid(app.UIAxes,'on');
                            app.UIAxes.FontName = 'Times New Roman';
                            app.UIAxes.FontSize = 14;
                            app.UIAxes.XLabel.String = 'Time (Years)';
                            app.UIAxes.XLabel.FontName = 'Times New Roman';
                            app.UIAxes.XLabel.FontWeight = 'bold';
                            app.UIAxes.XLabel.FontSize = 18;
                            app.UIAxes.YLabel.String = '(R)TWSA (mm)';   % left axis label
                            app.UIAxes.YLabel.FontName = 'Times New Roman';
                            app.UIAxes.YLabel.FontWeight = 'bold';
                            app.UIAxes.YLabel.FontSize = 18;
                            % Lyticks = 0:round(max(REC,2)/5):max(REC,2);   % adjust step as needed
                            % app.UIAxes.YTick = Lyticks;
                            hold(app.UIAxes,'off');
                            %% ==================== PRECIPITATION (inverted, on right axis, with gap to TWS) ====================
                            selectedNodes = app.Precipitation.CheckedNodes;
                            yyaxis(app.UIAxes,'right');
                            yl = ylabel(app.UIAxes,'Precipitation (mm)');  % get handle
                            yl.FontSize = 18;
                            yl.FontName = 'Times New Roman';
                            yl.FontWeight = 'bold';
                            set(app.UIAxes,'YDir','reverse');  % invert the axis so bars grow downward

                            precipData = []; precipLabels = {};
                            for i = 1:numel(selectedNodes)
                                if ~isempty(selectedNodes(i).Children), continue; end
                                rawName = strtrim(selectedNodes(i).Text);
                                nodeKey = lower(rawName);
                                clear data

                                switch nodeKey
                                    case 'imd'
                                        % IMD (already in mm monthly)
                                        app.IMD_BA = mean(applyBasinMask(app, app.IMDData, app.IMDLat, app.IMDLon),1);
                                        data = NaN(1,1500); data(1,app.IMDMN) = app.IMD_BA;

                                    case 'gpcp'
                                        % GPCP (mm/month)
                                        app.GPCP_BA = mean(applyBasinMask(app, app.GPCPData, app.GPCPLat, app.GPCPLon),1);
                                        data = NaN(1,1500); data(1,app.GPCPMN) = app.GPCP_BA;

                                    case 'era5'
                                        % ERA5 'tp' is meters; convert to mm
                                        app.ERA5_BA = 1000*mean(applyBasinMask(app, app.ERA5Data, app.ERA5Lat, app.ERA5Lon),1);
                                        data = NaN(1,1500); data(1,app.ERA5MN) = app.ERA5_BA;
                                end

                                if exist('data','var')
                                    precipData   = [precipData; data];    %#ok<AGROW>
                                    precipLabels = [precipLabels; nodeKey]; %#ok<AGROW>
                                end
                            end

                            if ~isempty(precipData)
                                % What’s selected?
                                nSel      = size(precipData,1);
                                hasIMD    = any(strcmpi(precipLabels,'imd'));
                                % Stats in window
                                p_min  = min(precipData(:,x),[],1,'omitnan');
                                p_max  = max(precipData(:,x),[],1,'omitnan');
                                p_mean = mean(precipData(:,x),1,'omitnan');
                                Pmax   = max(p_max,[],'omitnan');

                                % ---- Plot according to selection rules ----
                                if nSel == 1
                                    % Only one dataset selected
                                    ydata = precipData(1,x);
                                    if strcmpi(precipLabels{1},'imd')
                                        hold(app.UIAxes,'on');
                                        % IMD as open circles (inverted)
                                        bar(app.UIAxes, x, ydata, 0.4, 'FaceColor','none','EdgeColor',[0.2 0.7 0.9],'LineWidth',1.2, 'DisplayName','IMD Precip');
                                        plot(app.UIAxes, x, ydata, 'o', 'Color','k', 'MarkerFaceColor','w','MarkerSize',4,'DisplayName','IMD Precip');
                                    elseif strcmpi(precipLabels{1},'gpcp')
                                        bar(app.UIAxes, x, ydata, 0.4, 'FaceColor','none','EdgeColor',[0.2 0.7 0.9],'LineWidth',1.2, 'DisplayName','GPCP Precip');
                                    else % ERA5
                                        bar(app.UIAxes, x, ydata, 0.4, 'FaceColor','none','EdgeColor',[0.2 0.7 0.9],'LineWidth',1.2, 'DisplayName','ERA5 Precip');
                                    end
                                elseif nSel == 2
                                    % Multiple selected
                                    % (Only IMD points + whiskers + hollow mean bar in blue tones)
                                    % Hollow mean bar (blue edge)
                                    hold(app.UIAxes,'on');
                                    bar(app.UIAxes, x, p_mean, 0.45, 'FaceColor','none','EdgeColor',[0.2 0.7 0.9],'LineWidth',1.2, 'DisplayName','Mean Precip');
                                    % Whiskers (min–max) behind mean
                                    legendAdded = false;  % flag to ensure legend appears only once

                                    for k = 1:numel(x)
                                        if ~legendAdded
                                            % First whisker line with legend
                                            line(app.UIAxes, [x(k) x(k)], [p_max(k) p_min(k)],'Color',[0.35 0.35 0.35], 'LineWidth',1.0,'LineStyle','-', 'Marker','none', 'DisplayName','Precip Range');
                                            legendAdded = true;  % next lines won’t have legend
                                        else
                                            % Other lines: no legend
                                            line(app.UIAxes, [x(k) x(k)], [p_max(k) p_min(k)],'Color',[0.35 0.35 0.35], 'LineWidth',1.0,'LineStyle','-', 'Marker','none', 'HandleVisibility','off');
                                        end
                                    end

                                    if hasIMD
                                        % Plot IMD as “o” markers
                                        j = find(strcmpi(precipLabels,'imd'),1);
                                        plot(app.UIAxes, x, precipData(j,x), 'o', 'Color','k', 'MarkerFaceColor','w','MarkerSize',4,'DisplayName','IMD Precip');
                                    end
                                else
                                    hold(app.UIAxes,'on');
                                    bar(app.UIAxes, x, p_mean, 0.45, 'FaceColor','none','EdgeColor',[0.2 0.7 0.9],'LineWidth',1.2, 'DisplayName','Mean Precip');
                                    j = find(strcmpi(precipLabels,'imd'),1);
                                    plot(app.UIAxes, x, precipData(j,x), 'o', 'Color','k', 'MarkerFaceColor','w','MarkerSize',4,'DisplayName','IMD Precip');
                                    legendAdded = false;  % flag to ensure legend appears only once

                                    for k = 1:numel(x)
                                        if ~legendAdded
                                            % First whisker line with legend
                                            line(app.UIAxes, [x(k) x(k)], [p_max(k) p_min(k)],'Color',[0.35 0.35 0.35], 'LineWidth',1.0,'LineStyle','-', 'Marker','none', 'DisplayName','Precip Range');
                                            legendAdded = true;  % next lines won’t have legend
                                        else
                                            % Other lines: no legend
                                            line(app.UIAxes, [x(k) x(k)], [p_max(k) p_min(k)],'Color',[0.35 0.35 0.35], 'LineWidth',1.0,'LineStyle','-', 'Marker','none', 'HandleVisibility','off');
                                        end
                                    end


                                end

                                % ---------- Dynamic Axis coordination (TWSA + Precip Gap) ----------
                                yyaxis(app.UIAxes,'left');

                                % Collect ALL TWSA data from plotted series in the selected window
                                allTWSA = [];
                                h = findall(app.UIAxes,'Type','Line'); % get plotted lines
                                for k = 1:numel(h)
                                    ydata = h(k).YData;
                                    xdata = h(k).XData;
                                    % only keep values within the sIdx:eIdx window
                                    mask = (xdata >= sIdx & xdata <= eIdx);
                                    if any(mask)
                                        allTWSA = [allTWSA, ydata(mask)];
                                    end
                                end

                                if ~isempty(allTWSA)
                                    % Dynamic limits based on selected time window
                                    twsMin = min(allTWSA, [], 'omitnan');
                                    twsMax = max(allTWSA, [], 'omitnan');

                                    % Add padding for readability
                                    pad = 0.15 * (twsMax - twsMin);
                                    twsLimits = [twsMin , twsMax + pad];

                                    % Apply limits to left axis
                                    ylim(app.UIAxes, twsLimits);

                                    % Dynamic ticks
                                    step = round((twsMax - twsMin) / 5);
                                    if step == 0, step = 1; end
                                    app.UIAxes.YTick = round(twsMin):step:round(twsMax);

                                    % -------- Right axis (precipitation, inverted, with gap) --------
                                    yyaxis(app.UIAxes,'right');
                                    Pmax = max(p_max,[],'omitnan');   % already computed from precip data
                                    gap  = 1.2 * (twsLimits(2) - twsLimits(1)); % proportional gap
                                    ylim(app.UIAxes, [0 Pmax + gap]);
                                    yticks(app.UIAxes, 0:round(Pmax/5):Pmax);
                                end

                            end

                            % Ensure grid and axis font
                            grid(app.UIAxes, 'on');
                            app.UIAxes.FontName = 'Times New Roman';
                            app.UIAxes.FontSize = 18* scale;

                            % Axis labels
                            app.UIAxes.XLabel.String = 'Time (Years)';
                            app.UIAxes.XLabel.FontName = 'Times New Roman';
                            app.UIAxes.XLabel.FontWeight = 'bold';
                            app.UIAxes.XLabel.FontSize = 18* scale;
                            % Create legend AFTER plotting
                            lg = legend(app.UIAxes, 'show');
                            % Legend configuration
                            % if exist('newWidth','var') && ~isempty(newWidth)
                            lg.NumColumns =9;% min(9, floor(newWidth/150));
                            % else
                            %     lg.NumColumns = 3; % fallback
                            % end
                            lg.Location    = 'southoutside';
                            lg.Orientation = 'horizontal';
                            lg.Box         = 'on';
                            lg.Interpreter = 'none';
                            lg.AutoUpdate  = 'off';
                            lg.FontName    = 'Times New Roman';
                            lg.FontWeight  = 'bold';

                            if exist('scale','var') && ~isempty(scale)
                                lg.FontSize = 10* scale;
                            else
                                lg.FontSize = 12; % fallback
                            end

                            hold(app.UIAxes, 'off');

                        case 'Annual'
                            cla(app.UIAxes, 'reset');
                            hold(app.UIAxes,'on'); % clear axes before plotting anything
                            % Define the starting and ending years for the slider scale
                            startYr = 1901;
                            endYr = 2025;
                            allYrs = startYr:endYr;
                            % Get selected time range from slider
                            sIdx = round(app.TimeSpan19012025Slider.Value(1));
                            eIdx = round(app.TimeSpan19012025Slider.Value(2));
                            sIdx = max(sIdx,1);
                            eIdx = min(eIdx, numel(allYrs));
                            selectedTimeRange = allYrs(sIdx:eIdx);
                            x = sIdx:eIdx;
                            % Get start & end years of current visible time range
                            tStart = selectedTimeRange(1);
                            tEnd   = selectedTimeRange(end);

                            % Calculate total span in years
                            spanYrs = tEnd - tStart;

                            % Choose a step size dynamically (prevent overlap)
                            if spanYrs > 40
                                step = 10;   % e.g., large range → coarser ticks
                            elseif spanYrs > 20
                                step = 5;
                            elseif spanYrs > 10
                                step = 2;
                            else
                                step = 1;    % short range → finer ticks
                            end

                            % Define ticks
                            tickYrs = tStart:step:tEnd;

                            % Apply ticks and labels
                            app.UIAxes.XTick = find(ismember(allYrs, tickYrs));
                            app.UIAxes.XTickLabel = cellstr(num2str(tickYrs'));

                            % Set axis limits (numeric)
                            xlim(app.UIAxes, [sIdx eIdx]);
                            timescales = app.TimescaleDropDown.Value;
                            legendItems = {};
                            %% ==================== RECONSTRUCTED TREE ====================
                            selectedNodes = app.RTWSA.CheckedNodes;
                            % Colors for different reconstructions (normalized keys)
                            colors = struct('hg19', [0.0 0.60 0.50], ...   % teal
                                'p25',[0.95 0.60 0.20], ...  % golden orange
                                'l21',       [0.35 0.70 0.90], ...  % light blue
                                'd23',     [0.90 0.10 0.15], ...  % red
                                'm25',   [0.60 0.40 0.20]);     % brown

                            for i = 1:numel(selectedNodes)
                                % Skip parent nodes
                                if ~isempty(selectedNodes(i).Children), continue; end

                                rawName = strtrim(selectedNodes(i).Text); % clean up
                                nodeKey = lower(rawName); % normalize to lowercase

                                REC = [];
                                switch nodeKey
                                    %% HUMPHREY (6 datasets)
                                    case 'hg19'
                                        Hp_REC = NaN(6,1500);
                                        Hp_REC(1,[app.Hp_GERECMN]) = mean(applyBasinMask(app, app.Hp_GERECData, app.Hp_GERECLat, app.Hp_GERECLon),1);
                                        Hp_REC(2,[app.Hp_GGRECMN]) = mean(applyBasinMask(app, app.Hp_GGRECData, app.Hp_GGRECLat, app.Hp_GGRECLon),1);
                                        Hp_REC(3,[app.Hp_GMRECMN]) = mean(applyBasinMask(app, app.Hp_GMRECData, app.Hp_GMRECLat, app.Hp_GMRECLon),1);
                                        Hp_REC(4,[app.Hp_JERECMN]) = mean(applyBasinMask(app, app.Hp_JERECData, app.Hp_JERECLat, app.Hp_JERECLon),1);
                                        Hp_REC(5,[app.Hp_JGRECMN]) = mean(applyBasinMask(app, app.Hp_JGRECData, app.Hp_JGRECLat, app.Hp_JGRECLon),1);
                                        Hp_REC(6,[app.Hp_JMRECMN]) = mean(applyBasinMask(app, app.Hp_JMRECData, app.Hp_JMRECLat, app.Hp_JMRECLon),1);

                                        % Convert monthly to annual mean - handle partial years
                                        Hp_REC_annual = NaN(6,125);
                                        for datasetIdx = 1:6
                                            monthly_data = Hp_REC(datasetIdx,:);
                                            for yrIdx = 1:125
                                                start_month = (yrIdx-1)*12 + 1;
                                                end_month = yrIdx*12;
                                                % Only calculate if we have data for this year
                                                year_data = monthly_data(start_month:end_month);
                                                if any(~isnan(year_data))
                                                    Hp_REC_annual(datasetIdx,yrIdx) = mean(year_data, 'omitnan');
                                                end
                                            end
                                        end

                                        REC = [
                                            min(Hp_REC_annual, [], 1,'omitnan');
                                            max(Hp_REC_annual, [], 1,'omitnan');
                                            mean(Hp_REC_annual, 1,'omitnan')
                                            ];

                                        %% PALAZZOLI (4 datasets)
                                    case 'p25'
                                        Pl_REC = NaN(4,1500);
                                        Pl_REC(1,[app.PalazzoliLSTMMN])        = 10*mean(applyBasinMask(app, app.PalazzoliLSTMData, app.PalazzoliLSTMLat, app.PalazzoliLSTMLon),1);
                                        Pl_REC(2,[app.PalazzoliLSTMnoLCSIFMN]) = 10*mean(applyBasinMask(app, app.PalazzoliLSTMnoLCSIFData, app.PalazzoliLSTMnoLCSIFLat, app.PalazzoliLSTMnoLCSIFLon),1);
                                        Pl_REC(3,[app.PalazzoliBiLSTMMN])      = 10*mean(applyBasinMask(app, app.PalazzoliBiLSTMData, app.PalazzoliBiLSTMLat, app.PalazzoliBiLSTMLon),1);
                                        Pl_REC(4,[app.PalazzoliBiLSTMnoLCSIFMN]) = 10*mean(applyBasinMask(app, app.PalazzoliBiLSTMnoLCSIFData, app.PalazzoliBiLSTMnoLCSIFLat, app.PalazzoliBiLSTMnoLCSIFLon),1);

                                        % Convert monthly to annual mean - handle partial years
                                        Pl_REC_annual = NaN(4,125);
                                        for datasetIdx = 1:4
                                            monthly_data = Pl_REC(datasetIdx,:);
                                            for yrIdx = 1:125
                                                start_month = (yrIdx-1)*12 + 1;
                                                end_month = yrIdx*12;
                                                % Only calculate if we have data for this year
                                                year_data = monthly_data(start_month:end_month);
                                                if any(~isnan(year_data))
                                                    Pl_REC_annual(datasetIdx,yrIdx) = mean(year_data, 'omitnan');
                                                end
                                            end
                                        end

                                        REC = [
                                            min(Pl_REC_annual, [], 1,'omitnan');
                                            max(Pl_REC_annual, [], 1,'omitnan');
                                            mean(Pl_REC_annual, 1,'omitnan')
                                            ];

                                        %% LI (single)
                                    case 'l21'
                                        Li_BA = 10*mean(applyBasinMask(app, app.LiRECData, app.LiRECLat, app.LiRECLon),1);
                                        Li_REC = NaN(1,1500);
                                        Li_REC(1,[app.LiRECMN]) = Li_BA;

                                        % Convert monthly to annual mean - handle partial years
                                        Li_REC_annual = NaN(1,125);
                                        monthly_data = Li_REC(1,:);
                                        for yrIdx = 1:125
                                            start_month = (yrIdx-1)*12 + 1;
                                            end_month = yrIdx*12;
                                            % Only calculate if we have data for this year
                                            year_data = monthly_data(start_month:end_month);
                                            if any(~isnan(year_data))
                                                Li_REC_annual(1,yrIdx) = mean(year_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(Li_REC_annual,3,1);

                                        %% DENG (single)
                                    case 'd23'
                                        Deng_BA = mean(applyBasinMask(app, app.DengRECData, app.DengRECLat, app.DengRECLon),1);
                                        Deng_REC = NaN(1,1500);
                                        Deng_REC(1,[app.DengRECMN]) = Deng_BA;

                                        % Convert monthly to annual mean - handle partial years
                                        Deng_REC_annual = NaN(1,125);
                                        monthly_data = Deng_REC(1,:);
                                        for yrIdx = 1:125
                                            start_month = (yrIdx-1)*12 + 1;
                                            end_month = yrIdx*12;
                                            % Only calculate if we have data for this year
                                            year_data = monthly_data(start_month:end_month);
                                            if any(~isnan(year_data))
                                                Deng_REC_annual(1,yrIdx) = mean(year_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(Deng_REC_annual,3,1);

                                        %% MANDAL (single)
                                    case 'm25'
                                        Mandal_BA = mean(applyBasinMask(app, app.MandalRECData, app.MandalRECLat, app.MandalRECLon),1);
                                        Mandal_REC = NaN(1,1500);
                                        Mandal_REC(1,[app.MandalRECMN]) = Mandal_BA;

                                        % Convert monthly to annual mean - handle partial years
                                        Mandal_REC_annual = NaN(1,125);
                                        monthly_data = Mandal_REC(1,:);
                                        for yrIdx = 1:125
                                            start_month = (yrIdx-1)*12 + 1;
                                            end_month = yrIdx*12;
                                            % Only calculate if we have data for this year
                                            year_data = monthly_data(start_month:end_month);
                                            if any(~isnan(year_data))
                                                Mandal_REC_annual(1,yrIdx) = mean(year_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(Mandal_REC_annual,3,1);
                                end

                                % Pick color safely
                                if isfield(colors,nodeKey)
                                    c = colors.(nodeKey);
                                else
                                    c = [0.5 0.5 0.5];
                                end

                                % Fill band (flat since single dataset)
                                hold(app.UIAxes, 'on');

                                if strcmp(nodeKey, 'hg19') || strcmp(nodeKey, 'p25')
                                    % Plot filled area
                                    fill(app.UIAxes, [x fliplr(x)], [REC(2, x) fliplr(REC(1, x))],c, 'FaceAlpha', 0.2, 'EdgeColor', 'none','DisplayName', strcat(rawName," Range"));
                                end

                                % Plot main line
                                plot(app.UIAxes, x, REC(3, x), 'Color', c, 'LineWidth',1.5,'LineStyle','--','DisplayName', strcat(rawName));

                            end

                            % Get selected GRACE datasets
                            selectedNodes = app.TWSA.CheckedNodes;
                            hold(app.UIAxes,'on');
                            % Colors for GRACE datasets (normalized keys)
                            colors = struct( ...
                                'jpl',  [0.2 0.2 0.2], ...  % dark gray
                                'csr',  [0.5 0.5 0.5], ...  % medium gray
                                'gsfc', [0.8 0.8 0.8]);     % light gray
                            markers= struct( ...
                                'jpl',  "o", ...  % dark gray
                                'csr',  "+", ...  % medium gray
                                'gsfc', '*' );     % light gray

                            for i = 1:numel(selectedNodes)
                                % Skip non-leaf nodes
                                if ~isempty(selectedNodes(i).Children), continue; end

                                rawName = strtrim(selectedNodes(i).Text);  % remove spaces
                                nodeKey = lower(rawName);
                                REC = [];
                                switch nodeKey
                                    case 'jpl'
                                        JPL_BA = 10*mean(applyBasinMask(app, app.JPLTWSData, app.JPLTWSLat, app.JPLTWSLon),1);
                                        JPL_TWSA = NaN(1,1500);
                                        JPL_TWSA(1,[app.JPLTWSMN]) = JPL_BA;
                                        % Convert monthly to annual mean - handle partial years
                                        JPL_annual = NaN(1,125);
                                        for yrIdx = 1:125
                                            start_month = (yrIdx-1)*12 + 1;
                                            end_month = yrIdx*12;
                                            % Only calculate if we have data for this year
                                            year_data = JPL_TWSA(start_month:end_month);
                                            if any(~isnan(year_data))
                                                JPL_annual(1,yrIdx) = mean(year_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(JPL_annual,3,1);

                                    case 'csr'
                                        CSR_BA = 10*mean(applyBasinMask(app, app.CSRTWSData, app.CSRTWSLat, app.CSRTWSLon),1);
                                        CSR_TWSA = NaN(1,1500);
                                        CSR_TWSA(1,[app.CSRTWSMN]) = CSR_BA;
                                        % Convert monthly to annual mean - handle partial years
                                        CSR_annual = NaN(1,125);
                                        for yrIdx = 1:125
                                            start_month = (yrIdx-1)*12 + 1;
                                            end_month = yrIdx*12;
                                            % Only calculate if we have data for this year
                                            year_data = CSR_TWSA(start_month:end_month);
                                            if any(~isnan(year_data))
                                                CSR_annual(1,yrIdx) = mean(year_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(CSR_annual,3,1);

                                    case 'gsfc'
                                        GSFC_BA = 10*mean(applyBasinMask(app, app.GFSCTWSData, app.GFSCTWSLat, app.GFSCTWSLon),1);
                                        GSFC_TWSA = NaN(1,1500);
                                        GSFC_TWSA(1,[app.GFSCTWSMN]) = GSFC_BA;
                                        % Convert monthly to annual mean - handle partial years
                                        GSFC_annual = NaN(1,125);
                                        for yrIdx = 1:125
                                            start_month = (yrIdx-1)*12 + 1;
                                            end_month = yrIdx*12;
                                            % Only calculate if we have data for this year
                                            year_data = GSFC_TWSA(start_month:end_month);
                                            if any(~isnan(year_data))
                                                GSFC_annual(1,yrIdx) = mean(year_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(GSFC_annual,3,1);

                                    otherwise
                                        disp(['[TWSA] Skipping unhandled node: "', rawName, '"']);
                                        continue;
                                end

                                if isempty(REC), continue; end
                                eIdx_plot = min(eIdx, size(REC,2));
                                x_plot = sIdx:eIdx_plot;

                                % Choose dataset color (fallback if missing)
                                if isfield(colors, nodeKey)
                                    c = colors.(nodeKey);
                                else
                                    c = [0.5 0.5 0.5];
                                end

                                if isfield(markers, nodeKey)
                                    d = markers.(nodeKey);
                                else
                                    d = 'square';
                                end

                                plot(app.UIAxes, x_plot, REC(3,x_plot), 'Color', c, 'LineWidth', 2,'Marker',d, 'DisplayName', strcat(upper(nodeKey)));
                            end

                            %% ==================== THIS STUDY TREE ====================
                            selectedNodes = app.This_Study.CheckedNodes;
                            hold(app.UIAxes,'on');
                            % Colors for each of your models
                            colors = struct( ...
                                'rf_imd',     [0.0 0.45 0.70], ...   % strong blue
                                'ann_g',      [0.85 0.33 0.10], ...  % bright orange
                                'ann_imd',     [0.93 0.69 0.13], ...  % yellow
                                'rf_g',       [0.49 0.18 0.56]);     % purple

                            for i = 1:numel(selectedNodes)
                                % Skip parent nodes
                                if ~isempty(selectedNodes(i).Children), continue; end

                                rawName = strtrim(selectedNodes(i).Text); % "Best", "ANN", etc.
                                nodeKey = lower(rawName);                 % normalize to lowercase

                                REC = [];
                                switch nodeKey
                                    %% BEST
                                    case 'rf_imd'
                                        Best_BA = mean(applyBasinMask(app, app.ThisStudyBestData, ...
                                            app.ThisStudyBestLat, app.ThisStudyBestLon),1);
                                        Best_REC = NaN(1,1500);
                                        Best_REC(1,[app.ThisStudyBestMN]) = Best_BA;
                                        % Convert monthly to annual mean - handle partial years
                                        Best_annual = NaN(1,125);
                                        monthly_data = Best_REC(1,:);
                                        for yrIdx = 1:125
                                            start_month = (yrIdx-1)*12 + 1;
                                            end_month = yrIdx*12;
                                            % Only calculate if we have data for this year
                                            year_data = monthly_data(start_month:end_month);
                                            if any(~isnan(year_data))
                                                Best_annual(1,yrIdx) = mean(year_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(Best_annual,3,1);

                                        %% ANN
                                    case 'ann_g'
                                        ANN_BA = mean(applyBasinMask(app, app.ThisStudyANNData, ...
                                            app.ThisStudyANNLat, app.ThisStudyANNLon),1);
                                        ANN_REC = NaN(1,1500);
                                        ANN_REC(1,[app.ThisStudyANNMN]) = ANN_BA;
                                        % Convert monthly to annual mean - handle partial years
                                        ANN_annual = NaN(1,125);
                                        monthly_data = ANN_REC(1,:);
                                        for yrIdx = 1:125
                                            start_month = (yrIdx-1)*12 + 1;
                                            end_month = yrIdx*12;
                                            % Only calculate if we have data for this year
                                            year_data = monthly_data(start_month:end_month);
                                            if any(~isnan(year_data))
                                                ANN_annual(1,yrIdx) = mean(year_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(ANN_annual,3,1);

                                        %% LSTM
                                    case 'ann_imd'
                                        LSTM_BA = mean(applyBasinMask(app, app.ThisStudyLSTMData, ...
                                            app.ThisStudyLSTMLat, app.ThisStudyLSTMLon),1);
                                        LSTM_REC = NaN(1,1500);
                                        LSTM_REC(1,[app.ThisStudyLSTMMN]) = LSTM_BA;
                                        % Convert monthly to annual mean - handle partial years
                                        LSTM_annual = NaN(1,125);
                                        monthly_data = LSTM_REC(1,:);
                                        for yrIdx = 1:125
                                            start_month = (yrIdx-1)*12 + 1;
                                            end_month = yrIdx*12;
                                            % Only calculate if we have data for this year
                                            year_data = monthly_data(start_month:end_month);
                                            if any(~isnan(year_data))
                                                LSTM_annual(1,yrIdx) = mean(year_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(LSTM_annual,3,1);

                                        %% RF
                                    case 'rf_g'
                                        RF_BA = mean(applyBasinMask(app, app.ThisStudyRFData, ...
                                            app.ThisStudyRFLat, app.ThisStudyRFLon),1);
                                        RF_REC = NaN(1,1500);
                                        RF_REC(1,[app.ThisStudyRFMN]) = RF_BA;
                                        % Convert monthly to annual mean - handle partial years
                                        RF_annual = NaN(1,125);
                                        monthly_data = RF_REC(1,:);
                                        for yrIdx = 1:125
                                            start_month = (yrIdx-1)*12 + 1;
                                            end_month = yrIdx*12;
                                            % Only calculate if we have data for this year
                                            year_data = monthly_data(start_month:end_month);
                                            if any(~isnan(year_data))
                                                RF_annual(1,yrIdx) = mean(year_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(RF_annual,3,1);
                                end

                                if isempty(REC), continue; end
                                % Pick dataset color safely
                                if isfield(colors,nodeKey)
                                    c = colors.(nodeKey);
                                else
                                    c = [0.5 0.5 0.5]; % fallback gray
                                end

                                hold(app.UIAxes,'on');

                                % Mean line
                                plot(app.UIAxes, x, REC(3,x), 'Color', c, 'LineWidth',1.5,'DisplayName', strcat(rawName));

                            end

                            % Axes settings
                            grid(app.UIAxes,'on');
                            app.UIAxes.FontName = 'Times New Roman';
                            app.UIAxes.FontSize = 14;
                            app.UIAxes.XLabel.String = 'Time (Years)';
                            app.UIAxes.XLabel.FontName = 'Times New Roman';
                            app.UIAxes.XLabel.FontWeight = 'bold';
                            app.UIAxes.XLabel.FontSize = 18;
                            app.UIAxes.YLabel.String = '(R)TWSA (mm)';   % left axis label
                            app.UIAxes.YLabel.FontName = 'Times New Roman';
                            app.UIAxes.YLabel.FontWeight = 'bold';
                            app.UIAxes.YLabel.FontSize = 18;

                            hold(app.UIAxes,'off');

                            %% ==================== PRECIPITATION (inverted, on right axis, with gap to TWS) ====================
                            selectedNodes = app.Precipitation.CheckedNodes;
                            yyaxis(app.UIAxes,'right');
                            yl = ylabel(app.UIAxes,'Precipitation (mm)');  % get handle
                            yl.FontSize = 18;
                            yl.FontName = 'Times New Roman';
                            yl.FontWeight = 'bold';
                            set(app.UIAxes,'YDir','reverse');  % invert the axis so bars grow downward

                            precipData = []; precipLabels = {};
                            for i = 1:numel(selectedNodes)
                                if ~isempty(selectedNodes(i).Children), continue; end
                                rawName = strtrim(selectedNodes(i).Text);
                                nodeKey = lower(rawName);
                                clear data

                                switch nodeKey
                                    case 'imd'
                                        % IMD (already in mm monthly) - convert to annual sum
                                        app.IMD_BA = mean(applyBasinMask(app, app.IMDData, app.IMDLat, app.IMDLon),1);
                                        data_monthly = NaN(1,1500); data_monthly(1,app.IMDMN) = app.IMD_BA;
                                        % Convert to annual sum - handle partial years
                                        data = NaN(1,125);
                                        for yrIdx = 1:125
                                            start_month = (yrIdx-1)*12 + 1;
                                            end_month = yrIdx*12;
                                            % Only calculate if we have data for this year
                                            year_data = data_monthly(1,start_month:end_month);
                                            if any(~isnan(year_data))
                                                data(1,yrIdx) = sum(year_data, 'omitnan');
                                            end
                                        end

                                    case 'gpcp'
                                        % GPCP (mm/month) - convert to annual sum
                                        app.GPCP_BA = mean(applyBasinMask(app, app.GPCPData, app.GPCPLat, app.GPCPLon),1);
                                        data_monthly = NaN(1,1500); data_monthly(1,app.GPCPMN) = app.GPCP_BA;
                                        % Convert to annual sum - handle partial years
                                        data = NaN(1,125);
                                        for yrIdx = 1:125
                                            start_month = (yrIdx-1)*12 + 1;
                                            end_month = yrIdx*12;
                                            % Only calculate if we have data for this year
                                            year_data = data_monthly(1,start_month:end_month);
                                            if any(~isnan(year_data))
                                                data(1,yrIdx) = sum(year_data, 'omitnan');
                                            end
                                        end

                                    case 'era5'
                                        % ERA5 'tp' is meters; convert to mm and then annual sum
                                        app.ERA5_BA = 1000*mean(applyBasinMask(app, app.ERA5Data, app.ERA5Lat, app.ERA5Lon),1);
                                        data_monthly = NaN(1,1500); data_monthly(1,app.ERA5MN) = app.ERA5_BA;
                                        % Convert to annual sum - handle partial years
                                        data = NaN(1,125);
                                        for yrIdx = 1:125
                                            start_month = (yrIdx-1)*12 + 1;
                                            end_month = yrIdx*12;
                                            % Only calculate if we have data for this year
                                            year_data = data_monthly(1,start_month:end_month);
                                            if any(~isnan(year_data))
                                                data(1,yrIdx) = sum(year_data, 'omitnan');
                                            end
                                        end
                                end

                                if exist('data','var')
                                    precipData   = [precipData; data];    %#ok<AGROW>
                                    precipLabels = [precipLabels; nodeKey]; %#ok<AGROW>
                                end
                            end

                            if ~isempty(precipData)
                                % What's selected?
                                nSel      = size(precipData,1);
                                hasIMD    = any(strcmpi(precipLabels,'imd'));
                                % Stats in window
                                p_min  = min(precipData(:,x),[],1,'omitnan');
                                p_max  = max(precipData(:,x),[],1,'omitnan');
                                p_mean = mean(precipData(:,x),1,'omitnan');
                                Pmax   = max(p_max,[],'omitnan');

                                % ---- Plot according to selection rules ----
                                if nSel == 1
                                    % Only one dataset selected
                                    ydata = precipData(1,x);
                                    if strcmpi(precipLabels{1},'imd')
                                        hold(app.UIAxes,'on');
                                        % IMD as open circles (inverted)
                                        bar(app.UIAxes, x, ydata, 0.4, 'FaceColor','none','EdgeColor',[0.2 0.7 0.9],'LineWidth',1.2, 'DisplayName','IMD Precip');
                                        plot(app.UIAxes, x, ydata, 'o', 'Color','k', 'MarkerFaceColor','w','MarkerSize',4,'DisplayName','IMD Precip');
                                    elseif strcmpi(precipLabels{1},'gpcp')
                                        bar(app.UIAxes, x, ydata, 0.4, 'FaceColor','none','EdgeColor',[0.2 0.7 0.9],'LineWidth',1.2, 'DisplayName','GPCP Precip');
                                    else % ERA5
                                        bar(app.UIAxes, x, ydata, 0.4, 'FaceColor','none','EdgeColor',[0.2 0.7 0.9],'LineWidth',1.2, 'DisplayName','ERA5 Precip');
                                    end
                                elseif nSel == 2
                                    % Multiple selected
                                    hold(app.UIAxes,'on');
                                    bar(app.UIAxes, x, p_mean, 0.45, 'FaceColor','none','EdgeColor',[0.2 0.7 0.9],'LineWidth',1.2, 'DisplayName','Mean Precip');
                                    % Whiskers (min-max) behind mean
                                    legendAdded = false;

                                    for k = 1:numel(x)
                                        if ~legendAdded
                                            line(app.UIAxes, [x(k) x(k)], [p_max(k) p_min(k)],'Color',[0.35 0.35 0.35], 'LineWidth',1.0,'LineStyle','-', 'Marker','none', 'DisplayName','Precip Range');
                                            legendAdded = true;
                                        else
                                            line(app.UIAxes, [x(k) x(k)], [p_max(k) p_min(k)],'Color',[0.35 0.35 0.35], 'LineWidth',1.0,'LineStyle','-', 'Marker','none', 'HandleVisibility','off');
                                        end
                                    end

                                    if hasIMD
                                        j = find(strcmpi(precipLabels,'imd'),1);
                                        plot(app.UIAxes, x, precipData(j,x), 'o', 'Color','k', 'MarkerFaceColor','w','MarkerSize',4,'DisplayName','IMD Precip');
                                    end
                                else
                                    hold(app.UIAxes,'on');
                                    bar(app.UIAxes, x, p_mean, 0.45, 'FaceColor','none','EdgeColor',[0.2 0.7 0.9],'LineWidth',1.2, 'DisplayName','Mean Precip');
                                    j = find(strcmpi(precipLabels,'imd'),1);
                                    plot(app.UIAxes, x, precipData(j,x), 'o', 'Color','k', 'MarkerFaceColor','w','MarkerSize',4,'DisplayName','IMD Precip');
                                    legendAdded = false;

                                    for k = 1:numel(x)
                                        if ~legendAdded
                                            line(app.UIAxes, [x(k) x(k)], [p_max(k) p_min(k)],'Color',[0.35 0.35 0.35], 'LineWidth',1.0,'LineStyle','-', 'Marker','none', 'DisplayName','Precip Range');
                                            legendAdded = true;
                                        else
                                            line(app.UIAxes, [x(k) x(k)], [p_max(k) p_min(k)],'Color',[0.35 0.35 0.35], 'LineWidth',1.0,'LineStyle','-', 'Marker','none', 'HandleVisibility','off');
                                        end
                                    end
                                end

                                % ---------- Dynamic Axis coordination (TWSA + Precip Gap) ----------
                                yyaxis(app.UIAxes,'left');

                                % Collect ALL TWSA data from plotted series in the selected window
                                allTWSA = [];
                                h = findall(app.UIAxes,'Type','Line'); % get plotted lines
                                for k = 1:numel(h)
                                    ydata = h(k).YData;
                                    xdata = h(k).XData;
                                    % only keep values within the sIdx:eIdx window
                                    mask = (xdata >= sIdx & xdata <= eIdx);
                                    if any(mask)
                                        allTWSA = [allTWSA, ydata(mask)];
                                    end
                                end

                                if ~isempty(allTWSA)
                                    % Dynamic limits based on selected time window
                                    twsMin = min(allTWSA, [], 'omitnan');
                                    twsMax = max(allTWSA, [], 'omitnan');
                                    disp(twsMax)
                                    % Add padding for readability
                                    %pad = 0.15 * (twsMax - twsMin);
                                    twsLimits = [twsMin , twsMax];% + pad];


                                    % Apply limits to left axis
                                    ylim(app.UIAxes, twsLimits);

                                    % Dynamic ticks
                                    step = round((twsMax - twsMin) / 5);
                                    if step == 0, step = 1; end
                                    app.UIAxes.YTick = round(twsMin):step:round(twsMax);

                                    % -------- Right axis (precipitation, inverted, with gap) --------
                                    yyaxis(app.UIAxes,'right');
                                    Pmax = max(p_max,[],'omitnan');
                                    gap  = 1.2 * (twsLimits(2) - twsLimits(1)); % proportional gap
                                    ylim(app.UIAxes, [0 Pmax + gap]);
                                    yticks(app.UIAxes, 0:round(Pmax/5):Pmax);
                                end
                            end
                            % Ensure grid and axis font
                            grid(app.UIAxes, 'on');
                            app.UIAxes.FontName = 'Times New Roman';
                            app.UIAxes.FontSize = 18* scale;;

                            % Axis labels
                            app.UIAxes.XLabel.String = 'Time (Years)';
                            app.UIAxes.XLabel.FontName = 'Times New Roman';
                            app.UIAxes.XLabel.FontWeight = 'bold';
                            app.UIAxes.XLabel.FontSize = 18* scale;;
                            % Create legend AFTER plotting
                            lg = legend(app.UIAxes, 'show');
                            % Legend configuration
                            % if exist('newWidth','var') && ~isempty(newWidth)
                            %     lg.NumColumns = min(9, floor(newWidth/150));
                            % else
                            lg.NumColumns = 9; % fallback
                            % end
                            lg.Location    = 'southoutside';
                            lg.Orientation = 'horizontal';
                            lg.Box         = 'on';
                            lg.Interpreter = 'none';
                            lg.AutoUpdate  = 'off';
                            lg.FontName    = 'Times New Roman';
                            lg.FontWeight  = 'bold';

                            if exist('scale','var') && ~isempty(scale)
                                lg.FontSize = 10* scale;
                            else
                                lg.FontSize = 12; % fallback
                            end

                            hold(app.UIAxes, 'off');
                        case 'Decadal'
                            cla(app.UIAxes, 'reset');
                            hold(app.UIAxes,'on'); % clear axes before plotting anything
                            % Define the starting and ending years for the slider scale
                            startYr = 1901;
                            endYr = 2025;
                            allYrs = startYr:endYr;
                            % Get selected time range from slider
                            sIdx = round(app.TimeSpan19012025Slider.Value(1));
                            eIdx = round(app.TimeSpan19012025Slider.Value(2));
                            sIdx = max(sIdx,1);
                            eIdx = min(eIdx, numel(allYrs));
                            selectedTimeRange = allYrs(sIdx:eIdx);

                            % Calculate decadal bins for the selected time range
                            tStart = selectedTimeRange(1);
                            tEnd = selectedTimeRange(end);

                            % Create decade bins (1901-1910, 1911-1920, etc.)
                            decadeStarts = floor(tStart/10)*10+1:10:floor(tEnd/10)*10+1;
                            if isempty(decadeStarts)
                                decadeStarts = tStart;
                            end

                            % Calculate decade centers for plotting
                            decadeCenters = decadeStarts + 4.5; % Middle of the decade
                            x = 1:numel(decadeStarts);

                            % Apply ticks and labels
                            app.UIAxes.XTick = x;
                            decadeLabels = cell(1, numel(decadeStarts));
                            for i = 1:numel(decadeStarts)
                                decadeEnd = min(decadeStarts(i) + 9, tEnd);
                                decadeLabels{i} = sprintf('%d-%d', decadeStarts(i), decadeEnd);
                            end
                            app.UIAxes.XTickLabel = decadeLabels;

                            % Set axis limits
                            xlim(app.UIAxes, [0.5 numel(decadeStarts)+0.5]);

                            timescales = app.TimescaleDropDown.Value;
                            legendItems = {};

                            %% ==================== RECONSTRUCTED TREE ====================
                            selectedNodes = app.RTWSA.CheckedNodes;
                            % Colors for different reconstructions (normalized keys)
                            colors = struct('hg19', [0.0 0.60 0.50], ...   % teal
                                'p25',[0.95 0.60 0.20], ...  % golden orange
                                'l21',       [0.35 0.70 0.90], ...  % light blue
                                'd23',     [0.90 0.10 0.15], ...  % red
                                'm25',   [0.60 0.40 0.20]);     % brown

                            for i = 1:numel(selectedNodes)
                                % Skip parent nodes
                                if ~isempty(selectedNodes(i).Children), continue; end

                                rawName = strtrim(selectedNodes(i).Text); % clean up
                                nodeKey = lower(rawName); % normalize to lowercase

                                REC = [];
                                switch nodeKey
                                    %% HUMPHREY (6 datasets)
                                    case 'hg19'
                                        Hp_REC = NaN(6,1500);
                                        Hp_REC(1,[app.Hp_GERECMN]) = mean(applyBasinMask(app, app.Hp_GERECData, app.Hp_GERECLat, app.Hp_GERECLon),1);
                                        Hp_REC(2,[app.Hp_GGRECMN]) = mean(applyBasinMask(app, app.Hp_GGRECData, app.Hp_GGRECLat, app.Hp_GGRECLon),1);
                                        Hp_REC(3,[app.Hp_GMRECMN]) = mean(applyBasinMask(app, app.Hp_GMRECData, app.Hp_GMRECLat, app.Hp_GMRECLon),1);
                                        Hp_REC(4,[app.Hp_JERECMN]) = mean(applyBasinMask(app, app.Hp_JERECData, app.Hp_JERECLat, app.Hp_JERECLon),1);
                                        Hp_REC(5,[app.Hp_JGRECMN]) = mean(applyBasinMask(app, app.Hp_JGRECData, app.Hp_JGRECLat, app.Hp_JGRECLon),1);
                                        Hp_REC(6,[app.Hp_JMRECMN]) = mean(applyBasinMask(app, app.Hp_JMRECData, app.Hp_JMRECLat, app.Hp_JMRECLon),1);

                                        % Convert monthly to decadal mean
                                        Hp_REC_decadal = NaN(6, numel(decadeStarts));
                                        for datasetIdx = 1:6
                                            monthly_data = Hp_REC(datasetIdx,:);
                                            for decadeIdx = 1:numel(decadeStarts)
                                                startYear = decadeStarts(decadeIdx);
                                                endYear = min(startYear + 9, tEnd);
                                                % Convert years to month indices
                                                startMonth = (startYear - startYr) * 12 + 1;
                                                endMonth = (endYear - startYr + 1) * 12;
                                                % Ensure we don't exceed data bounds
                                                startMonth = max(startMonth, 1);
                                                endMonth = min(endMonth, length(monthly_data));

                                                decade_data = monthly_data(startMonth:endMonth);
                                                if any(~isnan(decade_data))
                                                    Hp_REC_decadal(datasetIdx,decadeIdx) = mean(decade_data, 'omitnan');
                                                end
                                            end
                                        end

                                        REC = [
                                            min(Hp_REC_decadal, [], 1,'omitnan');
                                            max(Hp_REC_decadal, [], 1,'omitnan');
                                            mean(Hp_REC_decadal, 1,'omitnan')
                                            ];

                                        %% PALAZZOLI (4 datasets)
                                    case 'p25'
                                        Pl_REC = NaN(4,1500);
                                        Pl_REC(1,[app.PalazzoliLSTMMN])        = 10*mean(applyBasinMask(app, app.PalazzoliLSTMData, app.PalazzoliLSTMLat, app.PalazzoliLSTMLon),1);
                                        Pl_REC(2,[app.PalazzoliLSTMnoLCSIFMN]) = 10*mean(applyBasinMask(app, app.PalazzoliLSTMnoLCSIFData, app.PalazzoliLSTMnoLCSIFLat, app.PalazzoliLSTMnoLCSIFLon),1);
                                        Pl_REC(3,[app.PalazzoliBiLSTMMN])      = 10*mean(applyBasinMask(app, app.PalazzoliBiLSTMData, app.PalazzoliBiLSTMLat, app.PalazzoliBiLSTMLon),1);
                                        Pl_REC(4,[app.PalazzoliBiLSTMnoLCSIFMN]) = 10*mean(applyBasinMask(app, app.PalazzoliBiLSTMnoLCSIFData, app.PalazzoliBiLSTMnoLCSIFLat, app.PalazzoliBiLSTMnoLCSIFLon),1);

                                        % Convert monthly to decadal mean
                                        Pl_REC_decadal = NaN(4, numel(decadeStarts));
                                        for datasetIdx = 1:4
                                            monthly_data = Pl_REC(datasetIdx,:);
                                            for decadeIdx = 1:numel(decadeStarts)
                                                startYear = decadeStarts(decadeIdx);
                                                endYear = min(startYear + 9, tEnd);
                                                % Convert years to month indices
                                                startMonth = (startYear - startYr) * 12 + 1;
                                                endMonth = (endYear - startYr + 1) * 12;
                                                % Ensure we don't exceed data bounds
                                                startMonth = max(startMonth, 1);
                                                endMonth = min(endMonth, length(monthly_data));

                                                decade_data = monthly_data(startMonth:endMonth);
                                                if any(~isnan(decade_data))
                                                    Pl_REC_decadal(datasetIdx,decadeIdx) = mean(decade_data, 'omitnan');
                                                end
                                            end
                                        end

                                        REC = [
                                            min(Pl_REC_decadal, [], 1,'omitnan');
                                            max(Pl_REC_decadal, [], 1,'omitnan');
                                            mean(Pl_REC_decadal, 1,'omitnan')
                                            ];

                                        %% LI (single)
                                    case 'l21'
                                        Li_BA = 10*mean(applyBasinMask(app, app.LiRECData, app.LiRECLat, app.LiRECLon),1);
                                        Li_REC = NaN(1,1500);
                                        Li_REC(1,[app.LiRECMN]) = Li_BA;

                                        % Convert monthly to decadal mean
                                        Li_REC_decadal = NaN(1, numel(decadeStarts));
                                        monthly_data = Li_REC(1,:);
                                        for decadeIdx = 1:numel(decadeStarts)
                                            startYear = decadeStarts(decadeIdx);
                                            endYear = min(startYear + 9, tEnd);
                                            % Convert years to month indices
                                            startMonth = (startYear - startYr) * 12 + 1;
                                            endMonth = (endYear - startYr + 1) * 12;
                                            % Ensure we don't exceed data bounds
                                            startMonth = max(startMonth, 1);
                                            endMonth = min(endMonth, length(monthly_data));

                                            decade_data = monthly_data(startMonth:endMonth);
                                            if any(~isnan(decade_data))
                                                Li_REC_decadal(1,decadeIdx) = mean(decade_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(Li_REC_decadal,3,1);

                                        %% DENG (single)
                                    case 'd23'
                                        Deng_BA = mean(applyBasinMask(app, app.DengRECData, app.DengRECLat, app.DengRECLon),1);
                                        Deng_REC = NaN(1,1500);
                                        Deng_REC(1,[app.DengRECMN]) = Deng_BA;

                                        % Convert monthly to decadal mean
                                        Deng_REC_decadal = NaN(1, numel(decadeStarts));
                                        monthly_data = Deng_REC(1,:);
                                        for decadeIdx = 1:numel(decadeStarts)
                                            startYear = decadeStarts(decadeIdx);
                                            endYear = min(startYear + 9, tEnd);
                                            % Convert years to month indices
                                            startMonth = (startYear - startYr) * 12 + 1;
                                            endMonth = (endYear - startYr + 1) * 12;
                                            % Ensure we don't exceed data bounds
                                            startMonth = max(startMonth, 1);
                                            endMonth = min(endMonth, length(monthly_data));

                                            decade_data = monthly_data(startMonth:endMonth);
                                            if any(~isnan(decade_data))
                                                Deng_REC_decadal(1,decadeIdx) = mean(decade_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(Deng_REC_decadal,3,1);

                                        %% MANDAL (single)
                                    case 'm25'
                                        Mandal_BA = mean(applyBasinMask(app, app.MandalRECData, app.MandalRECLat, app.MandalRECLon),1);
                                        Mandal_REC = NaN(1,1500);
                                        Mandal_REC(1,[app.MandalRECMN]) = Mandal_BA;

                                        % Convert monthly to decadal mean
                                        Mandal_REC_decadal = NaN(1, numel(decadeStarts));
                                        monthly_data = Mandal_REC(1,:);
                                        for decadeIdx = 1:numel(decadeStarts)
                                            startYear = decadeStarts(decadeIdx);
                                            endYear = min(startYear + 9, tEnd);
                                            % Convert years to month indices
                                            startMonth = (startYear - startYr) * 12 + 1;
                                            endMonth = (endYear - startYr + 1) * 12;
                                            % Ensure we don't exceed data bounds
                                            startMonth = max(startMonth, 1);
                                            endMonth = min(endMonth, length(monthly_data));

                                            decade_data = monthly_data(startMonth:endMonth);
                                            if any(~isnan(decade_data))
                                                Mandal_REC_decadal(1,decadeIdx) = mean(decade_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(Mandal_REC_decadal,3,1);
                                end

                                % Pick color safely
                                if isfield(colors,nodeKey)
                                    c = colors.(nodeKey);
                                else
                                    c = [0.5 0.5 0.5];
                                end

                                % Fill band (flat since single dataset)
                                hold(app.UIAxes, 'on');

                                if strcmp(nodeKey, 'hg19') || strcmp(nodeKey, 'p25')
                                    % Plot filled area
                                    fill(app.UIAxes, [x fliplr(x)], [REC(2, x) fliplr(REC(1, x))],c, 'FaceAlpha', 0.2, 'EdgeColor', 'none','DisplayName', strcat(rawName," Range"));
                                end

                                % Plot main line
                                plot(app.UIAxes, x, REC(3, x), 'Color', c, 'LineWidth',1.5,'LineStyle','--','DisplayName', strcat(rawName));

                            end

                            % Get selected GRACE datasets
                            selectedNodes = app.TWSA.CheckedNodes;
                            hold(app.UIAxes,'on');
                            % Colors for GRACE datasets (normalized keys)
                            colors = struct( ...
                                'jpl',  [0.2 0.2 0.2], ...  % dark gray
                                'csr',  [0.5 0.5 0.5], ...  % medium gray
                                'gsfc', [0.8 0.8 0.8]);     % light gray
                            markers= struct( ...
                                'jpl',  "o", ...  % dark gray
                                'csr',  "+", ...  % medium gray
                                'gsfc', '*' );     % light gray

                            for i = 1:numel(selectedNodes)
                                % Skip non-leaf nodes
                                if ~isempty(selectedNodes(i).Children), continue; end

                                rawName = strtrim(selectedNodes(i).Text);  % remove spaces
                                nodeKey = lower(rawName);
                                REC = [];
                                switch nodeKey
                                    case 'jpl'
                                        JPL_BA = 10*mean(applyBasinMask(app, app.JPLTWSData, app.JPLTWSLat, app.JPLTWSLon),1);
                                        JPL_TWSA = NaN(1,1500);
                                        JPL_TWSA(1,[app.JPLTWSMN]) = JPL_BA;
                                        % Convert monthly to decadal mean
                                        JPL_decadal = NaN(1, numel(decadeStarts));
                                        monthly_data = JPL_TWSA(1,:);
                                        for decadeIdx = 1:numel(decadeStarts)
                                            startYear = decadeStarts(decadeIdx);
                                            endYear = min(startYear + 9, tEnd);
                                            % Convert years to month indices
                                            startMonth = (startYear - startYr) * 12 + 1;
                                            endMonth = (endYear - startYr + 1) * 12;
                                            % Ensure we don't exceed data bounds
                                            startMonth = max(startMonth, 1);
                                            endMonth = min(endMonth, length(monthly_data));

                                            decade_data = monthly_data(startMonth:endMonth);
                                            if any(~isnan(decade_data))
                                                JPL_decadal(1,decadeIdx) = mean(decade_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(JPL_decadal,3,1);

                                    case 'csr'
                                        CSR_BA = 10*mean(applyBasinMask(app, app.CSRTWSData, app.CSRTWSLat, app.CSRTWSLon),1);
                                        CSR_TWSA = NaN(1,1500);
                                        CSR_TWSA(1,[app.CSRTWSMN]) = CSR_BA;
                                        % Convert monthly to decadal mean
                                        CSR_decadal = NaN(1, numel(decadeStarts));
                                        monthly_data = CSR_TWSA(1,:);
                                        for decadeIdx = 1:numel(decadeStarts)
                                            startYear = decadeStarts(decadeIdx);
                                            endYear = min(startYear + 9, tEnd);
                                            % Convert years to month indices
                                            startMonth = (startYear - startYr) * 12 + 1;
                                            endMonth = (endYear - startYr + 1) * 12;
                                            % Ensure we don't exceed data bounds
                                            startMonth = max(startMonth, 1);
                                            endMonth = min(endMonth, length(monthly_data));

                                            decade_data = monthly_data(startMonth:endMonth);
                                            if any(~isnan(decade_data))
                                                CSR_decadal(1,decadeIdx) = mean(decade_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(CSR_decadal,3,1);

                                    case 'gsfc'
                                        GSFC_BA = 10*mean(applyBasinMask(app, app.GFSCTWSData, app.GFSCTWSLat, app.GFSCTWSLon),1);
                                        GSFC_TWSA = NaN(1,1500);
                                        GSFC_TWSA(1,[app.GFSCTWSMN]) = GSFC_BA;
                                        % Convert monthly to decadal mean
                                        GSFC_decadal = NaN(1, numel(decadeStarts));
                                        monthly_data = GSFC_TWSA(1,:);
                                        for decadeIdx = 1:numel(decadeStarts)
                                            startYear = decadeStarts(decadeIdx);
                                            endYear = min(startYear + 9, tEnd);
                                            % Convert years to month indices
                                            startMonth = (startYear - startYr) * 12 + 1;
                                            endMonth = (endYear - startYr + 1) * 12;
                                            % Ensure we don't exceed data bounds
                                            startMonth = max(startMonth, 1);
                                            endMonth = min(endMonth, length(monthly_data));

                                            decade_data = monthly_data(startMonth:endMonth);
                                            if any(~isnan(decade_data))
                                                GSFC_decadal(1,decadeIdx) = mean(decade_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(GSFC_decadal,3,1);

                                    otherwise
                                        disp(['[TWSA] Skipping unhandled node: "', rawName, '"']);
                                        continue;
                                end

                                if isempty(REC), continue; end
                                x_plot = 1:size(REC,2);

                                % Choose dataset color (fallback if missing)
                                if isfield(colors, nodeKey)
                                    c = colors.(nodeKey);
                                else
                                    c = [0.5 0.5 0.5];
                                end

                                if isfield(markers, nodeKey)
                                    d = markers.(nodeKey);
                                else
                                    d = 'square';
                                end

                                plot(app.UIAxes, x_plot, REC(3,x_plot), 'Color', c, 'LineWidth', 2,'Marker',d, 'DisplayName', strcat(upper(nodeKey)));
                            end

                            %% ==================== THIS STUDY TREE ====================
                            selectedNodes = app.This_Study.CheckedNodes;
                            hold(app.UIAxes,'on');
                            % Colors for each of your models
                            colors = struct( ...
                                'rf_imd',     [0.0 0.45 0.70], ...   % strong blue
                                'ann_g',      [0.85 0.33 0.10], ...  % bright orange
                                'ann_imd',     [0.93 0.69 0.13], ...  % yellow
                                'rf_g',       [0.49 0.18 0.56]);     % purple

                            for i = 1:numel(selectedNodes)
                                % Skip parent nodes
                                if ~isempty(selectedNodes(i).Children), continue; end

                                rawName = strtrim(selectedNodes(i).Text); % "Best", "ANN", etc.
                                nodeKey = lower(rawName);                 % normalize to lowercase

                                REC = [];
                                switch nodeKey
                                    %% BEST
                                    case 'rf_imd'
                                        Best_BA = mean(applyBasinMask(app, app.ThisStudyBestData, ...
                                            app.ThisStudyBestLat, app.ThisStudyBestLon),1);
                                        Best_REC = NaN(1,1500);
                                        Best_REC(1,[app.ThisStudyBestMN]) = Best_BA;
                                        % Convert monthly to decadal mean
                                        Best_decadal = NaN(1, numel(decadeStarts));
                                        monthly_data = Best_REC(1,:);
                                        for decadeIdx = 1:numel(decadeStarts)
                                            startYear = decadeStarts(decadeIdx);
                                            endYear = min(startYear + 9, tEnd);
                                            % Convert years to month indices
                                            startMonth = (startYear - startYr) * 12 + 1;
                                            endMonth = (endYear - startYr + 1) * 12;
                                            % Ensure we don't exceed data bounds
                                            startMonth = max(startMonth, 1);
                                            endMonth = min(endMonth, length(monthly_data));

                                            decade_data = monthly_data(startMonth:endMonth);
                                            if any(~isnan(decade_data))
                                                Best_decadal(1,decadeIdx) = mean(decade_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(Best_decadal,3,1);

                                        %% ANN
                                    case 'ann_g'
                                        ANN_BA = mean(applyBasinMask(app, app.ThisStudyANNData, ...
                                            app.ThisStudyANNLat, app.ThisStudyANNLon),1);
                                        ANN_REC = NaN(1,1500);
                                        ANN_REC(1,[app.ThisStudyANNMN]) = ANN_BA;
                                        % Convert monthly to decadal mean
                                        ANN_decadal = NaN(1, numel(decadeStarts));
                                        monthly_data = ANN_REC(1,:);
                                        for decadeIdx = 1:numel(decadeStarts)
                                            startYear = decadeStarts(decadeIdx);
                                            endYear = min(startYear + 9, tEnd);
                                            % Convert years to month indices
                                            startMonth = (startYear - startYr) * 12 + 1;
                                            endMonth = (endYear - startYr + 1) * 12;
                                            % Ensure we don't exceed data bounds
                                            startMonth = max(startMonth, 1);
                                            endMonth = min(endMonth, length(monthly_data));

                                            decade_data = monthly_data(startMonth:endMonth);
                                            if any(~isnan(decade_data))
                                                ANN_decadal(1,decadeIdx) = mean(decade_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(ANN_decadal,3,1);

                                        %% LSTM
                                    case 'ann_imd'
                                        LSTM_BA = mean(applyBasinMask(app, app.ThisStudyLSTMData, ...
                                            app.ThisStudyLSTMLat, app.ThisStudyLSTMLon),1);
                                        LSTM_REC = NaN(1,1500);
                                        LSTM_REC(1,[app.ThisStudyLSTMMN]) = LSTM_BA;
                                        % Convert monthly to decadal mean
                                        LSTM_decadal = NaN(1, numel(decadeStarts));
                                        monthly_data = LSTM_REC(1,:);
                                        for decadeIdx = 1:numel(decadeStarts)
                                            startYear = decadeStarts(decadeIdx);
                                            endYear = min(startYear + 9, tEnd);
                                            % Convert years to month indices
                                            startMonth = (startYear - startYr) * 12 + 1;
                                            endMonth = (endYear - startYr + 1) * 12;
                                            % Ensure we don't exceed data bounds
                                            startMonth = max(startMonth, 1);
                                            endMonth = min(endMonth, length(monthly_data));

                                            decade_data = monthly_data(startMonth:endMonth);
                                            if any(~isnan(decade_data))
                                                LSTM_decadal(1,decadeIdx) = mean(decade_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(LSTM_decadal,3,1);

                                        %% RF
                                    case 'rf_g'
                                        RF_BA = mean(applyBasinMask(app, app.ThisStudyRFData, ...
                                            app.ThisStudyRFLat, app.ThisStudyRFLon),1);
                                        RF_REC = NaN(1,1500);
                                        RF_REC(1,[app.ThisStudyRFMN]) = RF_BA;
                                        % Convert monthly to decadal mean
                                        RF_decadal = NaN(1, numel(decadeStarts));
                                        monthly_data = RF_REC(1,:);
                                        for decadeIdx = 1:numel(decadeStarts)
                                            startYear = decadeStarts(decadeIdx);
                                            endYear = min(startYear + 9, tEnd);
                                            % Convert years to month indices
                                            startMonth = (startYear - startYr) * 12 + 1;
                                            endMonth = (endYear - startYr + 1) * 12;
                                            % Ensure we don't exceed data bounds
                                            startMonth = max(startMonth, 1);
                                            endMonth = min(endMonth, length(monthly_data));

                                            decade_data = monthly_data(startMonth:endMonth);
                                            if any(~isnan(decade_data))
                                                RF_decadal(1,decadeIdx) = mean(decade_data, 'omitnan');
                                            end
                                        end
                                        REC = repmat(RF_decadal,3,1);
                                end

                                if isempty(REC), continue; end
                                % Pick dataset color safely
                                if isfield(colors,nodeKey)
                                    c = colors.(nodeKey);
                                else
                                    c = [0.5 0.5 0.5]; % fallback gray
                                end

                                hold(app.UIAxes,'on');

                                % Mean line
                                plot(app.UIAxes, x, REC(3,x), 'Color', c, 'LineWidth',1.5,'DisplayName', strcat(rawName));

                            end

                            % Axes settings
                            grid(app.UIAxes,'on');
                            app.UIAxes.FontName = 'Times New Roman';
                            app.UIAxes.FontSize = 14;
                            app.UIAxes.XLabel.String = 'Time (Decades)';
                            app.UIAxes.XLabel.FontName = 'Times New Roman';
                            app.UIAxes.XLabel.FontWeight = 'bold';
                            app.UIAxes.XLabel.FontSize = 18;
                            app.UIAxes.YLabel.String = '(R)TWSA (mm)';   % left axis label
                            app.UIAxes.YLabel.FontName = 'Times New Roman';
                            app.UIAxes.YLabel.FontWeight = 'bold';
                            app.UIAxes.YLabel.FontSize = 18;

                            hold(app.UIAxes,'off');

                            %% ==================== PRECIPITATION (inverted, on right axis, with gap to TWS) ====================
                            selectedNodes = app.Precipitation.CheckedNodes;
                            yyaxis(app.UIAxes,'right');
                            yl = ylabel(app.UIAxes,'Precipitation (mm)');  % get handle
                            yl.FontSize = 18;
                            yl.FontName = 'Times New Roman';
                            yl.FontWeight = 'bold';
                            set(app.UIAxes,'YDir','reverse');  % invert the axis so bars grow downward

                            precipData = []; precipLabels = {};
                            for i = 1:numel(selectedNodes)
                                if ~isempty(selectedNodes(i).Children), continue; end
                                rawName = strtrim(selectedNodes(i).Text);
                                nodeKey = lower(rawName);
                                clear data

                                switch nodeKey
                                    case 'imd'
                                        % IMD (already in mm monthly) - convert to decadal mean annual precipitation
                                        app.IMD_BA = mean(applyBasinMask(app, app.IMDData, app.IMDLat, app.IMDLon),1);
                                        data_monthly = NaN(1,1500); data_monthly(1,app.IMDMN) = app.IMD_BA;
                                        % Convert to decadal mean annual precipitation
                                        data = NaN(1, numel(decadeStarts));
                                        for decadeIdx = 1:numel(decadeStarts)
                                            startYear = decadeStarts(decadeIdx);
                                            endYear = min(startYear + 9, tEnd);
                                            % Convert years to month indices
                                            startMonth = (startYear - startYr) * 12 + 1;
                                            endMonth = (endYear - startYr + 1) * 12;
                                            % Ensure we don't exceed data bounds
                                            startMonth = max(startMonth, 1);
                                            endMonth = min(endMonth, length(data_monthly));

                                            decade_data = data_monthly(1,startMonth:endMonth);
                                            if any(~isnan(decade_data))
                                                % Calculate mean annual precipitation for the decade
                                                data(1,decadeIdx) = mean(decade_data, 'omitnan') * 12; % Convert monthly mean to annual equivalent
                                            end
                                        end

                                    case 'gpcp'
                                        % GPCP (mm/month) - convert to decadal mean annual precipitation
                                        app.GPCP_BA = mean(applyBasinMask(app, app.GPCPData, app.GPCPLat, app.GPCPLon),1);
                                        data_monthly = NaN(1,1500); data_monthly(1,app.GPCPMN) = app.GPCP_BA;
                                        % Convert to decadal mean annual precipitation
                                        data = NaN(1, numel(decadeStarts));
                                        for decadeIdx = 1:numel(decadeStarts)
                                            startYear = decadeStarts(decadeIdx);
                                            endYear = min(startYear + 9, tEnd);
                                            % Convert years to month indices
                                            startMonth = (startYear - startYr) * 12 + 1;
                                            endMonth = (endYear - startYr + 1) * 12;
                                            % Ensure we don't exceed data bounds
                                            startMonth = max(startMonth, 1);
                                            endMonth = min(endMonth, length(data_monthly));

                                            decade_data = data_monthly(1,startMonth:endMonth);
                                            if any(~isnan(decade_data))
                                                % Calculate mean annual precipitation for the decade
                                                data(1,decadeIdx) = mean(decade_data, 'omitnan') * 12; % Convert monthly mean to annual equivalent
                                            end
                                        end

                                    case 'era5'
                                        % ERA5 'tp' is meters; convert to mm and then decadal mean annual precipitation
                                        app.ERA5_BA = 1000*mean(applyBasinMask(app, app.ERA5Data, app.ERA5Lat, app.ERA5Lon),1);
                                        data_monthly = NaN(1,1500); data_monthly(1,app.ERA5MN) = app.ERA5_BA;
                                        % Convert to decadal mean annual precipitation
                                        data = NaN(1, numel(decadeStarts));
                                        for decadeIdx = 1:numel(decadeStarts)
                                            startYear = decadeStarts(decadeIdx);
                                            endYear = min(startYear + 9, tEnd);
                                            % Convert years to month indices
                                            startMonth = (startYear - startYr) * 12 + 1;
                                            endMonth = (endYear - startYr + 1) * 12;
                                            % Ensure we don't exceed data bounds
                                            startMonth = max(startMonth, 1);
                                            endMonth = min(endMonth, length(data_monthly));

                                            decade_data = data_monthly(1,startMonth:endMonth);
                                            if any(~isnan(decade_data))
                                                % Calculate mean annual precipitation for the decade
                                                data(1,decadeIdx) = mean(decade_data, 'omitnan') * 12; % Convert monthly mean to annual equivalent
                                            end
                                        end
                                end

                                if exist('data','var')
                                    precipData   = [precipData; data];    %#ok<AGROW>
                                    precipLabels = [precipLabels; nodeKey]; %#ok<AGROW>
                                end
                            end

                            if ~isempty(precipData)
                                % What's selected?
                                nSel      = size(precipData,1);
                                hasIMD    = any(strcmpi(precipLabels,'imd'));
                                % Stats in window
                                p_min  = min(precipData(:,x),[],1,'omitnan');
                                p_max  = max(precipData(:,x),[],1,'omitnan');
                                p_mean = mean(precipData(:,x),1,'omitnan');
                                Pmax   = max(p_max,[],'omitnan');

                                % ---- Plot according to selection rules ----
                                if nSel == 1
                                    % Only one dataset selected
                                    ydata = precipData(1,x);
                                    if strcmpi(precipLabels{1},'imd')
                                        hold(app.UIAxes,'on');
                                        % IMD as open circles (inverted)
                                        bar(app.UIAxes, x, ydata, 0.4, 'FaceColor','none','EdgeColor',[0.2 0.7 0.9],'LineWidth',1.2, 'DisplayName','IMD Precip');
                                        plot(app.UIAxes, x, ydata, 'o', 'Color','k', 'MarkerFaceColor','w','MarkerSize',4,'DisplayName','IMD Precip');
                                    elseif strcmpi(precipLabels{1},'gpcp')
                                        bar(app.UIAxes, x, ydata, 0.4, 'FaceColor','none','EdgeColor',[0.2 0.7 0.9],'LineWidth',1.2, 'DisplayName','GPCP Precip');
                                    else % ERA5
                                        bar(app.UIAxes, x, ydata, 0.4, 'FaceColor','none','EdgeColor',[0.2 0.7 0.9],'LineWidth',1.2, 'DisplayName','ERA5 Precip');
                                    end
                                elseif nSel == 2
                                    % Multiple selected
                                    hold(app.UIAxes,'on');
                                    bar(app.UIAxes, x, p_mean, 0.45, 'FaceColor','none','EdgeColor',[0.2 0.7 0.9],'LineWidth',1.2, 'DisplayName','Mean Precip');
                                    % Whiskers (min-max) behind mean
                                    legendAdded = false;

                                    for k = 1:numel(x)
                                        if ~legendAdded
                                            line(app.UIAxes, [x(k) x(k)], [p_max(k) p_min(k)],'Color',[0.35 0.35 0.35], 'LineWidth',1.0,'LineStyle','-', 'Marker','none', 'DisplayName','Precip Range');
                                            legendAdded = true;
                                        else
                                            line(app.UIAxes, [x(k) x(k)], [p_max(k) p_min(k)],'Color',[0.35 0.35 0.35], 'LineWidth',1.0,'LineStyle','-', 'Marker','none', 'HandleVisibility','off');
                                        end
                                    end

                                    if hasIMD
                                        j = find(strcmpi(precipLabels,'imd'),1);
                                        plot(app.UIAxes, x, precipData(j,x), 'o', 'Color','k', 'MarkerFaceColor','w','MarkerSize',4,'DisplayName','IMD Precip');
                                    end
                                else
                                    hold(app.UIAxes,'on');
                                    bar(app.UIAxes, x, p_mean, 0.45, 'FaceColor','none','EdgeColor',[0.2 0.7 0.9],'LineWidth',1.2, 'DisplayName','Mean Precip');
                                    j = find(strcmpi(precipLabels,'imd'),1);
                                    plot(app.UIAxes, x, precipData(j,x), 'o', 'Color','k', 'MarkerFaceColor','w','MarkerSize',4,'DisplayName','IMD Precip');
                                    legendAdded = false;

                                    for k = 1:numel(x)
                                        if ~legendAdded
                                            line(app.UIAxes, [x(k) x(k)], [p_max(k) p_min(k)],'Color',[0.35 0.35 0.35], 'LineWidth',1.0,'LineStyle','-', 'Marker','none', 'DisplayName','Precip Range');
                                            legendAdded = true;
                                        else
                                            line(app.UIAxes, [x(k) x(k)], [p_max(k) p_min(k)],'Color',[0.35 0.35 0.35], 'LineWidth',1.0,'LineStyle','-', 'Marker','none', 'HandleVisibility','off');
                                        end
                                    end
                                end

                                % ---------- Dynamic Axis coordination (TWSA + Precip Gap) ----------
                                yyaxis(app.UIAxes,'left');

                                % Collect ALL TWSA data from plotted series in the selected window
                                allTWSA = [];
                                h = findall(app.UIAxes,'Type','Line'); % get plotted lines
                                for k = 1:numel(h)
                                    ydata = h(k).YData;
                                    xdata = h(k).XData;
                                    % only keep values within the x window
                                    mask = (xdata >= min(x) & xdata <= max(x));
                                    if any(mask)
                                        allTWSA = [allTWSA, ydata(mask)];
                                    end
                                end

                                if ~isempty(allTWSA)
                                    % Dynamic limits based on selected time window
                                    twsMin = min(allTWSA, [], 'omitnan');
                                    twsMax = max(allTWSA, [], 'omitnan');
                                    % Add padding for readability
                                    pad = 0.15 * (twsMax - twsMin);
                                    twsLimits = [twsMin - pad, twsMax + pad];

                                    % Apply limits to left axis
                                    ylim(app.UIAxes, twsLimits);

                                    % Dynamic ticks
                                    step = round((twsMax - twsMin) / 5);
                                    if step == 0, step = 1; end
                                    app.UIAxes.YTick = round(twsMin):step:round(twsMax);

                                    % -------- Right axis (precipitation, inverted, with gap) --------
                                    yyaxis(app.UIAxes,'right');
                                    Pmax = max(p_max,[],'omitnan');
                                    gap  = 1.2 * (twsLimits(2) - twsLimits(1)); % proportional gap
                                    ylim(app.UIAxes, [0 Pmax + gap]);
                                    yticks(app.UIAxes, 0:round(Pmax/5):Pmax);
                                end
                            end

                            % Ensure grid and axis font
                            grid(app.UIAxes, 'on');
                            app.UIAxes.FontName = 'Times New Roman';
                            app.UIAxes.FontSize = 18* scale;;

                            % Axis labels
                            app.UIAxes.XLabel.String = 'Time (Decades)';
                            app.UIAxes.XLabel.FontName = 'Times New Roman';
                            app.UIAxes.XLabel.FontWeight = 'bold';
                            app.UIAxes.XLabel.FontSize = 18* scale;;

                            % Create legend AFTER plotting
                            lg = legend(app.UIAxes, 'show');
                            % Legend configuration
                            lg.NumColumns = 9; % fallback
                            lg.Location    = 'southoutside';
                            lg.Orientation = 'horizontal';
                            lg.Box         = 'on';
                            lg.Interpreter = 'none';
                            lg.AutoUpdate  = 'off';
                            lg.FontName    = 'Times New Roman';
                            lg.FontWeight  = 'bold';

                            if exist('scale','var') && ~isempty(scale)
                                lg.FontSize = 10* scale;
                            else
                                lg.FontSize = 12; % fallback
                            end

                            hold(app.UIAxes, 'off');

                    end

                case 'Spatial'
                    %% ==================== INITIALIZE ====================
                    cla(app.UIAxes,'reset');
                    hold(app.UIAxes,'on');

                    % Time axis (master monthly line: Jan-1901 ... Dec-2025)
                    startDate   = datetime(1901,1,1);
                    endDate     = datetime(2025,12,1);
                    allTimeDates = startDate:calmonths(1):endDate;  % length = 1500

                    % Slider-selected window
                    sIdx = round(app.TimeSpan19012025Slider.Value(1));
                    eIdx = round(app.TimeSpan19012025Slider.Value(2));
                    sIdx = max(sIdx,1);
                    eIdx = min(eIdx, numel(allTimeDates));

                    % Numeric time in **years** from window start (used for slopes in mm/yr)
                    winDates = allTimeDates(sIdx:eIdx);
                    t = years(winDates - winDates(1));  % column t has units of years
                    x= sIdx:eIdx;
                    % Retrieve the selected basin
                    selectedBasin = app.BasinSelectionButton.Value;
                    % Load shapefile data
                    basins = app.Basins;

                    % Find the polygon corresponding to the selected basin
                    basinPolygon = [];
                    for i = 1:length(basins)
                        if strcmpi(basins(i).RIVER_BASI, selectedBasin)
                            basinPolygon = [basins(i).X', basins(i).Y']; % Extract polygon coordinates
                            break;
                        end
                    end

                    % Clean polygon (remove NaNs)
                    basinPolygon = basinPolygon(~any(isnan(basinPolygon), 2), :);

                    % if isempty(basinPolygon)
                    %     uialert(app.UIFigure, ...
                    %         {'Please select a basin.', ...
                    %          'If selected, please ensure the selected', ...
                    %          'basin is available in the shapefile.'}, ...
                    %         'Warning', 'Icon','warning');
                    %     return;  % <<< Stop execution here
                    % end
                    % ==================== SELECTION VALIDATION ====================
                    % Collect all selected leaf nodes across all categories
                    selectedRTWSA = app.RTWSA.CheckedNodes;
                    selectedTWSA  = app.TWSA.CheckedNodes;
                    selectedThis  = app.This_Study.CheckedNodes;

                    % Combine only leaf nodes (no parents)
                    allSelected = [selectedRTWSA(~arrayfun(@(n) ~isempty(n.Children), selectedRTWSA)); ...
                        selectedTWSA(~arrayfun(@(n) ~isempty(n.Children), selectedTWSA)); ...
                        selectedThis(~arrayfun(@(n) ~isempty(n.Children), selectedThis))];

                    % Check how many datasets are selected
                    if numel(allSelected) > 1
                        uialert(app.UIFigure, ...
                            {'Spatial plots are available for one dataset at a time.', ...
                            'Please select only one dataset and try again.'}, ...
                            'Multiple Selections Detected', ...
                            'Icon', 'warning');
                        return;  % <<< Stop execution before any plotting
                    end

                    %% ==================== RECONSTRUCTED TREE ====================
                    selectedNodes = app.RTWSA.CheckedNodes;
                    for i = 1:numel(selectedNodes)
                        % Skip parent nodes
                        if ~isempty(selectedNodes(i).Children), continue; end
                        rawName = strtrim(selectedNodes(i).Text); % clean up
                        nodeKey = lower(rawName); % normalize to lowercase
                        switch nodeKey
                            %% HUMPHREY (6 datasets)
                            case 'hg19'
                                cla(app.UIAxes);
                                [Hp_GERECmasked,latHp_GEREC, lonHp_GEREC] = applyBasinMaskWithCoords(app, app.Hp_GERECData, app.Hp_GERECLat, app.Hp_GERECLon);
                                Hp_GEREC = NaN(size(latHp_GEREC,1),1500);
                                Hp_GEREC(:,[app.Hp_GERECMN])= Hp_GERECmasked;
                                Hp_GERECmean=mean(Hp_GEREC(:,x),2,'omitnan');
                                plotSpatialBasinMap(app, lonHp_GEREC, latHp_GEREC, Hp_GERECmean, basinPolygon, ...
                                    'Humphrey Basin Mean (selected timespan)');

                                %% PALAZZOLI (LSTM)
                            case 'p25'
                                % --- 1. Apply basin mask with coordinates ---
                                [Pl_RECmasked, latPl_REC, lonPl_REC] = applyBasinMaskWithCoords(app, ...
                                    app.PalazzoliLSTMData, app.PalazzoliLSTMLat, app.PalazzoliLSTMLon);

                                % Allocate container
                                Pl_REC = NaN(size(latPl_REC,1),1500);
                                Pl_REC(:,[app.PalazzoliLSTMMN]) = 10 * Pl_RECmasked;   % note the scaling factor *10

                                % Basin mean for selected time indices (x from slider)
                                Pl_RECmean = mean(Pl_REC(:,x),2,'omitnan');

                                plotSpatialBasinMap(app, lonPl_REC, latPl_REC, Pl_RECmean, basinPolygon, ...
                                    'Palazzoli Basin Mean (selected timespan)');
                                %% LI (single)
                            case 'l21'
                                % --- 1. Apply basin mask to Li data ---
                                [Li_RECmasked, latLi_REC, lonLi_REC] = applyBasinMaskWithCoords(app, ...
                                    app.LiRECData, app.LiRECLat, app.LiRECLon);

                                % Allocate container (like Hp_GEREC)
                                Li_REC = NaN(size(latLi_REC,1),1500);
                                Li_REC(:,[app.LiRECMN]) = 10*Li_RECmasked;

                                % Basin mean across selected time indices (x is from slider)
                                Li_RECmean = mean(Li_REC(:,x),2,'omitnan');

                                plotSpatialBasinMap(app, lonLi_REC, latLi_REC, Li_RECmean, basinPolygon, ...
                                    'Li Basin Mean (selected timespan)');

                                %% DENG (single)
                            case 'd23'
                                % --- 1. Apply basin mask with coordinates ---
                                [Deng_RECmasked, latDeng_REC, lonDeng_REC] = applyBasinMaskWithCoords(app, ...
                                    app.DengRECData, app.DengRECLat, app.DengRECLon);

                                % Allocate container (similar to Li/Hp)
                                Deng_REC = NaN(size(latDeng_REC,1),1500);
                                Deng_REC(:,[app.DengRECMN]) = Deng_RECmasked;

                                % Basin mean across selected time indices (x is from slider)
                                Deng_RECmean = mean(Deng_REC(:,x),2,'omitnan');
                                plotSpatialBasinMap(app, lonDeng_REC, latDeng_REC, Deng_RECmean, basinPolygon, ...
                                    'Deng Basin Mean (selected timespan)');

                                %
                                %% MANDAL (single)
                            case 'm25'
                                % --- 1. Apply basin mask with coordinates ---
                                [Mandal_RECmasked, latMandal_REC, lonMandal_REC] = applyBasinMaskWithCoords(app, ...
                                    app.MandalRECData, app.MandalRECLat, app.MandalRECLon);

                                % Allocate container (same style as hp/li/deng)
                                Mandal_REC = NaN(size(latMandal_REC,1),1500);
                                Mandal_REC(:,[app.MandalRECMN]) = Mandal_RECmasked;

                                % Basin mean for selected time indices (x from slider)
                                Mandal_RECmean = mean(Mandal_REC(:,x),2,'omitnan');
                                % Plot spatial map
                                plotSpatialBasinMap(app, lonMandal_REC, latMandal_REC, Mandal_RECmean, basinPolygon, ...
                                    'Mandal Basin Mean (selected timespan)');

                        end
                    end
                    % Get selected GRACE datasets
                    selectedNodes = app.TWSA.CheckedNodes;
                    hold(app.UIAxes,'on');
                    for i = 1:numel(selectedNodes)
                        % Skip non-leaf nodes
                        if ~isempty(selectedNodes(i).Children), continue; end

                        rawName = strtrim(selectedNodes(i).Text);  % remove spaces
                        nodeKey = lower(rawName);
                        switch nodeKey
                            %% JPL (mascon)
                            case 'jpl'
                                [JPL_masked, latJPL, lonJPL] = applyBasinMaskWithCoords(app, ...
                                    app.JPLTWSData, app.JPLTWSLat, app.JPLTWSLon);

                                JPL_REC = NaN(size(latJPL,1),1500);
                                JPL_REC(:,app.JPLTWSMN) = 10 * JPL_masked;

                                JPLmean = mean(JPL_REC(:,x),2,'omitnan');

                                % Interpolation + plotting
                                plotSpatialBasinMap(app, lonJPL, latJPL, JPLmean, basinPolygon, ...
                                    'JPL Mascon Basin Mean (selected timespan)');

                                %% CSR (mascon)
                            case 'csr'
                                [CSR_masked, latCSR, lonCSR] = applyBasinMaskWithCoords(app, ...
                                    app.CSRTWSData, app.CSRTWSLat, app.CSRTWSLon);

                                CSR_REC = NaN(size(latCSR,1),1500);
                                CSR_REC(:,app.CSRTWSMN) = 10 * CSR_masked;

                                CSRmean = mean(CSR_REC(:,x),2,'omitnan');

                                % Interpolation + plotting
                                plotSpatialBasinMap(app, lonCSR, latCSR, CSRmean, basinPolygon, ...
                                    'CSR Mascon Basin Mean (selected timespan)');

                                %% GSFC (mascon)
                            case 'gsfc'
                                [GSFC_masked, latGSFC, lonGSFC] = applyBasinMaskWithCoords(app, ...
                                    app.GFSCTWSData, app.GFSCTWSLat, app.GFSCTWSLon);

                                GSFC_REC = NaN(size(latGSFC,1),1500);
                                GSFC_REC(:,app.GFSCTWSMN) = 10 * GSFC_masked;

                                GSFCmean = mean(GSFC_REC(:,x),2,'omitnan');

                                % Interpolation + plotting
                                plotSpatialBasinMap(app, lonGSFC, latGSFC, GSFCmean, basinPolygon, ...
                                    'GSFC Mascon Basin Mean (selected timespan)');
                        end
                    end
                    selectedNodes = app.This_Study.CheckedNodes;
                    hold(app.UIAxes,'on');

                    for i = 1:numel(selectedNodes)
                        % Skip parent nodes
                        if ~isempty(selectedNodes(i).Children), continue; end

                        rawName = strtrim(selectedNodes(i).Text); % "Best", "ANN", etc.
                        nodeKey = lower(rawName);                 % normalize to lowercase
                        switch nodeKey
                            %% BEST
                            case 'rf_imd'
                                [Best_masked, latBest, lonBest] = applyBasinMaskWithCoords(app, ...
                                    app.ThisStudyBestData, app.ThisStudyBestLat, app.ThisStudyBestLon);

                                Best_REC = NaN(size(latBest,1),1500);
                                Best_REC(:,app.ThisStudyBestMN) = Best_masked;

                                BestMean = mean(Best_REC(:,x),2,'omitnan');

                                % Plot spatial map
                                plotSpatialBasinMap(app, lonBest, latBest, BestMean, basinPolygon, ...
                                    'BEST Basin Mean (selected timespan)');

                                %% ANN
                            case 'ann_g'
                                [ANN_masked, latANN, lonANN] = applyBasinMaskWithCoords(app, ...
                                    app.ThisStudyANNData, app.ThisStudyANNLat, app.ThisStudyANNLon);

                                ANN_REC = NaN(size(latANN,1),1500);
                                ANN_REC(:,app.ThisStudyANNMN) = ANN_masked;

                                ANNMean = mean(ANN_REC(:,x),2,'omitnan');

                                % Plot spatial map
                                plotSpatialBasinMap(app, lonANN, latANN, ANNMean, basinPolygon, ...
                                    'ANN Basin Mean (selected timespan)');

                                %% LSTM
                            case 'ann_imd'
                                [LSTM_masked, latLSTM, lonLSTM] = applyBasinMaskWithCoords(app, ...
                                    app.ThisStudyLSTMData, app.ThisStudyLSTMLat, app.ThisStudyLSTMLon);

                                LSTM_REC = NaN(size(latLSTM,1),1500);
                                LSTM_REC(:,app.ThisStudyLSTMMN) = LSTM_masked;

                                LSTMMean = mean(LSTM_REC(:,x),2,'omitnan');

                                % Plot spatial map
                                plotSpatialBasinMap(app, lonLSTM, latLSTM, LSTMMean, basinPolygon, ...
                                    'LSTM Basin Mean (selected timespan)');

                                %% RF
                            case 'rf_g'
                                [RF_masked, latRF, lonRF] = applyBasinMaskWithCoords(app, ...
                                    app.ThisStudyRFData, app.ThisStudyRFLat, app.ThisStudyRFLon);

                                RF_REC = NaN(size(latRF,1),1500);
                                RF_REC(:,app.ThisStudyRFMN) = RF_masked;

                                RFMean = mean(RF_REC(:,x),2,'omitnan');

                                % Plot spatial map
                                plotSpatialBasinMap(app, lonRF, latRF, RFMean, basinPolygon, ...
                                    'RF Basin Mean (selected timespan)');
                        end
                    end
                case 'Regional Mean'
                    cla(app.UIAxes, 'reset');
                    hold(app.UIAxes, 'on');

                    % Check if more than one dataset is selected
                    totalSelected = 0;

                    % Count selected nodes from all sections
                    selectedNodesRTWSA = app.RTWSA.CheckedNodes;
                    for i = 1:numel(selectedNodesRTWSA)
                        if isempty(selectedNodesRTWSA(i).Children)
                            totalSelected = totalSelected + 1;
                        end
                    end

                    selectedNodesTWSA = app.TWSA.CheckedNodes;
                    for i = 1:numel(selectedNodesTWSA)
                        if isempty(selectedNodesTWSA(i).Children)
                            totalSelected = totalSelected + 1;
                        end
                    end

                    selectedNodesThisStudy = app.This_Study.CheckedNodes;
                    for i = 1:numel(selectedNodesThisStudy)
                        if isempty(selectedNodesThisStudy(i).Children)
                            totalSelected = totalSelected + 1;
                        end
                    end

                    % If more than one dataset selected, show warning and return
                    if totalSelected > 1
                        uialert(app.UIFigure, ...
                            'Please check only one dataset at a time for Regional Mean plot.', ...
                            'Multiple Datasets Selected', 'Icon', 'warning');
                        hold(app.UIAxes, 'off');
                        return;
                    end

                    % Define the starting and ending dates for the slider scale
                    startDate = datetime(1901, 1, 1); % Start date (01-1901)
                    endDate = datetime(2025, 12, 1);  % End date (12-2025)
                    % Generate all months between the start and end dates
                    allTimeDates = startDate:calmonths(1):endDate;
                    % Get selected time range from slider
                    sIdx = round(app.TimeSpan19012025Slider.Value(1));
                    eIdx = round(app.TimeSpan19012025Slider.Value(2));
                    sIdx = max(sIdx,1);
                    eIdx = min(eIdx, numel(allTimeDates));
                    selectedTimeRange = allTimeDates(sIdx:eIdx);
                    x = sIdx:eIdx;
                    % Get start & end years of current visible time range
                    tStart = year(selectedTimeRange(1));
                    tEnd   = year(selectedTimeRange(end));
                    xlim(app.UIAxes, [sIdx eIdx]);
                    % Calculate total span in years
                    spanYears = tEnd - tStart;

                    % Choose a step size dynamically (prevent overlap)
                    if spanYears > 40
                        step = 10;   % e.g., large range → coarser ticks
                    elseif spanYears > 20
                        step = 5;
                    elseif spanYears > 10
                        step = 2;
                    else
                        step = 1;    % short range → finer ticks
                    end

                    % Define ticks
                    tickYears = tStart:step:tEnd;

                    % % Axis ticks every 2 years
                    % tickYears = year(selectedTimeRange(1)) : 2 : year(selectedTimeRange(end));
                    xt = datetime(tickYears, 1, 1);
                    % Convert datetime to indices relative to allTimeDates
                    [~, idxTicks] = ismember(xt, allTimeDates);
                    % Apply ticks and labels
                    app.UIAxes.XTick = idxTicks;
                    app.UIAxes.XTickLabel = cellstr(datestr(xt, 'yyyy'));

                    % Initialize variables for regional plot
                    regionalData = [];
                    regionalLats = [];
                    datasetName = '';

                    %% ==================== PROCESS RECONSTRUCTED TREE DATA ====================
                    selectedNodes = app.RTWSA.CheckedNodes;
                    for i = 1:numel(selectedNodes)
                        if ~isempty(selectedNodes(i).Children), continue; end

                        rawName = strtrim(selectedNodes(i).Text);
                        nodeKey = lower(rawName);

                        switch nodeKey
                            %% HUMPHREY (6 datasets)
                            case 'hg19'
                                [Hp_GERECmasked, latHp_GEREC, lonHp_GEREC] = applyBasinMaskWithCoords(app, app.Hp_GERECData, app.Hp_GERECLat, app.Hp_GERECLon);

                                if ~isempty(Hp_GERECmasked)
                                    % Create full timeline container
                                    Hp_GEREC = NaN(size(latHp_GEREC,1), 1500);
                                    Hp_GEREC(:, app.Hp_GERECMN) = Hp_GERECmasked;

                                    % Extract selected time range
                                    Hp_GEREC_selected = Hp_GEREC(:, x);

                                    % Group by latitude and compute regional mean (latitude-time matrix)
                                    [uniqueLats, ~, idx] = unique(latHp_GEREC);
                                    regionalMeanData = zeros(length(uniqueLats), length(x));

                                    for j = 1:length(uniqueLats)
                                        latMask = (latHp_GEREC == uniqueLats(j));
                                        % Average over all points at this latitude (regional mean)
                                        regionalMeanData(j, :) = mean(Hp_GEREC_selected(latMask, :), 1, 'omitnan');
                                    end

                                    regionalData = regionalMeanData;
                                    regionalLats = uniqueLats;
                                    datasetName = 'Humphrey et al. 2019';
                                end

                                %% PALAZZOLI (LSTM)
                            case 'p25'
                                [Pl_RECmasked, latPl_REC, lonPl_REC] = applyBasinMaskWithCoords(app, ...
                                    app.PalazzoliLSTMData, app.PalazzoliLSTMLat, app.PalazzoliLSTMLon);

                                if ~isempty(Pl_RECmasked)
                                    Pl_REC = NaN(size(latPl_REC,1), 1500);
                                    Pl_REC(:, app.PalazzoliLSTMMN) = 10 * Pl_RECmasked;

                                    Pl_REC_selected = Pl_REC(:, x);

                                    [uniqueLats, ~, idx] = unique(latPl_REC);
                                    regionalMeanData = zeros(length(uniqueLats), length(x));

                                    for j = 1:length(uniqueLats)
                                        latMask = (latPl_REC == uniqueLats(j));
                                        regionalMeanData(j, :) = mean(Pl_REC_selected(latMask, :), 1, 'omitnan');
                                    end

                                    regionalData = regionalMeanData;
                                    regionalLats = uniqueLats;
                                    datasetName = 'Palazzoli et al. 2025';
                                end

                                %% LI (single)
                            case 'l21'
                                [Li_RECmasked, latLi_REC, lonLi_REC] = applyBasinMaskWithCoords(app, ...
                                    app.LiRECData, app.LiRECLat, app.LiRECLon);

                                if ~isempty(Li_RECmasked)
                                    Li_REC = NaN(size(latLi_REC,1), 1500);
                                    Li_REC(:, app.LiRECMN) = 10 * Li_RECmasked;

                                    Li_REC_selected = Li_REC(:, x);

                                    [uniqueLats, ~, idx] = unique(latLi_REC);
                                    regionalMeanData = zeros(length(uniqueLats), length(x));

                                    for j = 1:length(uniqueLats)
                                        latMask = (latLi_REC == uniqueLats(j));
                                        regionalMeanData(j, :) = mean(Li_REC_selected(latMask, :), 1, 'omitnan');
                                    end

                                    regionalData = regionalMeanData;
                                    regionalLats = uniqueLats;
                                    datasetName = 'Li et al. 2021';
                                end

                                %% DENG (single)
                            case 'd23'
                                [Deng_RECmasked, latDeng_REC, lonDeng_REC] = applyBasinMaskWithCoords(app, ...
                                    app.DengRECData, app.DengRECLat, app.DengRECLon);

                                if ~isempty(Deng_RECmasked)
                                    Deng_REC = NaN(size(latDeng_REC,1), 1500);
                                    Deng_REC(:, app.DengRECMN) = Deng_RECmasked;

                                    Deng_REC_selected = Deng_REC(:, x);

                                    [uniqueLats, ~, idx] = unique(latDeng_REC);
                                    regionalMeanData = zeros(length(uniqueLats), length(x));

                                    for j = 1:length(uniqueLats)
                                        latMask = (latDeng_REC == uniqueLats(j));
                                        regionalMeanData(j, :) = mean(Deng_REC_selected(latMask, :), 1, 'omitnan');
                                    end

                                    regionalData = regionalMeanData;
                                    regionalLats = uniqueLats;
                                    datasetName = 'Deng et al. 2023';
                                end

                                %% MANDAL (single)
                            case 'm25'
                                [Mandal_RECmasked, latMandal_REC, lonMandal_REC] = applyBasinMaskWithCoords(app, ...
                                    app.MandalRECData, app.MandalRECLat, app.MandalRECLon);

                                if ~isempty(Mandal_RECmasked)
                                    Mandal_REC = NaN(size(latMandal_REC,1), 1500);
                                    Mandal_REC(:, app.MandalRECMN) = Mandal_RECmasked;

                                    Mandal_REC_selected = Mandal_REC(:, x);

                                    [uniqueLats, ~, idx] = unique(latMandal_REC);
                                    regionalMeanData = zeros(length(uniqueLats), length(x));

                                    for j = 1:length(uniqueLats)
                                        latMask = (latMandal_REC == uniqueLats(j));
                                        regionalMeanData(j, :) = mean(Mandal_REC_selected(latMask, :), 1, 'omitnan');
                                    end

                                    regionalData = regionalMeanData;
                                    regionalLats = uniqueLats;
                                    datasetName = 'Mandal et al. 2025';
                                end
                        end

                        if ~isempty(regionalData)
                            break; % Only process first selected dataset
                        end
                    end

                    %% ==================== PROCESS GRACE DATA ====================
                    if isempty(regionalData)
                        selectedNodes = app.TWSA.CheckedNodes;
                        for i = 1:numel(selectedNodes)
                            if ~isempty(selectedNodes(i).Children), continue; end

                            rawName = strtrim(selectedNodes(i).Text);
                            nodeKey = lower(rawName);

                            switch nodeKey
                                %% JPL (mascon)
                                case 'jpl'
                                    [JPL_masked, latJPL, lonJPL] = applyBasinMaskWithCoords(app, ...
                                        app.JPLTWSData, app.JPLTWSLat, app.JPLTWSLon);

                                    if ~isempty(JPL_masked)
                                        JPL_REC = NaN(size(latJPL,1), 1500);
                                        JPL_REC(:, app.JPLTWSMN) = 10 * JPL_masked;

                                        JPL_selected = JPL_REC(:, x);

                                        [uniqueLats, ~, idx] = unique(latJPL);
                                        regionalMeanData = zeros(length(uniqueLats), length(x));

                                        for j = 1:length(uniqueLats)
                                            latMask = (latJPL == uniqueLats(j));
                                            regionalMeanData(j, :) = mean(JPL_selected(latMask, :), 1, 'omitnan');
                                        end

                                        regionalData = regionalMeanData;
                                        regionalLats = uniqueLats;
                                        datasetName = 'JPL Mascon';
                                    end

                                    %% CSR (mascon)
                                case 'csr'
                                    [CSR_masked, latCSR, lonCSR] = applyBasinMaskWithCoords(app, ...
                                        app.CSRTWSData, app.CSRTWSLat, app.CSRTWSLon);

                                    if ~isempty(CSR_masked)
                                        CSR_REC = NaN(size(latCSR,1), 1500);
                                        CSR_REC(:, app.CSRTWSMN) = 10 * CSR_masked;

                                        CSR_selected = CSR_REC(:, x);

                                        [uniqueLats, ~, idx] = unique(latCSR);
                                        regionalMeanData = zeros(length(uniqueLats), length(x));

                                        for j = 1:length(uniqueLats)
                                            latMask = (latCSR == uniqueLats(j));
                                            regionalMeanData(j, :) = mean(CSR_selected(latMask, :), 1, 'omitnan');
                                        end

                                        regionalData = regionalMeanData;
                                        regionalLats = uniqueLats;
                                        datasetName = 'CSR Mascon';
                                    end

                                    %% GSFC (mascon)
                                case 'gsfc'
                                    [GSFC_masked, latGSFC, lonGSFC] = applyBasinMaskWithCoords(app, ...
                                        app.GFSCTWSData, app.GFSCTWSLat, app.GFSCTWSLon);

                                    if ~isempty(GSFC_masked)
                                        GSFC_REC = NaN(size(latGSFC,1), 1500);
                                        GSFC_REC(:, app.GFSCTWSMN) = 10 * GSFC_masked;

                                        GSFC_selected = GSFC_REC(:, x);

                                        [uniqueLats, ~, idx] = unique(latGSFC);
                                        regionalMeanData = zeros(length(uniqueLats), length(x));

                                        for j = 1:length(uniqueLats)
                                            latMask = (latGSFC == uniqueLats(j));
                                            regionalMeanData(j, :) = mean(GSFC_selected(latMask, :), 1, 'omitnan');
                                        end

                                        regionalData = regionalMeanData;
                                        regionalLats = uniqueLats;
                                        datasetName = 'GSFC Mascon';
                                    end
                            end

                            if ~isempty(regionalData)
                                break;
                            end
                        end
                    end

                    %% ==================== PROCESS THIS STUDY DATA ====================
                    if isempty(regionalData)
                        selectedNodes = app.This_Study.CheckedNodes;
                        for i = 1:numel(selectedNodes)
                            if ~isempty(selectedNodes(i).Children), continue; end

                            rawName = strtrim(selectedNodes(i).Text);
                            nodeKey = lower(rawName);

                            switch nodeKey
                                %% BEST
                                case 'rf_imd'
                                    [Best_masked, latBest, lonBest] = applyBasinMaskWithCoords(app, ...
                                        app.ThisStudyBestData, app.ThisStudyBestLat, app.ThisStudyBestLon);

                                    if ~isempty(Best_masked)
                                        Best_REC = NaN(size(latBest,1), 1500);
                                        Best_REC(:, app.ThisStudyBestMN) = Best_masked;

                                        Best_selected = Best_REC(:, x);

                                        [uniqueLats, ~, idx] = unique(latBest);
                                        regionalMeanData = zeros(length(uniqueLats), length(x));

                                        for j = 1:length(uniqueLats)
                                            latMask = (latBest == uniqueLats(j));
                                            regionalMeanData(j, :) = mean(Best_selected(latMask, :), 1, 'omitnan');
                                        end

                                        regionalData = regionalMeanData;
                                        regionalLats = uniqueLats;
                                        datasetName = 'RF_IMD (This Study)';
                                    end

                                    %% ANN
                                case 'ann_g'
                                    [ANN_masked, latANN, lonANN] = applyBasinMaskWithCoords(app, ...
                                        app.ThisStudyANNData, app.ThisStudyANNLat, app.ThisStudyANNLon);

                                    if ~isempty(ANN_masked)
                                        ANN_REC = NaN(size(latANN,1), 1500);
                                        ANN_REC(:, app.ThisStudyANNMN) = ANN_masked;

                                        ANN_selected = ANN_REC(:, x);

                                        [uniqueLats, ~, idx] = unique(latANN);
                                        regionalMeanData = zeros(length(uniqueLats), length(x));

                                        for j = 1:length(uniqueLats)
                                            latMask = (latANN == uniqueLats(j));
                                            regionalMeanData(j, :) = mean(ANN_selected(latMask, :), 1, 'omitnan');
                                        end

                                        regionalData = regionalMeanData;
                                        regionalLats = uniqueLats;
                                        datasetName = 'ANN_GLDAS (This Study)';
                                    end

                                    %% LSTM
                                case 'ann_imd'
                                    [LSTM_masked, latLSTM, lonLSTM] = applyBasinMaskWithCoords(app, ...
                                        app.ThisStudyLSTMData, app.ThisStudyLSTMLat, app.ThisStudyLSTMLon);

                                    if ~isempty(LSTM_masked)
                                        LSTM_REC = NaN(size(latLSTM,1), 1500);
                                        LSTM_REC(:, app.ThisStudyLSTMMN) = LSTM_masked;

                                        LSTM_selected = LSTM_REC(:, x);

                                        [uniqueLats, ~, idx] = unique(latLSTM);
                                        regionalMeanData = zeros(length(uniqueLats), length(x));

                                        for j = 1:length(uniqueLats)
                                            latMask = (latLSTM == uniqueLats(j));
                                            regionalMeanData(j, :) = mean(LSTM_selected(latMask, :), 1, 'omitnan');
                                        end

                                        regionalData = regionalMeanData;
                                        regionalLats = uniqueLats;
                                        datasetName = 'ANN_IMD (This Study)';
                                    end

                                    %% RF
                                case 'rf_g'
                                    [RF_masked, latRF, lonRF] = applyBasinMaskWithCoords(app, ...
                                        app.ThisStudyRFData, app.ThisStudyRFLat, app.ThisStudyRFLon);

                                    if ~isempty(RF_masked)
                                        RF_REC = NaN(size(latRF,1), 1500);
                                        RF_REC(:, app.ThisStudyRFMN) = RF_masked;

                                        RF_selected = RF_REC(:, x);

                                        [uniqueLats, ~, idx] = unique(latRF);
                                        regionalMeanData = zeros(length(uniqueLats), length(x));

                                        for j = 1:length(uniqueLats)
                                            latMask = (latRF == uniqueLats(j));
                                            regionalMeanData(j, :) = mean(RF_selected(latMask, :), 1, 'omitnan');
                                        end

                                        regionalData = regionalMeanData;
                                        regionalLats = uniqueLats;
                                        datasetName = 'RF_GLDAS (This Study)';
                                    end
                            end

                            if ~isempty(regionalData)
                                break;
                            end
                        end
                    end


                    %% ==================== CREATE REGIONAL MEAN CONTOUR PLOT ====================
                    if ~isempty(regionalData) && ~isempty(regionalLats)
                        % Convert datetime to simple year numbers
                        if isdatetime(selectedTimeRange)
                            numericTime = year(selectedTimeRange);
                        else
                            numericTime = double(selectedTimeRange);
                        end

                        % Ensure other variables are numeric
                        regionalLats = double(regionalLats);
                        regionalData = double(regionalData);


                        % Replace NaN with a sentinel value outside data range
                        dataMin = min(regionalData(:), [], 'omitnan');
                        dataMax = max(regionalData(:), [], 'omitnan');
                        maskValue = 0; %dataMin - 999; % something way below min

                        regionalDataMasked = regionalData;
                        % regionalDataMasked(isnan(regionalData)) = maskValue;

                        [T, L] = meshgrid(x, regionalLats);
                        % Clear the axes before plotting
                        cla(app.UIAxes);

                        % Ensure the axes are held correctly
                        hold(app.UIAxes, 'on');
                        contourf(app.UIAxes, T, L, regionalDataMasked, 5, 'LineStyle', 'none');
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
                        colorbar(app.UIAxes);
                        % --- Symmetric color axis ---

                        cabs = max(abs([dataMin dataMax]));
                        clim(app.UIAxes, [-cabs cabs]);



                        xlabel(app.UIAxes, 'Time (Years)', 'FontSize', 12, 'FontName', 'Times New Roman');
                        ylabel(app.UIAxes, 'Latitude', 'FontSize', 12, 'FontName', 'Times New Roman');
                        title(app.UIAxes, ['Regional Mean Plot - ' datasetName], 'FontSize', 14, 'FontName', 'Times New Roman');

                        app.UIAxes.FontName = 'Times New Roman';
                        app.UIAxes.FontSize = 11;
                        grid(app.UIAxes, 'on');
                        drawnow;


                        % Ensure the axes are held correctly
                        hold(app.UIAxes, 'off');

                    else
                        % No data selected or no data in basin
                        % Clear previous text
                        cla(app.UIAxes, 'reset');

                        % Hold off so text is centered cleanly
                        hold(app.UIAxes, 'off');

                        % Set normalized coordinate system
                        text(app.UIAxes, 0.5, 0.5, ...
                            'No data available for selected basin or no dataset selected', ...
                            'Units', 'normalized', ...  % <<< KEY FIX
                            'HorizontalAlignment', 'center', ...
                            'VerticalAlignment', 'middle', ...
                            'FontSize', 14, ...
                            'FontName', 'Times New Roman', ...
                            'FontWeight', 'bold');

                        % Optionally remove tick marks for cleaner look
                        app.UIAxes.XTick = [];
                        app.UIAxes.YTick = [];
                        title(app.UIAxes, '');
                        xlabel(app.UIAxes, '');
                        ylabel(app.UIAxes, '');

                    end

                    hold(app.UIAxes, 'off');

            end
        end