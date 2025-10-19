function plot_Fault_Deformation(ax, current_fault, E, N, c_lim, figure_name, config)
    % --- Business Logic Plotting Function ---
    % This function knows about the 'Fault' data structure. Its job is to:
    % 1. Extract data from the fault structure.
    % 2. Call the generic `plot_Deformation_Map` to create the base plot.
    % 3. Add fault-specific elements (like the fault trace) on top.
    % 4. Set final titles and labels specific to this application.

    % Extract data for clarity
    deformation = current_fault.deformation;
    model_params = current_fault.model_parameters;

    % Call the generic plotting function to draw the data fields
    plot_3D_Field_Map(ax, E, N, deformation.uZ, deformation.uE, deformation.uN, c_lim, config);    
    hold(ax, 'on'); 
   
    % Fault trace
    L_half = model_params.length / 2;
    alpha = (90 - model_params.strike) * pi / 180;
    x_trace = [-L_half, L_half] * cos(alpha);
    y_trace = [-L_half, L_half] * sin(alpha);
    plot(ax, x_trace, y_trace, 'Color', config.fault.color, 'LineWidth', config.fault.line_width);
    
    % Mark the dip direction on the hanging wall
    if model_params.dip ~= 90
        dip_dir_x = 0.1 * L_half * sin(alpha);
        dip_dir_y = -0.1 * L_half * cos(alpha);
        plot(ax, [0, dip_dir_x], [0, dip_dir_y], 'v', 'Color', config.fault.color, ...
            'LineWidth', 2, 'MarkerFaceColor', config.fault.color, 'MarkerSize', config.fault.dip_marker_size);
    end

    % Axes
    axis(ax, 'equal');
    xlim(ax, [min(E(:)), max(E(:))]);
    ylim(ax, [min(N(:)), max(N(:))]);
    
    xlabel(ax, 'East (km)');
    ylabel(ax, 'North (km)');
    title(ax, figure_name, 'Interpreter', 'none', 'FontWeight', 'bold');
    
    hold(ax, 'off');
end
