function plot_Single_Models(Fault, E, N, varying_params_names, plotting_config, path)
%plot_Single_Models Handles all logic for single mode

    num_models = length(Fault);
    fprintf('--- %d models to plot individually ---\n', num_models);

    % 1. Unify color limit
    max_abs_uz = 0;
    for i = 1:num_models
        max_abs_uz = max(max_abs_uz, max(abs(Fault{i}.deformation.uZ(:))));
    end
    c_lim = max_abs_uz;
    if c_lim == 0, c_lim = 1; end
    
    % 2. Show colorbar
    plotting_config.colorbar.show = true; 
    
    % 3. Plot single fault deformation figure
    for i = 1:num_models
        current_fault = Fault{i};        
        % figure name
        if exist('varying_params_names', 'var') && ~isempty(varying_params_names)
            param_strs = cellfun(@(p) sprintf('%s=%.1f', p, current_fault.model_parameters.(p)), ...
                                 varying_params_names, 'UniformOutput', false);
            figure_name = strjoin(param_strs, '; ');
        else
            figure_name = 'Base_Fault';
        end

        %  
        fig = figure('Visible', 'off', 'Position',[100, 100, 800, 650]);
        plot_Fault_Deformation(gca, current_fault, E, N, c_lim, figure_name, plotting_config);
        
        % file name
        fig_name = strrep(figure_name, '; ', '_');
        fig_name = strrep(fig_name, '=', '');
        fig_name = strrep(fig_name, '.', 'p');
        fig_filename = sprintf('Surf_Deformation_%s.%s', fig_name, plotting_config.save_format);
        saveas(fig, fullfile(path.Figure_PATH_Single, fig_filename));    
        close(fig);
    end
    fprintf('--- Single figures saved to: \n  %s\n', path.Figure_PATH_Single);
end
