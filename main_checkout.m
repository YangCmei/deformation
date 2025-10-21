% -------------------------------------------------------------------------
% Overview:
%   This script serves as a preliminary testbed and a validation tool. It
%   was initially created to explore the core functionalities of the Okada
%   1985 model before the comprehensive `Main_Calculation` and `Main_Plotting`
%   suite was developed.
%
%   While the main suite is designed for systematic, large-scale data
%   processing, this script remains valuable for quick, targeted checks.
% -------------------------------------------------------------------------
clear; clc; close all; tic;
%% Setting
% path
path.Project_PATH = 'D:\codes\Deformation'; 
addpath(fullfile(path.Project_PATH, 'Okada'));
% grid
grid_extent = 40; 
grid_points = 101;
x_coords = linspace(-grid_extent, grid_extent, grid_points); % E-W 方向 (km)
y_coords = linspace(-grid_extent, grid_extent, grid_points); % N-S 方向 (km)
[E, N] = meshgrid(x_coords, y_coords);
% base fault model
base_fault.strike = 45;     % degree
base_fault.length = 25;     % km
base_fault.width = 10;      % km
base_fault.depth = 10;      % km
base_fault.slip = 1;        % m
base_fault.open = 0;        % m
base_fault.nu = 0.25;       

%% Rake
% 通过改变rake来模拟不同类型的断层运动
rake_var = [0, 180, 90, -90]; % 0:左旋走滑, 180:右旋走滑, 90:逆冲, -90:正断
titles_rake = {'Left-Lateral Strike-Slip (Rake = 0°)', ...
          'Right-Lateral Strike-Slip (Rake = 180°)', ...
          'Reverse Fault (Rake = 90°)', ...
          'Normal Fault (Rake = -90°)'};
fault_rake = base_fault; 
fault_rake.dip = 80; % 对走滑断层使用较陡的倾角

u_rake = cell(length(rake_var), 3); % {uE, uN, uZ}
all_uz_rake = [];
for i = 1:length(rake_var)
    fault_rake.rake = rake_var(i);
    [uE, uN, uZ] = okada85(E, N, fault_rake.depth, fault_rake.strike, fault_rake.dip, ...
                         fault_rake.length, fault_rake.width, fault_rake.rake, ...
                         fault_rake.slip, fault_rake.open, fault_rake.nu);
    u_rake{i, 1} = uE;
    u_rake{i, 2} = uN;
    u_rake{i, 3} = uZ;
    all_uz_rake = [all_uz_rake; uZ(:)];
end
c_lim_rake = max(abs(all_uz_rake));
% plot
figure('Name', 'Deformation of Fault Type (Rake)', 'Position', [50, 50, 1000, 800]);
tiledlayout('flow'); % 不用提前计算行列数
for i = 1:length(rake_var)
    nexttile;  % 自动放置下一个子图
    % subplot(2, 2, i);
    fault_rake.rake = rake_var(i); 
    plot_deformation(E, N, u_rake{i,1}, u_rake{i,2}, u_rake{i,3}, fault_rake, titles_rake{i}, c_lim_rake);
end
sgtitle({'Deformation in Fault Types(Rake)','(Dip=80°)'}, 'FontSize', 16, 'FontWeight', 'bold');

%% Dip
% 针对逆冲断层，观察不同倾角下的形变特征
dip_var = [10, 20, 30, 40, 50, 60, 70, 80, 90]; % 浅倾角, 中等倾角, 垂直
fault_dip = base_fault;
fault_dip.rake = 90; % 固定为逆冲断层

u_dip = cell(length(dip_var), 3);
all_uz_dip = [];
for i = 1:length(dip_var)
    fault_dip.dip = dip_var(i);
    [uE, uN, uZ] = okada85(E, N, fault_dip.depth, fault_dip.strike, fault_dip.dip, ...
                         fault_dip.length, fault_dip.width, fault_dip.rake, ...
                         fault_dip.slip, fault_dip.open, fault_dip.nu);
    u_dip{i, 1} = uE;
    u_dip{i, 2} = uN;
    u_dip{i, 3} = uZ;
    all_uz_dip = [all_uz_dip; uZ(:)];
end
c_lim_dip = max(abs(all_uz_dip));

% plot
figure('Name', 'Deformation of Dip on Reverse Fault', 'Position', [100, 100, 1200, 500]);
tiledlayout('flow'); 
for i = 1:length(dip_var)
    nexttile;
    % subplot(1, 3, i);
    fault_dip.dip = dip_var(i);
    plot_deformation(E, N, u_dip{i,1}, u_dip{i,2}, u_dip{i,3}, fault_dip, sprintf('Dip = %d°', fault_dip.dip), c_lim_dip);
end
sgtitle('Deformation for Reverse Fault (Rake = 90°)in Dip', 'FontSize', 16, 'FontWeight', 'bold');

%% Source Depth
% 观察同一断层在不同深度时，地表形变幅度和范围的变化
depth_var = [5, 10, 15, 20]; 
fault_open = base_fault;
fault_open.rake = 90; % 固定为逆冲断层
fault_open.dip = 60;

