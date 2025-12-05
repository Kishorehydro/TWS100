function createTornadoPlot(app, pointNames, featureData, featureNames, plotTitle)
    % Create tornado plot similar to SHAP analysis

    try
        % Create a new figure for the tornado plot
        fig = figure('Name', plotTitle, ...
            'NumberTitle', 'off', ...
            'Position', [100, 100, 1200, 800]);

        % Calculate absolute mean values for each feature across all points
        meanAbsValues = mean(abs(featureData), 1, 'omitnan');

        % Sort features by their absolute mean importance (descending)
        [sortedValues, sortIdx] = sort(meanAbsValues, 'descend');
        sortedFeatureNames = featureNames(sortIdx);

        % Create horizontal bar plot (proper tornado plot)
        subplot(1, 2, 1);
        
        % For tornado plot, we want highest values at top, lowest at bottom
        % So we reverse the order
        y = 1:length(sortedValues);
        if length(sortedValues) > 20
            topN = 20;
            barhValues = sortedValues(1:topN);
            barhFeatures = sortedFeatureNames(1:topN);
            y = 1:topN;
        else
            barhValues = sortedValues;
            barhFeatures = sortedFeatureNames;
            topN = length(sortedValues);
        end
        
        % Create the horizontal bars
        h = barh(y, barhValues);
        ylabel('Features');
        xlabel('Mean Absolute Value');
        title('Feature Importance (Tornado Plot)');
        
        % Set Y-axis properties for proper tornado plot appearance
        set(gca, 'YTick', y, 'YTickLabel', barhFeatures);
        set(gca, 'YDir', 'reverse'); % This puts highest values at top
        grid on;
        
        % Customize the bars
        h.FaceColor = 'flat';
        h.EdgeColor = 'blue';
        h.LineWidth = 0.5;
        
        % Add value labels on the bars
        for i = 1:length(barhValues)
            text(barhValues(i) + max(barhValues)*0.01, i, ...
                sprintf('%.3f', barhValues(i)), ...
                'FontSize', 8, 'VerticalAlignment', 'middle');
        end

        % Create a heatmap of values for detailed analysis
        subplot(1, 2, 2);

        % Use only top features for heatmap if there are too many
        if size(featureData, 2) > 20
            topFeatures = sortIdx(1:min(20, length(sortIdx)));
            heatmapData = featureData(:, topFeatures);
            heatmapFeatures = sortedFeatureNames(1:min(20, length(sortIdx)));
        else
            heatmapData = featureData(:, sortIdx);
            heatmapFeatures = sortedFeatureNames;
        end

        % Sort heatmap data by the same order as tornado plot
        heatmapData = heatmapData(:, 1:size(heatmapData, 2));
        
        % Create heatmap with proper orientation
        imagesc(heatmapData);
        colorbar;
        xlabel('Features');
        ylabel('Data Points');
        title('Feature Values Heatmap');
        colormap(jet); % Use jet colormap for better visibility

        % Set tick labels
        if length(heatmapFeatures) <= 30 % Only show labels if not too many
            set(gca, 'XTick', 1:length(heatmapFeatures), ...
                'XTickLabel', heatmapFeatures, ...
                'XTickLabelRotation', 45);
        end

        if length(pointNames) <= 50 % Only show point names if not too many
            set(gca, 'YTick', 1:length(pointNames), ...
                'YTickLabel', pointNames);
        end

        % Add overall title
        sgtitle(plotTitle, 'FontSize', 14, 'FontWeight', 'bold');

        % Add some statistics to the command window
        fprintf('\n--- Sensitivity Analysis Statistics ---\n');
        fprintf('Number of data points: %d\n', length(pointNames));
        fprintf('Number of features: %d\n', length(featureNames));
        fprintf('Top %d most important features:\n', min(5, topN));
        for i = 1:min(5, topN)
            fprintf('  %d. %s: %.4f\n', i, barhFeatures{i}, barhValues(i));
        end

    catch ME
        errorMsg = sprintf('Error creating tornado plot: %s', ME.message);
        uialert(app.UIFigure, errorMsg, 'Plot Error');
        rethrow(ME);
    end
end