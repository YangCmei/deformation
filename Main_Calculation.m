% -------------------------------------------------------------------------
% Overview:
%   This script serves as a tool for systematically studying the impact of
%   fault parameters on surface deformation. It automatically generates
%   all possible combinations of user-defined fault parameter ranges and
%   calculates the resulting surface deformation using the Okada 1985 model.
%   The results are saved to a .mat file for later visualization.
%
% Author: YangChunmei (SCSIO, UCAS)
% Email:  yangcmei12138@gmail.com
%
% Log: version 1.0: 2025-10-13; 
%     
% Dependances:
%   okada85.m, generateFaultModels.m: Must be in the MATLAB path.
%
% Usage:
%   1. Define all study parameters in the 'Setting' section below.
%   2. For parameters to be varied, use a 3-element vector [start, end, step]
%      or a vector of discrete values (e.g., [0, 90, 180]).
%   3. For fixed parameters, provide a single numeric value.
%   4. Run this script. It will perform all calculations and save the results.
% -------------------------------------------------------------------------
clear; clc; close all; tic;
%% Setting
% Path
path.Project_PATH = 'D:\codes\Deformation'; % 更改路径
path.Output_PATH = fullfile(path.Project_PATH, 'Results'); % 参数组合数据保存路径
path.Figure_PATH = fullfile(path.Output_PATH, 'Figures');   % 图像保存路径
% Add function
addpath(fullfile(path.Project_PATH, 'Okada'));
addpath(fullfile(path.Project_PATH, 'Function'));
if ~exist(path.Output_PATH, 'dir'), mkdir(path.Output_PATH); end
if ~exist(path.Figure_PATH, 'dir'), mkdir(path.Figure_PATH); end
fprintf('  Saving results to: %s\n', path.Output_PATH);
fprintf('  Saving figures to: %s\n', path.Figure_PATH);

% Grid
setting.grid.extent = 40;        % 计算区域半径 (km)
setting.grid.points = 101;       % 网格点数
% Base fault model
% 使用 [start, end, step] 或单个值来定义
base_fault.strike = 45;           % degree
base_fault.dip    = [10, 85, 5]; % degree
base_fault.length = 25;           % km
base_fault.width  = 10;           % km
base_fault.depth  = [5,15,1];           % km
base_fault.rake   = [10,85,5];   % degree
base_fault.slip   = [0.5,1.5,0.1];            % m
base_fault.open   = 0;            % m
base_fault.nu     = 0.25;

%% Computing
% Generate model combinations
[model_combinations, num_models, varying_params_names] = generate_Model_Combinations(base_fault);
% Okada
fprintf('\n--- Running Okada calculation ---\n');
% 创建观测网格
[E, N] = meshgrid(linspace(-setting.grid.extent, setting.grid.extent, setting.grid.points));

% 预分配结果结构体
Fault = cell(num_models, 1);
calculation_start_time = tic;
for i = 1:num_models
    current_model = model_combinations(i);
    
    % 显示进度
    param_strs = cell(1, length(varying_params_names));
    for j = 1:length(varying_params_names)
        current_p_name = varying_params_names{j};
        param_strs{j} = sprintf('%s=%.1f', current_p_name, current_model.(current_p_name));
    end
    progress_str = sprintf('  Processing %d/%d: %s', i, num_models, strjoin(param_strs, ' '));
    
    fprintf('%s\n', progress_str);
    
    % 调用 Okada85 模型
    [uE, uN, uZ] = okada85(E, N, ...
                         current_model.depth, current_model.strike, current_model.dip, ...
                         current_model.length, current_model.width, current_model.rake, ...
                         current_model.slip, current_model.open, current_model.nu);
                         
    % 存储该模型的结果和参数
    Fault{i}.model_parameters = current_model;
    Fault{i}.deformation.uE = uE;
    Fault{i}.deformation.uN = uN;
    Fault{i}.deformation.uZ = uZ;
end
calculation_time = toc(calculation_start_time);
fprintf('--- Calculation time: %.2f seconds ---\n', calculation_time);

%% Saving
% filename
filename_params = strjoin(varying_params_names, '_');
if isempty(filename_params), filename_params = 'Base_Fault'; end
timestamp = datetime('now', 'Format', 'yyyyMMdd_HHmmss');
filename_mat = fullfile(path.Output_PATH, sprintf('Surface_Deformation_%s_%s.mat', filename_params, timestamp));
% save .mat
save(filename_mat, 'Fault', 'E', 'N', 'num_models', 'varying_params_names');
fprintf('--- Results successfully saved to: \n  %s\n', filename_mat);

%% Plotting
% 直接调用新的绘图函数
%fprintf('\n--- Starting to generate figures... ---\n');
%plot_deformation_maps(Fault, E, N, num_models, varying_params_names, paths);

%%
rmpath(fullfile(path.Project_PATH, 'Okada'));
rmpath(fullfile(path.Project_PATH, 'Function'));
elapsedTime = toc; fprintf('Elapsed time: %.6f seconds\n', elapsedTime);
