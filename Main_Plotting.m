% -------------------------------------------------------------------------
% Overview:
%   This script loads pre-calculated surface deformation data and generates
%   publication-quality figures. It supports two modes:
%   1. Plotting each fault model as a single, individual figure.
%   2. Generating grouped figures, where each figure shows the deformation
%      variation as a single parameter changes, keeping others constant.
% -------------------------------------------------------------------------
clear; clc; close all; tic;
%% Setting
% Path 
path.Project_PATH = 'D:\codes\Deformation'; 
path.Output_PATH = fullfile(path.Project_PATH, 'Results');
addpath(fullfile(path.Project_PATH, 'Function'));

% Figure
plot_mode = 'group'; %  Can be 'single', 'group', 'both'.

% Output directory
path.Figure_PATH_Single = fullfile(path.Output_PATH, 'Figures_Single');
path.Figure_PATH_Group = fullfile(path.Output_PATH, 'Figures_Group');
if strcmp(plot_mode, 'single') || strcmp(plot_mode, 'both')
    if ~exist(path.Figure_PATH_Single, 'dir'), mkdir(path.Figure_PATH_Single); end
end
if strcmp(plot_mode, 'group') || strcmp(plot_mode, 'both')
    if ~exist(path.Figure_PATH_Group, 'dir'), mkdir(path.Figure_PATH_Group); end
end

% Configuration
plotting_config.axes.font_size = 8;
plotting_config.axes.box = 'on';
plotting_config.axes.grid = 'on';

plotting_config.quiver.skip = 10; % Plot one vector every 'skip' points
plotting_config.quiver.scale = 1.5;
plotting_config.quiver.color = 'k';
plotting_config.quiver.line_width = 0.8;

plotting_config.contour.line_count = 10;
plotting_config.contour.color = 'k';
plotting_config.contour.style = '-';

plotting_config.fault.color = 'r';
plotting_config.fault.line_width = 1;
plotting_config.fault.dip_marker_size = 4;

plotting_config.colormap = jet;
plotting_config.save_format = 'png'; % Can be 'png', 'jpeg', 'pdf', etc.

%% Load Data File
fprintf('\n--- Choosing a *.mat file ---\n');
% Select the .mat file
[filename, pathname] = uigetfile(fullfile(path.Output_PATH, '*.mat'), 'Please choose a data file');
if isequal(filename, 0)
    fprintf('--- No file selected. The script will stop. ---\n');
    return;
end
% Load data
fprintf('--- Loading: %s ---\n', filename);
load(fullfile(pathname, filename));

%% Plotting 
% mode 1: single figures
if strcmp(plot_mode, 'single') || strcmp(plot_mode, 'both')
    fprintf('\n--- Generating single figures... ---\n');
    plot_Single_Models(Fault, E, N, varying_params_names, plotting_config, path);
end

% mode 2: group figures
if strcmp(plot_mode, 'group') || strcmp(plot_mode, 'both')
    fprintf('\n--- Generating group figures... ---\n');
    
    % 检查 `plot_groups` 变量是否存在，如果不存在则给出提示
    if ~exist('plot_groups', 'var')
        error(['The variable "plot_groups" was not found in the loaded .mat file. ' ...
               'Please re-run Main_Calculation.m with the latest version to include it.']);
    end
    
    % 遍历每一个分组，并调用独立的绘图函数生成图像
    for i = 1:length(plot_groups)
        plot_Group_Models(plot_groups{i}, Fault, E, N, plotting_config, path);
    end
end

%% Ending
fprintf('\n--- All plotting tasks complete! ---\n');
rmpath(fullfile(path.Project_PATH, 'Function'));
elapsedTime = toc; fprintf('Elapsed time: %.6f seconds\n', elapsedTime);
