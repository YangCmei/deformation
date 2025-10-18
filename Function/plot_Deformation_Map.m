function plot_Deformation_Map(ax, E, N, uZ, uE, uN, c_lim, config)
    % --- Generic Core Plotting Function ---
    % This function's sole responsibility is to visualize 2D field data.
    % Pre-open a figure and pass its handle as an argument to this function.
    
    hold(ax, 'on');
    % Vertical displacement (uZ) as a color map
    pcolor(ax, E, N, uZ);
    shading(ax, 'interp');
    cbar = colorbar(ax);
    ylabel(cbar, 'Vertical Displacement (m)');
    colormap(ax, config.colormap);

    % Unify color axis if c_lim is provided
    if nargin > 6 && ~isempty(c_lim) && c_lim > 0
        clim(ax, [-c_lim, c_lim]);
    end

    % Contour lines
    if config.contour.line_count > 0
        contour(ax, E, N, uZ, config.contour.line_count, ...
            'Color', config.contour.color, 'LineStyle', config.contour.style);
    end

    % Horizontal displacement vector (quiver)
    if nargin > 4 && ~isempty(uE) && nargin > 5 && ~isempty(uN)
        skip = config.quiver.skip;
        quiver(ax, E(1:skip:end, 1:skip:end), N(1:skip:end, 1:skip:end), ...
               uE(1:skip:end, 1:skip:end), uN(1:skip:end, 1:skip:end), ...
               config.quiver.scale, 'Color', config.quiver.color, ...
               'LineWidth', config.quiver.line_width);
    end
    
    % Apply general axes settings
    set(ax, 'FontSize', config.axes.font_size);
    if strcmp(config.axes.box, 'on'), box(ax, 'on'); end
    if strcmp(config.axes.grid, 'on'), grid(ax, 'on'); end
    
    hold(ax, 'off');
end
