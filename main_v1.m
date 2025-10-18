% -------------------------------------------------------------------------
% Overview:
%   This script systematically investigates the impact of various fault
%   parameters on surface deformation using the Okada 1985 model. It
%   explores four key parameters: fault type (rake), dip angle, hypocenter
%   depth, and tensile opening. The results are visualized as a series of
%   plots showing vertical and horizontal surface displacements.
%
% Author: YangChunmei (SCSIO, UCAS)
% Email:  yangcmei12138@gmail.com
%
% Log: version 1.0: Oct 13, 2025; 
%
% Dependances:
%   okada85.m: This function, which implements the Okada 1985 model, must 
%   be present in the MATLAB path or the same directory.
%
% Usage:
%   Simply run this script in MATLAB. All parameters for the study are
%   defined within the script. The figures will be generated automatically.
%   To change the study area, modify `grid_extent` and `grid_points`.
%
% -------------------------------------------------------------------------
clear; clc; close all; tic;
% =========================================================================
%% 定义计算区域和模型基本参数
path.Project_PATH = 'D:\codes\Deformation'; % 更改路径
addpath(fullfile(path.Project_PATH, 'Okada'));
% 设置观测点网格
grid_extent = 40; % 计算区域边长的一半 (km)
grid_points = 101; % 网格点数量
x_coords = linspace(-grid_extent, grid_extent, grid_points); % E-W 方向 (km)
y_coords = linspace(-grid_extent, grid_extent, grid_points); % N-S 方向 (km)
[E, N] = meshgrid(x_coords, y_coords);

% 定义一个标准的参考断层模型 (后续研究将在此基础上修改单个参数)
base_fault.strike = 45;     % 走向 (度)
base_fault.length = 25;     % 长度 (km)
base_fault.width = 10;      % 宽度 (km)
base_fault.depth = 10;      % 断层中心深度 (km)
base_fault.slip = 1;        % 滑动量 (m)
base_fault.open = 0;        % 张开量 (m)
base_fault.nu = 0.25;       % 泊松比

% =========================================================================
%% 断层类型 (Rake)

% 通过改变滑动角(rake)来模拟不同类型的断层运动
rake_var = [0, 180, 90, -90]; % 0:左旋走滑, 180:右旋走滑, 90:逆冲, -90:正断
titles_rake = {'Left-Lateral Strike-Slip (Rake = 0°)', ...
          'Right-Lateral Strike-Slip (Rake = 180°)', ...
          'Reverse Fault (Rake = 90°)', ...
          'Normal Fault (Rake = -90°)'};
fault_rake = base_fault; % 防止这里的处理污染原始数据base_fault
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
% 不同断层类型(rake)
figure('Name', 'Deformation of Fault Type (Rake)', 'Position', [50, 50, 1000, 800]);
tiledlayout('flow'); 
for i = 1:length(rake_var)
    nexttile;  % 自动放置下一个子图
    % subplot(2, 2, i);
    fault_rake.rake = rake_var(i); 
    plot_deformation(E, N, u_rake{i,1}, u_rake{i,2}, u_rake{i,3}, fault_rake, titles_rake{i}, c_lim_rake);
end
sgtitle({'Deformation in Fault Types(Rake)','(Dip=80°)'}, 'FontSize', 16, 'FontWeight', 'bold');

% =========================================================================
%% 倾角 (Dip)

% 针对逆冲断层，观察不同倾角下的形变特征
dip_var = [30, 60, 90]; % 浅倾角, 中等倾角, 垂直
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

% 绘图步骤
figure('Name', 'Deformation of Dip on Reverse Fault', 'Position', [100, 100, 1200, 500]);
tiledlayout('flow'); 
for i = 1:length(dip_var)
    nexttile;
    % subplot(1, 3, i);
    fault_dip.dip = dip_var(i);
    plot_deformation(E, N, u_dip{i,1}, u_dip{i,2}, u_dip{i,3}, fault_dip, sprintf('Dip = %d°', fault_dip.dip), c_lim_dip);
