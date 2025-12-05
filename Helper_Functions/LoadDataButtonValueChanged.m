function LoadDataButtonValueChanged(app, event)
            % value = app.LoadDataButton.Value;
            % Get screen size [x y width height]
            % screenSize = get(0,'ScreenSize');
            %
            % % Design size (from your UIFigure in Design View)
            % designWidth = 1212;
            % designHeight = 764;
            %
            % % Compute scale factor relative to screen size
            % scale = min(screenSize(3)/designWidth, screenSize(4)/designHeight);
            %
            % % Apply new scaled size (use 85% of available screen for safety)
            % newWidth = round(designWidth * scale* 0.85);%* 0.85
            % newHeight = round(designHeight * scale* 0.85);
            %
            % % Update UIFigure size
            % app.UIFigure.Position = [50 50 newWidth newHeight];
            %
            % % Center the app
            % movegui(app.UIFigure, 'onscreen');


            % Set auto-resize behavior
            %app.UIFigure.AutoResizeChildren = 'on';

            % % Set normalized units for axes to make them responsive
            % app.UIAxes.Units = 'normalized';
            % app.UIAxes.Position = [0.1 0.25 0.85 0.75]; % Adjust as needed
            % This function loads all required datasets into the app properties
            % Ensure to set the correct paths and variable names for each dataset
            % Path settings (update these paths as needed)
            IMDFile =  "./Data/Precipitation/IMD/IMD_Precipitation_1901_2023_Godavari.nc";
            GPCPFile = "./Data/Precipitation/GPCP/GPCP_total_precipitation_monthly_Godavari.nc";
            ERA5File = "./Data/Precipitation/ERA5/ERA5_total_precipitation_monthly_Godavari_1951_2023.nc";

            timename = 'time';

            % Get NetCDF info
            infoIMD = ncinfo(IMDFile);

            % Find time variable
            timeVarIMD = infoIMD.Variables(strcmp({infoIMD.Variables.Name}, timename));

            % Read time values
            timeIMD = ncread(IMDFile, timename);

            % Get units attribute
            timeUnitsIMD = '';
            for i = 1:length(timeVarIMD.Attributes)
                if strcmpi(timeVarIMD.Attributes(i).Name, 'units')
                    timeUnitsIMD = timeVarIMD.Attributes(i).Value;
                    break;
                end
            end

            % --- Convert to MATLAB datetime ---
            if contains(timeUnitsIMD, 'since', 'IgnoreCase', true)
                parts = regexp(timeUnitsIMD, 'since\s*([\d-]+)', 'tokens', 'once');
                if ~isempty(parts)
                    baseDateIMD = datetime(parts{1}, 'InputFormat', 'yyyy-MM-dd');

                    if contains(timeUnitsIMD, 'days', 'IgnoreCase', true)
                        app.IMD_datetime = baseDateIMD + days(timeIMD);
                    else
                        error('Unsupported time units for IMD data: %s', timeUnitsIMD);
                    end
                else
                    error('Failed to parse base date from time units: %s', timeUnitsIMD);
                end
            else
                error('Time units not recognized or missing in the NetCDF file.');
            end

            baseDir = fullfile('Data', 'Reconstructed_TWSA', 'Humphrey_2019');
            Hp_GHFile = fullfile(baseDir, 'modified_GRACE_REC_v03_G_E_monthly_ensemble_mean_Godavari.nc');
            Hp_GGFile = fullfile(baseDir, 'modified_GRACE_REC_v03_GSFC_GSWP3_monthly_ensemble_mean_Godavari.nc');
            Hp_GMFile = fullfile(baseDir, 'modified_GRACE_REC_v03_GSFC_MSWEP_monthly_ensemble_mean_Godavari.nc');
            Hp_JEFile = fullfile(baseDir, 'modified_GRACE_REC_v03_J_E_monthly_ensemble_mean_Godavari.nc');
            Hp_JGFile = fullfile(baseDir, 'modified_GRACE_REC_v03_JPL_GSWP3_monthly_ensemble_mean_Godavari.nc');
            Hp_JMFile = fullfile(baseDir, 'modified_GRACE_REC_v03_JPL_MSWEP_monthly_ensemble_mean_Godavari.nc');

            %YinRECFile = 'D:\IITR_ISRO_PhD\Reconstruction\Yin_REC.nc';
            %LiRECFile = 'D:\IITR_ISRO_PhD\Reconstruction\Li_REC.nc';
            JPLFile = "./Data/GRACE/JPL/GRCTellus.JPL.200204_202501.GLO.RL06.3M.MSCNv04CRI_Godavari.nc";
            CSRFile = "./Data/GRACE/CSR/CSR_GRACE_GRACE-FO_RL0603_Mascons_all-corrections_Godavari.nc";
            GFSCFile = "./Data/GRACE/GFSC/GSFC_200204_202410_Godavari.nc";

            try
                % Load IMD data
                [app.IMDData, app.IMDTime, app.IMDLat, app.IMDLon,app.IMDMN] = loadNetCDFData(app,IMDFile, 'RAINFALL','LATITUDE','LONGITUDE','time');
                %disp('IMD Precipitation data successfully loaded');%disp(size(app.IMDData));disp(max(size(app.IMDLon)));disp(size(app.IMDLat))
                % Load GPCP data
                [app.GPCPData, app.GPCPTime, app.GPCPLat, app.GPCPLon,app.GPCPMN] = app.loadNetCDFData(GPCPFile, 'precip','lat','lon','time');
                %disp('GPCP Precipitation data successfully loaded');
                % Load ERA5 data
                [app.ERA5Data, app.ERA5Time, app.ERA5Lat, app.ERA5Lon,app.ERA5MN] = app.loadNetCDFData(ERA5File, 'tp','latitude','longitude','time');
                %disp('ERA5 Precipitation data successfully loaded');
                %Load Humphrey reconstruction data
                [app.Hp_GERECData, app.Hp_GERECTime, app.Hp_GERECLat, app.Hp_GERECLon, app.Hp_GERECMN] = app.loadNetCDFData(Hp_GHFile, 'TWS','lat','lon','time');
                [app.Hp_GGRECData, app.Hp_GGRECTime, app.Hp_GGRECLat, app.Hp_GGRECLon, app.Hp_GGRECMN] = app.loadNetCDFData(Hp_GGFile, 'TWS','lat','lon','time');
                [app.Hp_GMRECData, app.Hp_GMRECTime, app.Hp_GMRECLat, app.Hp_GMRECLon, app.Hp_GMRECMN] = app.loadNetCDFData(Hp_GMFile, 'TWS','lat','lon','time');
                [app.Hp_JERECData, app.Hp_JERECTime, app.Hp_JERECLat, app.Hp_JERECLon, app.Hp_JERECMN] = app.loadNetCDFData(Hp_JEFile, 'TWS','lat','lon','time');
                [app.Hp_JGRECData, app.Hp_JGRECTime, app.Hp_JGRECLat, app.Hp_JGRECLon, app.Hp_JGRECMN] = app.loadNetCDFData(Hp_JGFile, 'TWS','lat','lon','time');
                [app.Hp_JMRECData, app.Hp_JMRECTime, app.Hp_JMRECLat, app.Hp_JMRECLon, app.Hp_JMRECMN] = app.loadNetCDFData(Hp_JMFile, 'TWS','lat','lon','time');
                %disp('Humphrey Reconstructed data successfully loaded');


                % Deng 2023
                DengFile = "./Data/Reconstructed_TWSA/Deng_2023/Deng_Godavari.nc";
                [app.DengRECData, app.DengRECTime, app.DengRECLat, app.DengRECLon, app.DengRECMN] = ...
                    app.loadNetCDFData(DengFile, 'twsa_rec','lat','lon','time');
                %disp('Deng 2023 reconstruction successfully loaded');

                % Li 2021"F:\GUI_and_Data\Data\Reconstructed_TWSA\Li_2021\GRACE_REC_Li_Godavari.nc"
                LiFile = "./Data/Reconstructed_TWSA/Li_2021/GRACE_REC_Li_Godavari.nc";
                [app.LiRECData, app.LiRECTime, app.LiRECLat, app.LiRECLon, app.LiRECMN] = ...
                    app.loadNetCDFData(LiFile, 'lwe_thickness','lat','lon','time');
                %disp('Li 2021 reconstruction successfully loaded');

                % Mandal 2025
                MandalFile = "./Data/Reconstructed_TWSA/Mandal_2025/BNML_TWSA_Global_Godavari.nc";
                [app.MandalRECData, app.MandalRECTime, app.MandalRECLat, app.MandalRECLon, app.MandalRECMN] = ...
                    app.loadNetCDFData(MandalFile, 'bnml_twsa','lat','lon','time');
                %disp('Mandal 2025 reconstruction successfully loaded');

                % Palazzoli 2025 - multiple models
                PalazzoliFile1 = "./Data/Reconstructed_TWSA/Palazzoli_2025/GRAiCE_LSTM_Godavari.nc";
                [app.PalazzoliLSTMData, app.PalazzoliLSTMTime, app.PalazzoliLSTMLat, app.PalazzoliLSTMLon, app.PalazzoliLSTMMN] = ...
                    app.loadNetCDFData(PalazzoliFile1, 'TWSA','lat','lon','time');
                %disp('Palazzoli 2025 LSTM successfully loaded');

                PalazzoliFile2 = "./Data/Reconstructed_TWSA/Palazzoli_2025/GRAiCE_LSTMnoLCSIF_Godavari.nc";
                [app.PalazzoliLSTMnoLCSIFData, app.PalazzoliLSTMnoLCSIFTime, app.PalazzoliLSTMnoLCSIFLat, app.PalazzoliLSTMnoLCSIFLon, app.PalazzoliLSTMnoLCSIFMN] = ...
                    app.loadNetCDFData(PalazzoliFile2, 'TWSA','lat','lon','time');
                %disp('Palazzoli 2025 LSTM-noLCSIF successfully loaded');

                PalazzoliFile3 = "./Data/Reconstructed_TWSA/Palazzoli_2025/Palazzoli_BiLSTM_Godavari.nc";
                [app.PalazzoliBiLSTMData, app.PalazzoliBiLSTMTime, app.PalazzoliBiLSTMLat, app.PalazzoliBiLSTMLon, app.PalazzoliBiLSTMMN] = ...
                    app.loadNetCDFData(PalazzoliFile3, 'TWSA','lat','lon','time');
                %disp('Palazzoli 2025 BiLSTM successfully loaded');

                PalazzoliFile4 = "./Data/Reconstructed_TWSA/Palazzoli_2025/GRAiCE_BiLSTMnoLCSIF_Godavari.nc";
                [app.PalazzoliBiLSTMnoLCSIFData, app.PalazzoliBiLSTMnoLCSIFTime, app.PalazzoliBiLSTMnoLCSIFLat, app.PalazzoliBiLSTMnoLCSIFLon, app.PalazzoliBiLSTMnoLCSIFMN] = ...
                    app.loadNetCDFData(PalazzoliFile4, 'TWSA','lat','lon','time');
                %disp('Palazzoli 2025 BiLSTM-noLCSIF successfully loaded');

                % ================= THIS STUDY (4 models) =================
                % Best
                ThisStudyFile1 = "./Data/This_Study/RTWSA_GRACE_IMD_RF_Godavari.nc";
                [app.ThisStudyBestData, app.ThisStudyBestTime, app.ThisStudyBestLat, app.ThisStudyBestLon, app.ThisStudyBestMN] = ...
                    app.loadNetCDFData(ThisStudyFile1, 'TWSA','lat','lon','time');
                %disp('This Study - GRACE Best successfully loaded');

                % ANN
                ThisStudyFile2 = "./Data/This_Study/RTWSA_GRACE_ANN_Godavari.nc";
                [app.ThisStudyANNData, app.ThisStudyANNTime, app.ThisStudyANNLat, app.ThisStudyANNLon, app.ThisStudyANNMN] = ...
                    app.loadNetCDFData(ThisStudyFile2, 'TWSA','lat','lon','time');
                %disp('This Study - GRACE ANN successfully loaded');

                % LSTM
                ThisStudyFile3 = "./Data/This_Study/RTWSA_GRACE_IMD_ANN_Godavari.nc";
                [app.ThisStudyLSTMData, app.ThisStudyLSTMTime, app.ThisStudyLSTMLat, app.ThisStudyLSTMLon, app.ThisStudyLSTMMN] = ...
                    app.loadNetCDFData(ThisStudyFile3, 'TWSA','lat','lon','time');
                %disp('This Study - GRACE LSTM successfully loaded');

                % RF
                ThisStudyFile4 = "./Data/This_Study/RTWSA_GRACE_RF_Godavari.nc";
                [app.ThisStudyRFData, app.ThisStudyRFTime, app.ThisStudyRFLat, app.ThisStudyRFLon, app.ThisStudyRFMN] = ...
                    app.loadNetCDFData(ThisStudyFile4, 'TWSA','lat','lon','time');
                %disp('This Study - GRACE RF successfully loaded');

                % Load GRACE JPL TWS data
                [app.JPLTWSData, app.JPLTWSTime, app.JPLTWSLat, app.JPLTWSLon, app.JPLTWSMN] = app.loadNetCDFData(JPLFile,'lwe_thickness','lat','lon','time');
                %disp('JPL data successfully loaded');
                % Load GRACE CSR TWS data
                [app.CSRTWSData, app.CSRTWSTime, app.CSRTWSLat, app.CSRTWSLon, app.CSRTWSMN] = app.loadNetCDFData(CSRFile, 'lwe_thickness','lat','lon','time');
                %disp('CSR data successfully loaded');%disp(app.CSRTWSMN)
                % Load GRACE GSFZ TWS data
                [app.GFSCTWSData, app.GFSCTWSTime, app.GFSCTWSLat, app.GFSCTWSLon, app.GFSCTWSMN] = app.loadNetCDFData(GFSCFile,'lwe_thickness','lat','lon','time');
                %disp('GFSC data successfully loaded');
                % Load shapefile
                % Specify the path to the shapefile
                shapefilePath = "./Data/River_Shps/Indian_river_shps.shp";
                % Load the shapefile
                app.Basins = shaperead(shapefilePath);
                % GLDAS file path
                GLDASFile = "./Data/GLDAS/GLDAS_NOAH_1948_2024_JPLgrid_Godavari.nc";

                % Load GLDAS Precipitation data
                [app.GLDAS_PData, app.GLDAS_PTime, app.GLDAS_PLat, app.GLDAS_PLon, app.GLDAS_PMN] = ...
                    app.loadNetCDFData(GLDASFile, 'Rainf_f_tavg', 'lat', 'lon', 'time');
                %disp('GLDAS Precipitation data successfully loaded');
                % disp(size(app.GLDAS_PData))
                % Load GLDAS Evapotranspiration data
                [app.GLDAS_ETData, app.GLDAS_ETTime, app.GLDAS_ETLat, app.GLDAS_ETLon, app.GLDAS_ETMN] = ...
                    app.loadNetCDFData(GLDASFile, 'Evap_tavg', 'lat', 'lon', 'time');
                %disp('GLDAS Evapotranspiration data successfully loaded');

                % Load GLDAS Soil Moisture data
                [app.GLDAS_SMData, app.GLDAS_SMTime, app.GLDAS_SMLat, app.GLDAS_SMLon, app.GLDAS_SMMN] = ...
                    app.loadNetCDFData(GLDASFile, 'Soil_Moisture', 'lat', 'lon', 'time');
                %disp('GLDAS Soil Moisture data successfully loaded');

                % Load GLDAS Air Temperature data
                [app.GLDAS_TData, app.GLDAS_TTime, app.GLDAS_TLat, app.GLDAS_TLon, app.GLDAS_TMN] = ...
                    app.loadNetCDFData(GLDASFile, 'Tair_f_inst', 'lat', 'lon', 'time');
                %disp('GLDAS Air Temperature data successfully loaded');

                % Load GLDAS Wind Speed data
                [app.GLDAS_WSData, app.GLDAS_WSTime, app.GLDAS_WSLat, app.GLDAS_WSLon, app.GLDAS_WSMN] = ...
                    app.loadNetCDFData(GLDASFile, 'Wind_f_inst', 'lat', 'lon', 'time');
                %disp('GLDAS Wind Speed data successfully loaded');

                % Load GLDAS Specific Humidity data
                [app.GLDAS_SHData, app.GLDAS_SHTime, app.GLDAS_SHLat, app.GLDAS_SHLon, app.GLDAS_SHMN] = ...
                    app.loadNetCDFData(GLDASFile, 'Qair_f_inst', 'lat', 'lon', 'time');
                %disp('GLDAS Specific Humidity data successfully loaded');

                % Load GLDAS Longwave Radiation data
                [app.GLDAS_LWData, app.GLDAS_LWTime, app.GLDAS_LWLat, app.GLDAS_LWLon, app.GLDAS_LWMN] = ...
                    app.loadNetCDFData(GLDASFile, 'LWdown_f_tavg', 'lat', 'lon', 'time');
                %disp('GLDAS Longwave Radiation data successfully loaded');

                % Load GLDAS Shortwave Radiation data
                [app.GLDAS_SWData, app.GLDAS_SWTime, app.GLDAS_SWLat, app.GLDAS_SWLon, app.GLDAS_SWMN] = ...
                    app.loadNetCDFData(GLDASFile, 'SWdown_f_tavg', 'lat', 'lon', 'time');

                % % Load GLDAS Snowwater equivalent data
                % [app.GLDAS_SWeData, app.GLDAS_SWeime, app.GLDAS_SWeLat, app.GLDAS_SWeLon, app.GLDAS_SWeMN] = ...
                %     app.loadNetCDFData(GLDASFile, 'SWE_inst', 'lat', 'lon', 'time');
                %
                %                 % Load GLDAS Shortwave Radiation data
                % [app.GLDAS_CWData, app.GLDAS_CWTime, app.GLDAS_CWLat, app.GLDAS_CWLon, app.GLDAS_CWMN] = ...
                %     app.loadNetCDFData(GLDASFile, 'SWdown_f_tavg', 'lat', 'lon', 'time');
                %disp('GLDAS Shortwave Radiation data successfully loaded');

                % Read NetCDF info
                info1 = ncinfo(JPLFile);

                % Find time variable
                timeVar = info1.Variables(strcmp({info1.Variables.Name}, timename));

                % Read time values
                time = ncread(JPLFile, timename);

                % Get units attribute
                timeUnits = '';
                for i = 1:length(timeVar.Attributes)
                    if strcmpi(timeVar.Attributes(i).Name, 'units')
                        timeUnits = timeVar.Attributes(i).Value;
                        break;
                    end
                end

                % --- Convert to MATLAB datetime ---
                if contains(timeUnits, 'since', 'IgnoreCase', true)
                    % Extract reference date
                    parts = regexp(timeUnits, 'since\s*([\d-]+)', 'tokens', 'once');
                    if ~isempty(parts)
                        baseDate = datetime(parts{1}, 'InputFormat', 'yyyy-MM-dd');

                        % Handle different units
                        if contains(timeUnits, 'days', 'IgnoreCase', true)
                            app.JPL_datetime = baseDate + days(time);
                        elseif contains(timeUnits, 'months', 'IgnoreCase', true)
                            app.JPL_datetime = baseDate + calmonths(time);
                        elseif contains(timeUnits, 'years', 'IgnoreCase', true)
                            % Fractional years -> convert to months/days
                            yearsInt = floor(time);
                            yearsFrac = time - yearsInt;
                            app.JPL_datetime = baseDate + calyears(yearsInt) + days(yearsFrac*365.25);
                        else
                            error('Unsupported time units: %s', timeUnits);
                        end
                    else
                        error('Failed to parse base date from time units: %s', timeUnits);
                    end
                else
                    error('Time units not recognized or missing in the NetCDF file.');
                end



                % Get info
                info2 = ncinfo(GLDASFile);

                % Find time variable
                timeVar = info2.Variables(strcmp({info2.Variables.Name}, timename));

                % Read time values
                time = ncread(GLDASFile, timename);

                % Get units attribute
                timeUnits = '';
                for i = 1:length(timeVar.Attributes)
                    if strcmpi(timeVar.Attributes(i).Name, 'units')
                        timeUnits = timeVar.Attributes(i).Value;
                        break;
                    end
                end

                % --- Convert to MATLAB datetime ---
                if contains(timeUnits, 'since', 'IgnoreCase', true)
                    % Extract reference date
                    parts = regexp(timeUnits, 'since\s*([\d-]+)', 'tokens', 'once');
                    if ~isempty(parts)
                        baseDate = datetime(parts{1}, 'InputFormat', 'yyyy-MM-dd');

                        % Handle different units
                        if contains(timeUnits, 'days', 'IgnoreCase', true)
                            app.GLDAS_datetime = baseDate + days(time);
                        elseif contains(timeUnits, 'hours', 'IgnoreCase', true)
                            app.GLDAS_datetime = baseDate + hours(time);
                        elseif contains(timeUnits, 'minutes', 'IgnoreCase', true)
                            app.GLDAS_datetime = baseDate + minutes(time);
                        elseif contains(timeUnits, 'months', 'IgnoreCase', true)
                            app.GLDAS_datetime = baseDate + calmonths(time);
                        elseif contains(timeUnits, 'years', 'IgnoreCase', true)
                            % Fractional years -> convert to days
                            yearsInt = floor(time);
                            yearsFrac = time - yearsInt;
                            app.GLDAS_datetime = baseDate + calyears(yearsInt) + days(yearsFrac*365.25);
                        else
                            error('Unsupported time units: %s', timeUnits);
                        end
                    else
                        error('Failed to parse base date from time units: %s', timeUnits);
                    end
                else
                    error('Time units not recognized or missing in the NetCDF file.');
                end

                % Notify the user that the data loading is complete
                %disp('All datasets have been successfully loaded.');
                uialert(app.UIFigure, 'Data Loading Completed', 'Success', 'Icon', 'success');
            catch ME
                % Display error message if something goes wrong
                %disp(['Error loading data: ', ME.message]);
                uialert(app.UIFigure, 'Data Loading Failed', "Invalid File","Icon","error");
            end

            try
                excelFile = "./Data/CGWB/OB_Wells_Godavari.xlsx"; % Update path as needed
                app.CGWBData = readtable(excelFile);

                % Extract year columns (2002 to 2018)
                yearCols = [];
                years = [];
                for i = 1:width(app.CGWBData)
                    colName = app.CGWBData.Properties.VariableNames{i};
                    yearMatch = regexp(colName, '\d{4}', 'match');
                    if ~isempty(yearMatch)
                        year = str2double(yearMatch{1});
                        if year >= 2002 && year <= 2018
                            yearCols = [yearCols, i];
                            years = [years, year];
                        end
                    end
                end

                % Sort years and keep corresponding column indices
                [years, sortIdx] = sort(years);
                yearCols = yearCols(sortIdx);  % reorder columns accordingly

                % % Remove duplicates (keep first occurrence)
                % [years, uniqueIdx] = unique(years, 'stable');
                % yearCols = yearCols(uniqueIdx);  % drop corresponding duplicate columns

                % Extract the data for these columns
                T_data = app.CGWBData{:, yearCols};

                % Scale the data: 1000 * 0.05 * T_data
                T_scaled = 1000 * 0.05 * T_data;

                % Compute climatology (2004-2009)
                climYears = [2004, 2005, 2006, 2007, 2008, 2009];
                climIdx = ismember(years, climYears);
                T_clim = mean(T_scaled(:, climIdx), 2, 'omitnan');

                % Compute anomalies (well-wise)
                app.CGWBAnomalies = T_scaled - T_clim;

                % Average over wells
                app.CGWBAvg = mean(app.CGWBAnomalies, 1, 'omitnan');
                %disp(size(app.CGWBAvg))
                % Create datetime array for CGWB data (assuming seasonal measurements: Jan, May, Aug, Nov)
                % We create a date for each year and month: Jan (1), May (5), Aug (8), Nov (11)
                app.CGWBTime = [];
                app.CGWBLat = app.CGWBData{:, 'LAT'};
                app.CGWBLon = app.CGWBData{:, 'LON'};
                app.CGWBTime = datetime.empty;  % clear any old timestamps
                years = 2002:2018;  % 17 years
                for y = years
                    for m = [1,5,8,11]
                        app.CGWBTime = [app.CGWBTime; datetime(y,m,1)];
                    end
                end

                % disp(app.CGWBLat)
                % disp(length(app.CGWBAvg))
                %
                %                 disp(app.CGWBTime)
                % We have to match the number of time points to the number of columns in T_scaled
                % Since we have 4 measurements per year and 17 years (2002-2018), we have 68 time points.
                % But note: the Python code only uses 4 seasons per year, so we are creating 68 points.
                % However, the years might not all have 4 measurements? We assume they do.

            catch ME
                warning(ME.identifier,'Could not load CGWB data: %s', ME.message);
            end

        end