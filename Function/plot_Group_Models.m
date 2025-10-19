function plot_Group_Models(group_info, Fault, E, N, plotting_config, path)
%plot_Group_Models Generates and saves a single figure for a model group.
%   This function takes a single group of models and handles all plotting
%   details, including subplot layout, rendering each plot, adding a shared
%   colorbar and title, and saving the final figure to a file.
% -------------------------------------------------------------------------

    % Step 1: Unpack data from the input struct
    model_indices = group_info.model_indices;
    param_to_plot = group_info.varying_param_name;
    sorted_values = group_info.varying_param_values;
    fixed_params  = group_info.fixed_params;
    num_subplots  = length(model_indices);

    % Step 2: Unify color limit for the group
    max_abs_uz_group = 0;
    for m_idx = model_indices'
        max_abs_uz_group = max(max_abs_uz_group, max(abs(Fault{m_idx}.deformation.uZ(:))));
    end
    c_lim_group = max_abs_uz_group;
    if c_lim_group == 0, c_lim_group = 1; end

    % Step 3: Prepare the figure and tiled layout
    ncols = ceil(sqrt(num_subplots));
    nrows = ceil(num_subplots / ncols);
    fig = figure('Visible', 'off', 'Position', [100, 100, 450 * ncols + 80, 400 * nrows]);
    t = tiledlayout(nrows, ncols, 'TileSpacing', 'compact', 'Padding', 'compact');

    % Step 4: Draw each subplot
    plotting_config.colorbar.show = false; % 确保业务函数不创建独立色柱
    for s_idx = 1:num_subplots
        ax = nexttile;
        model_idx = model_indices(s_idx);
        current_fault = Fault{model_idx};
        subplot_title = sprintf('%s = %.1f', param_to_plot, sorted_values(s_idx));
        
        plot_Fault_Deformation(ax, current_fault, E, N, c_lim_group, subplot_title, plotting_config);
    end

    % Step 5: Add a shared colorbar and main title
    cb = colorbar;
    cb.Layout.Tile = 'east';
    ylabel(cb, 'Vertical Displacement (m)');
    
    fixed_param_names = fieldnames(fixed_params);
    figure_title_parts = cell(1, length(fixed_param_names));
    for i = 1:length(fixed_param_names)
        param_name = fixed_param_names{i};
        param_val = fixed_params.(param_name);
        figure_title_parts{i} = sprintf('%s=%.1f', param_name, param_val);
    end
    main_title = strjoin(figure_title_parts, '; ');
    title(t, main_title, 'Interpreter', 'none', 'FontWeight', 'bold');

    % Step 6: figure name 
    filename_parts = cell(1, 1 + length(fixed_param_names));
    filename_parts{1} = sprintf('Surf-Deformation-%s', param_to_plot);
    for i = 1:length(fixed_param_names)
        param_name = fixed_param_names{i};
        param_val = fixed_params.(param_name);
        filename_parts{i+1} = sprintf('%s_%.0f', param_name, param_val);
    end
    
    fig_name_base = strjoin(filename_parts, '_');
    fig_name_base = strrep(fig_name_base, '.', 'p');
    fig_filename = sprintf('%s.%s', fig_name_base, plotting_config.save_format);
    % save
    saveas(fig, fullfile(path.Figure_PATH_Group, fig_filename));
    close(fig);
    fprintf('  Saved figure: %s\n', fig_filename);
end