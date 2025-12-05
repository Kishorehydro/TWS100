function [data, time, lat, lon, mappedTime] = loadNetCDFData(app, filepath, varname, latname, longname, timename)
            % Load data, coordinates, and convert NetCDF time to MATLAB datetime

            % Initialize outputs to avoid returning nothing after errors
            data = [];
            time = [];
            lat = [];
            lon = [];
            mappedTime = [];

            try
                % Load main variable and coordinates
                data = ncread(filepath, varname);
                lat  = ncread(filepath, latname);
                lon  = ncread(filepath, longname);
                rawTime = ncread(filepath, timename);

                % Clear UIAxes
                cla(app.UIAxes);

                % Get time units attribute
                info = ncinfo(filepath);
                varIndex = strcmp({info.Variables.Name}, timename);

                if ~any(varIndex)
                    errordlg(sprintf('Time variable "%s" not found in file.', timename));
                    return;
                end

                timeVar = info.Variables(varIndex);

                % Extract time units
                timeUnits = '';
                for i = 1:length(timeVar.Attributes)
                    if strcmpi(timeVar.Attributes(i).Name, 'units')
                        timeUnits = timeVar.Attributes(i).Value;
                        break;
                    end
                end

                if isempty(timeUnits)
                    errordlg('Time units attribute missing in NetCDF file.');
                    return;
                end

                % Parse base date
                if contains(timeUnits, 'since', 'IgnoreCase', true)
                    tokens = regexp(timeUnits, 'since\s*(\d{4}-\d{2}-\d{2})', 'tokens', 'once');
                    if isempty(tokens)
                        errordlg(sprintf('Unable to parse base date from units: %s', timeUnits));
                        return;
                    end
                    baseDate = datetime(tokens{1}, 'InputFormat','yyyy-MM-dd');
                else
                    errordlg(sprintf('Unsupported time unit format: %s', timeUnits));
                    return;
                end

                % Convert raw time values to MATLAB datetime
                if contains(timeUnits, 'days', 'IgnoreCase', true)
                    time = baseDate + days(rawTime);
                elseif contains(timeUnits, 'hours', 'IgnoreCase', true)
                    time = baseDate + hours(rawTime);
                elseif contains(timeUnits, 'minutes', 'IgnoreCase', true)
                    time = baseDate + minutes(rawTime);
                elseif contains(timeUnits, 'seconds', 'IgnoreCase', true)
                    time = baseDate + seconds(rawTime);
                else
                    errordlg(sprintf('Unsupported time step units in file: %s', timeUnits));
                    return;
                end

                % Create MM-yyyy formatted strings
                timeFormatted = string(datestr(time, 'mm-yyyy'));

                % Build mapping range 1901–2100
                startDate = datetime(1901,1,1);
                endDate   = datetime(2100,12,1);
                allMonths = startDate : calmonths(1) : endDate;
                allMonthStrings = string(datestr(allMonths, 'mm-yyyy'));

                % Map to indices
                mappedTime = arrayfun(@(t) find(allMonthStrings == t, 1,'first'), timeFormatted);

                if any(isnan(mappedTime))
                    errordlg('Some time values could not be mapped between 1901–2100.');
                end

            catch ME
                errordlg(sprintf('Error reading NetCDF file:\n\n%s', ME.message));
            end
        end