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
    L = model_params.length;
    W = model_params.width;
    strike_rad = model_params.strike * pi / 180;
    dip_rad = model_params.dip * pi / 180;
    % 断层上缘中点在地表的投影位置
    horizontal_offset = (W/2) * cos(dip_rad);
    top_center_x = -horizontal_offset * cos(strike_rad);
    top_center_y = horizontal_offset * sin(strike_rad);

    % 以断层上缘中点为中心，沿着走向方向计算迹线端点
    x_trace = [-L/2 * sin(strike_rad),  L/2 * sin(strike_rad)] + top_center_x;
    y_trace = [-L/2 * cos(strike_rad), L/2 * cos(strike_rad)] + top_center_y;
    % 
    plot(ax, x_trace, y_trace,'Color', config.fault.color, 'LineWidth', config.fault.line_width);

    % Mark the dip direction on the hanging wall  
    if model_params.dip ~= 90  % 仅对于非垂直断层
        plot([top_center_x, 0], [top_center_y, 0], '-', 'Color', config.fault.color, ...
            'LineWidth', config.fault.line_width, 'MarkerFaceColor', config.fault.color, ...
            'MarkerSize', config.fault.dip_marker_size);      
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
