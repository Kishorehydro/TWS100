function readAndPlotSensitivityAnalysis(app, analysisType)
            % Read Excel file and create tornado plot for sensitivity analysis
            % based on the analysis type

            try
                % Determine the file path based on analysis type
                if strcmp(analysisType, 'basin_average')
                    filename = './SHAP_Analysis_Results_BasinAverage.xlsx';
                    plotTitle = 'Sensitivity Analysis - Basin Average';
                else
                    filename = './SHAP_Analysis_Results_AllPoints_Basin.xlsx';
                    plotTitle = 'Sensitivity Analysis - All Points';
                end

                % Check if file exists
                if ~isfile(filename)
                    error('Sensitivity analysis file not found: %s', filename);
                end

                % Read the Excel file
                data = readtable(filename);

                % Extract data for tornado plot
                pointNames = data.Point; % First column contains point names
                featureData = data{:, 2:end}; % Remaining columns contain feature data
                featureNames = data.Properties.VariableNames(2:end);

                % Create tornado plot
                createTornadoPlot(app, pointNames, featureData, featureNames, plotTitle);

                disp(['Sensitivity analysis plot created for: ', analysisType]);

            catch ME
                errorMsg = sprintf('Error reading sensitivity analysis file: %s', ME.message);
                uialert(app.UIFigure, errorMsg, 'File Read Error');
                rethrow(ME);
            end
        end