end
sgtitle('倾角 (Dip) 对逆冲断层 (Rake=90°) 形变的影响', 'FontSize', 16, 'FontWeight', 'bold');

% =========================================================================
%% 震源深度 (Depth)

% 观察同一断层在不同深度时，地表形变幅度和范围的变化
depth_var = [5, 10, 20]; 
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

% 绘图步骤 ---
figure('Name', 'Deformation of Fault Depth', 'Position', [150, 150, 1200, 500]);
tiledlayout('flow'); 
for i = 1:length(depth_var)
    nexttile;
    % subplot(1, 3, i);
    fault_open.depth = depth_var(i);
    plot_deformation(E, N, u_depth{i,1}, u_depth{i,2}, u_depth{i,3}, fault_open, sprintf('Depth = %d km', fault_open.depth), c_lim_depth);
end
sgtitle('震源深度 (Depth) 对逆冲断层形变的影响', 'FontSize', 16, 'FontWeight', 'bold');

% =========================================================================
%% 张性断层 (Opening)

% 模拟火山岩脉侵入等导致的纯张性破裂
dip_var_open = [30, 60, 90];
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

% --- 绘图步骤 ---
figure('Name', 'Effect of Tensile Fault (Opening)', 'Position', [200, 200, 1200, 500]);
tiledlayout('flow'); 
for i = 1:length(dip_var_open)
    nexttile;
    % subplot(1, 3, i);
    fault_open.dip = dip_var_open(i);
    plot_deformation(E, N, u_open{i,1}, u_open{i,2}, u_open{i,3}, fault_open, sprintf('Dip = %d°', fault_open.dip), c_lim_open);
end
sgtitle('张性断层 (Opening=1m) 在不同倾角下的形变特征', 'FontSize', 16, 'FontWeight', 'bold')
rmpath(fullfile(path.Project_PATH, 'Okada'));
elapsedTime = toc; fprintf('Elapsed time: %.6f seconds\n', elapsedTime);

% =========================================================================
%% 绘图子函数 (封装了绘图过程，方便重复调用)

function plot_deformation(E, N, uE, uN, uZ, fault_parameter, plot_title, c_lim)
    % 绘制垂直位移 (uZ) 的彩色填充图
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
    
    % 绘制等值线
    contour(E, N, uZ, 7, 'k-');

    % 叠加绘制水平位移矢量场
    skip = 10; % 每隔 skip 个点绘制一个箭头，避免图像过于密集
    quiver(E(1:skip:end, 1:skip:end), N(1:skip:end, 1:skip:end), ...
           uE(1:skip:end, 1:skip:end), uN(1:skip:end, 1:skip:end), ...
           'k', 'LineWidth', 1);

    % 绘制断层地表迹线 (断层上盘在地表的投影)
    L_half = fault_parameter.length / 2;
    alpha = (90 - fault_parameter.strike) * pi / 180;
    x_trace = [-L_half, L_half] * cos(alpha);
    y_trace = [-L_half, L_half] * sin(alpha);
    plot(x_trace, y_trace, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Fault Trace');
    
    % 在断层迹线上盘方向画一个标记，指示断层倾向   
    if fault_parameter.dip ~= 90  % 仅对于非垂直断层
        dip_dir_x = 0.1 * L_half * sin(alpha);
        dip_dir_y = -0.1 * L_half * cos(alpha);
        plot([0, dip_dir_x], [0, dip_dir_y], 'r-v', 'LineWidth', 1.5, 'MarkerFaceColor', 'r', 'MarkerSize', 4);
    end

    % 图形美化
    axis equal; grid on; box on;
    xlabel('East (km)'); ylabel('North (km)'); title(plot_title);
    xlim([min(E(:)), max(E(:))]); ylim([min(N(:)), max(N(:))]);
    hold off;
end