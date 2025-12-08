function saveReconstructedTWSToExcel2D(app, reconstructed_tws, time_data, point_names, reconstructionType, lat_masked, lon_masked)
            % Save reconstructed TWSA to Excel - CORRECTED VERSION

            [n_time, n_points] = size(reconstructed_tws);

            if strcmp(reconstructionType, 'all_points')
                % For all points in the basin - create separate tables for coordinates and data
                excel_data = table();

                % Add coordinate columns
                excel_data.Latitude = lat_masked(:);
                excel_data.Longitude = lon_masked(:);

                % Add point names
                excel_data.PointName = point_names(:);

                % Add mean reconstructed TWSA across time
                excel_data.Mean_TWSA = mean(reconstructed_tws, 1, 'omitnan')';

                % Save coordinates table
                writetable(excel_data, 'Reconstructed_TWSA_RF_AllPoints_Coordinates.xlsx');

                % Save time series data separately
                time_series_data = table();
                time_series_data.Time = time_data;

                for point_idx = 1:n_points
                    time_series_data.(point_names{point_idx}) = reconstructed_tws(:, point_idx);
                end

                writetable(time_series_data, 'Reconstructed_TWSA_RF_AllPoints_TimeSeries.xlsx');

                fprintf('Reconstructed TWSA saved to separate coordinate and timeseries files\n');

            else
                % For basin average
                excel_data = table();
                excel_data.Time = time_data;
                excel_data.Basin_Average_TWSA = reconstructed_tws;

                % Add statistics
                excel_data.Month = month(time_data);
                excel_data.Year = year(time_data);

                filename = 'Reconstructed_TWSA_RF_BasinAverage.xlsx';
                writetable(excel_data, filename);
                fprintf('Reconstructed TWSA saved to %s\n', filename);
            end
        end