function plot_3D_Field_Map(ax, E, N, uZ, uE, uN, c_lim, config)
    % --- Generic Core Plotting Function ---
    % This function's sole responsibility is to visualize 3D field data.
    % Pre-open a figure and pass its handle as an argument to this function.
    
    hold(ax, 'on');
    % Vertical displacement (uZ) as a color map
    pcolor(ax, E, N, uZ);
    shading(ax, 'interp');
    
    % 只有当config中明确指示要显示时，才创建色柱
    if isfield(config, 'colorbar') && isfield(config.colorbar, 'show') && config.colorbar.show
        cbar = colorbar(ax);
        ylabel(cbar, 'Vertical Displacement (m)');
    end    
    colormap(ax, config.colormap);

    % Unify color axis if c_lim is provided
    if nargin > 6 && ~isempty(c_lim) && all(isfinite(c_lim)) && c_lim(end) > 0
        clim(ax, [-c_lim(end), c_lim(end)]);
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
               config.quiver.factor*uE(1:skip:end, 1:skip:end), ...
               config.quiver.factor*uN(1:skip:end, 1:skip:end), ...
               0, 'Color', config.quiver.color, ...
               'LineWidth', config.quiver.line_width);
    end
    
    % Apply general axes settings
    set(ax, 'FontSize', config.axes.font_size);
    if strcmp(config.axes.box, 'on'), box(ax, 'on'); end
    if strcmp(config.axes.grid, 'on'), grid(ax, 'on'); end
    
    hold(ax, 'off');
end
