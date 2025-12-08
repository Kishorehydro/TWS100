function plotSpatialSideBySide(app)
    % Make both axes visible and adjust positions
    app.UIAxes2.Visible = 'on';
    app.UIAxes.Position = [0.08 0.25 0.4 0.65];
    app.UIAxes2.Position = [0.54 0.25 0.4 0.65];

    % Plot GRACE on left axes
    app.plotGRACE_Spatial();
    title(app.UIAxes, 'GRACE TWSA Spatial Distribution');

    % Plot CGWB on right axes
    cla(app.UIAxes2);
    app.plotCGWB_Spatial();
    title(app.UIAxes2, 'CGWB Well Locations');
end