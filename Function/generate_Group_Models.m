function plot_groups = generate_Group_Models(all_params_table, varying_params_names)
%generate_Group_Models Prepares group model data for figure comparation.
%   This function organizes a complete set of fault models into logical
%   groups. Each group contains all the necessary information to generate
%   a single comparison figure, where one parameter varies while others
%   are held constant. It acts as the primary data preparation step before
%   plotting.
% -------------------------------------------------------------------------

    % Step 1: Calculate generated number of figures.
    total_group_count = 0;
    for p_idx = 1:length(varying_params_names)
        param_to_plot = varying_params_names{p_idx};
        other_params = setdiff(varying_params_names, param_to_plot, 'stable');
        
        % Core logic: The number of figures for a varying parameter is the
        % number of unique combinations of all other varying parameters.
        if ~isempty(other_params)
            % 使用height(unique(...))直接高效地计算组合数
            num_groups_for_this_param = height(unique(all_params_table(:, other_params), 'rows'));
        else
            % Only one group when no other varying params.
            num_groups_for_this_param = 1;
        end
        % 总共需要生成的Figure数量就是每个参数拥有的组合数相加。
        total_group_count = total_group_count + num_groups_for_this_param;
    end

    % Step 2: Pre-allocate memory for the output 'plot_groups'.
    plot_groups = cell(1, total_group_count);
    group_counter = 0;

    % Step 3: Fill the 'plot_groups'.
    for p_idx = 1:length(varying_params_names)
        param_to_plot = varying_params_names{p_idx};
        other_params = setdiff(varying_params_names, param_to_plot, 'stable');
        
        if ~isempty(other_params)
            [~, ~, group_indices] = unique(all_params_table(:, other_params), 'rows');
            num_groups = max(group_indices);
        else
            group_indices = ones(height(all_params_table), 1);
            num_groups = 1;
        end
        
        for g_idx = 1:num_groups
            % 正在画的这一张figure里变化的参数的取值的那几个值所在group_indices的位置
            model_indices_in_group = find(group_indices == g_idx);
            
            % Sort the models within the group by the varying parameter's value.
            varying_values = all_params_table.(param_to_plot)(model_indices_in_group);
            [sorted_values, sort_order] = sort(varying_values);
            sorted_indices = model_indices_in_group(sort_order);
            
            % figure name and title
            fixed_params_combination = struct();
            if ~isempty(other_params)
                fixed_param_temp = all_params_table(sorted_indices(1), other_params);
                for op_idx = 1:length(other_params)
                    param_name = other_params{op_idx};
                    fixed_params_combination.(param_name) = fixed_param_temp.(param_name);
                end
            end
            
            % Package all information for the current group into a struct.
            current_group.model_indices = sorted_indices;
            current_group.varying_param_name = param_to_plot;
            current_group.varying_param_values = sorted_values;
            current_group.fixed_params = fixed_params_combination;
            
            group_counter = group_counter + 1;
            plot_groups{group_counter} = current_group;
        end
    end
    fprintf('--- Found %d groups to plot ---\n', length(plot_groups));
end
