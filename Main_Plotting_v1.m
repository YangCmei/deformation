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
path.Figure_PATH = fullfile(path.Output_PATH, 'Figures');
if ~exist(path.Figure_PATH, 'dir'), mkdir(path.Figure_PATH); end
addpath(fullfile(path.Project_PATH, 'Function'));

% Configuration 
plotting_config.axes.font_size = 12;
plotting_config.axes.box = 'on'; 
plotting_config.axes.grid = 'on';

plotting_config.quiver.skip = 10; % Plot one vector every 'skip' points
plotting_config.quiver.scale = 1.5;
plotting_config.quiver.color = 'k';
plotting_config.quiver.line_width = 1.0;

plotting_config.contour.line_count = 10;
plotting_config.contour.color = 'k';
plotting_config.contour.style = '-';

plotting_config.fault.color = 'r';
plotting_config.fault.line_width = 2.5;
plotting_config.fault.dip_marker_size = 8;

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
fprintf('--- %d models to plot. Generating figures... ---\n', num_models);
% Pre-calculate a unified color limit 
max_abs_uz = 0;
for i = 1:num_models
    max_abs_uz = max(max_abs_uz, max(abs(Fault{i}.deformation.uZ(:))));
end
c_lim = max_abs_uz;
if c_lim == 0, c_lim = 1; end % Avoid error if all values are zero

% plot
for i = 1:num_models
    current_fault = Fault{i};    
    % figure name
    if exist('varying_params_names', 'var') && ~isempty(varying_params_names)
        param_strs = cellfun(@(p) sprintf('%s=%.1f', p, current_fault.model_parameters.(p)), ...
                             varying_params_names, 'UniformOutput', false); % 用cellfun避免了一次小循环
        figure_name = strjoin(param_strs, '; ');
    else
        figure_name = 'Base_Fault';
    end

    % 
    fig = figure('Visible', 'off', 'Position',[100, 100, 800, 650]);
    plot_Fault_Deformation(gca, current_fault, E, N, c_lim, figure_name, plotting_config);
    % 
    fig_name = strrep(figure_name, '; ', '_'); % 图片文件名用-连接 图片标题用;连接
    fig_name = strrep(fig_name, '=', '');
    fig_filename = sprintf('Surf_Deformation_%s.%s', fig_name, plotting_config.save_format);
    saveas(fig, fullfile(path.Figure_PATH, fig_filename));    
    close(fig);
end

%% Ending
fprintf('--- Plotting complete! Figures saved to: \n  %s\n', path.Figure_PATH);
rmpath(fullfile(path.Project_PATH, 'Function'));
elapsedTime = toc; fprintf('Elapsed time: %.6f seconds\n', elapsedTime);
