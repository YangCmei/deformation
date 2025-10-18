function [model_combinations, num_models, varying_params_names] = generate_Model_Combinations(base_fault)
%generate_Model_Combinations Generate all possible model combinations from varying parameters.
%   This function takes a base structure (base_fault) containing model
%   parameters. It automatically identifies which parameters are fixed and
%   which are variable. It then calculates the Cartesian product of all
%   possible values for the varying parameters, generating a unique model
%   for each combination. This is highly useful for systematically and
%   batch-testing the impact of different parameter combinations.
%
%   [model_combinations, num_models, varying_params_names] = generate_Model_Combinations(base_fault)
%
%   base_fault ： A MATLAB structure where each field is a model parameter.
%                The value's format determines if it's fixed or variable:
%                - Single value for fixed parameters (e.g., `base_fault.length = 25`).
%                - 3-element vector [start, end, step] for ranged parameters.
%                - Vector with multiple values for discrete parameters.
%
%                For example：base_fault.dip  = [30, 40, 5]; 
%                             base_fault.rake = [80, 90];    
%   
%   model_combinations ：A structure array where each element represents a unique
%                        combination of model parameters. 
%                        
%                        Base on the example: {dip:30,rake:80}, {dip:35,rake:80}
%                                             {dip:40,rake:80}, {dip:30,rake:90},
%                                             {dip:35,rake:90}, {dip:40,rake:90}.
%
%   num_models         ： The total number of model combinations generated.
%
%   varying_params_names ： A cell array of strings containing the names
%                          of the parameters that were varied in this run.
%                          This will be an empty cell array {} when no params vary.
%
%   Author: YangChunmei <yangcmei12138@gmail.com>
%
% -------------------------------------------------------------------------
    fprintf('\n--- Parsing parameters and generating model combinations ---\n');

    new_base_fault = base_fault;
    param_names = fieldnames(base_fault);

    is_varying = false(1, length(param_names));
    for i = 1:length(param_names)
        if numel(base_fault.(param_names{i})) > 1
            is_varying(i) = true;
        end
    end
    num_varying_params = sum(is_varying);
    
    % Pre-allocate cell arrays with the exact final size.
    varying_params_list = cell(1, num_varying_params);
    varying_params_names = cell(1, num_varying_params);

    % Identify 'new_base_fault' and 'varying_params_list' and 'varying_params_name'
    list_idx = 0;
    for i = 1:length(param_names)
        if is_varying(i)
            list_idx = list_idx + 1; 
            current_p_name = param_names{i};
            current_p_value = base_fault.(current_p_name);
            
            varying_params_names{list_idx} = current_p_name; % 一进循环就是变量名
            
            if numel(current_p_value) == 3
                expanded_values = current_p_value(1):current_p_value(3):current_p_value(2);
                new_base_fault.(current_p_name) = expanded_values;
                varying_params_list{list_idx} = expanded_values; % Store values
                fprintf('  Varying: %s( Range: %g to %g, Step: %g)\n', ...
                    current_p_name, current_p_value(1), current_p_value(2), current_p_value(3));
            else % This handles discrete values (e.g., [10, 45, 90])
                new_base_fault.(current_p_name) = current_p_value;
                varying_params_list{list_idx} = current_p_value; % Store values
                fprintf('  Varying: %s (Discrete values)\n', current_p_name);
            end
        end
    end

    % Generate all parameter combinations
    if isempty(varying_params_list)
        num_models = 1;
        model_combinations = base_fault; % Only one model
    else
        [grids{1:length(varying_params_list)}] = ndgrid(varying_params_list{:});
        num_models = numel(grids{1});

        % 1. Create a template with fixed-value parameters
        model_template = new_base_fault;
        for i = 1:length(varying_params_names)
            model_template = rmfield(model_template, varying_params_names{i});
        end
        
        % 2. Replicate the template for the total number of models
        model_combinations = repmat(model_template, num_models, 1);
        
        % 3. Fill in the varying parameter values for each model
        for i = 1:num_models
            for j = 1:length(varying_params_names)
                current_p_name = varying_params_names{j};
                current_grid = grids{j};
                model_combinations(i).(current_p_name) = current_grid(i);
            end
        end
    end

    fprintf('--- Total model combinations: %d ---\n', num_models);

end