u_depth = cell(length(depth_var), 3);
all_uz_depth = [];
for i = 1:length(depth_var)
    fault_open.depth = depth_var(i);
    [uE, uN, uZ] = okada85(E, N, fault_open.depth, fault_open.strike, fault_open.dip, ...
                         fault_open.length, fault_open.width, fault_open.rake, ...
                         fault_open.slip, fault_open.open, fault_open.nu);
    u_depth{i, 1} = uE;
    u_depth{i, 2} = uN;
    u_depth{i, 3} = uZ;
    all_uz_depth = [all_uz_depth; uZ(:)];
end
c_lim_depth = max(abs(all_uz_depth));

% plot
figure('Name', 'Deformation of Fault Depth', 'Position', [150, 150, 1200, 500]);
tiledlayout('flow'); 
for i = 1:length(depth_var)
    nexttile;
    % subplot(1, 3, i);
    fault_open.depth = depth_var(i);
    plot_deformation(E, N, u_depth{i,1}, u_depth{i,2}, u_depth{i,3}, fault_open, sprintf('Depth = %d km', fault_open.depth), c_lim_depth);
end
sgtitle('Deformation for Reverse Fault in Depth', 'FontSize', 16, 'FontWeight', 'bold');

%% Opening(张性断层)
% 模拟火山岩脉侵入等导致的纯张性破裂
dip_var_open = [15, 30, 45, 60, 75, 90];
fault_open = base_fault;
fault_open.slip = 0; % 无剪切滑动
fault_open.open = 1; % 1米的张开量

u_open = cell(length(dip_var_open), 3);
all_uz_open = [];
for i = 1:length(dip_var_open)
    fault_open.dip = dip_var_open(i);
    [uE, uN, uZ] = okada85(E, N, fault_open.depth, fault_open.strike, fault_open.dip, ...
                         fault_open.length, fault_open.width, 0, ... % rake is irrelevant when slip=0
                         fault_open.slip, fault_open.open, fault_open.nu);
    u_open{i, 1} = uE;
    u_open{i, 2} = uN;
    u_open{i, 3} = uZ;
    all_uz_open = [all_uz_open; uZ(:)];
end
c_lim_open = max(abs(all_uz_open));

% plot
figure('Name', 'Effect of Tensile Fault (Opening)', 'Position', [200, 200, 1200, 500]);
tiledlayout('flow'); 
for i = 1:length(dip_var_open)
    nexttile;
    % subplot(1, 3, i);
    fault_open.dip = dip_var_open(i);
    plot_deformation(E, N, u_open{i,1}, u_open{i,2}, u_open{i,3}, fault_open, sprintf('Dip = %d°', fault_open.dip), c_lim_open);
end
sgtitle('Deformation for Opening Fault in Dip', 'FontSize', 16, 'FontWeight', 'bold')

%% Ending
rmpath(fullfile(path.Project_PATH, 'Okada'));
elapsedTime = toc; fprintf('Elapsed time: %.6f seconds\n', elapsedTime);

%% Subfunction
function plot_deformation(E, N, uE, uN, uZ, fault_parameter, plot_title, c_lim)
    % Vertical displacement (uZ) as a color map
    pcolor(E, N, uZ);
    shading interp;
    cbar = colorbar;
    ylabel(cbar, 'Vertical (m)');
    colormap(jet);
    
    % 使用传入的统一色轴范围；如果未提供，则使用局部范围
    if nargin > 7 && c_lim > 0
        clim([-c_lim, c_lim]);
    else
        max_abs_z = max(abs(uZ(:)));
        if max_abs_z > 0
            clim([-max_abs_z, max_abs_z]);
        end
    end
    
    hold on;
    
    % Contour lines
    contour(E, N, uZ, 7, 'k-');

    % Horizontal displacement vector (quiver)
    skip = 10; % 每隔 skip 个点绘制一个箭头，避免图像过于密集
    quiver(E(1:skip:end, 1:skip:end), N(1:skip:end, 1:skip:end), ...
           uE(1:skip:end, 1:skip:end), uN(1:skip:end, 1:skip:end), ...
           'k', 'LineWidth', 1);

    % Fault trace
    L = fault_parameter.length;
    W = fault_parameter.width;
    strike_rad = fault_parameter.strike * pi / 180;
    dip_rad = fault_parameter.dip * pi / 180;
    % 断层上缘中点在地表的投影位置
    horizontal_offset = (W/2) * cos(dip_rad);
    top_center_x = -horizontal_offset * cos(strike_rad);
    top_center_y = horizontal_offset * sin(strike_rad);

    % 以断层上缘中点为中心，沿着走向方向计算迹线端点
    x_trace = [-L/2 * sin(strike_rad),  L/2 * sin(strike_rad)] + top_center_x;
    y_trace = [-L/2 * cos(strike_rad), L/2 * cos(strike_rad)] + top_center_y;

    % 在 plot 时获取它的句柄 h_fault
    plot(x_trace, y_trace, 'r-', 'LineWidth', 3, 'DisplayName', 'Fault Trace');

    % Mark the dip direction on the hanging wall  
    if fault_parameter.dip ~= 90  % 仅对于非垂直断层
        plot([top_center_x, 0], [top_center_y, 0], 'r-', 'LineWidth', 1.5, 'MarkerFaceColor', 'r', 'MarkerSize', 4);        
    end

    % Axes
    axis equal; grid on; box on;
    xlabel('East (km)'); ylabel('North (km)'); title(plot_title);
    xlim([min(E(:)), max(E(:))]); ylim([min(N(:)), max(N(:))]);
    hold off;
end