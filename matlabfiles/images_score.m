clc
clear
close all
path = '~/Documents/MATLAB/01_TMI/IUS2024/';
folder = 'IUS2024_Diffusion';
addpath([path, folder, '/src']);
addpath([path, folder, '/data']);
load([path folder '/scores/EC_Metrics_Abs'], "FWHMAs", "FWHMLs", "SNRs", "gCNRs");

FWHMs = [FWHMAs; FWHMLs];
FWHMs = FWHMs';
names = {'DAS75'; 'DAS1'; 'EBMV'; 'DAS1+DUSvar'; '\bf{EBMV+DUSvar}'};
dumbnames = {''; ''; ''; ''; ''};
selected = [1, 2, 4, 3, 5];

figure(Position=[220 535 598 260]);
tiledlayout(1, 3, "Padding", 'none', "TileSpacing", 'none', Position=[0.25, 0.1, 0.7, 0.7])

% First Tile
nexttile
b = barh(1:length(names), FWHMs(selected, :));
b(1).FaceColor = [0.9290 0.6940 0.1250];
set(gca, 'ytick', [1:length(names)], 'yticklabel', names)
lgn = legend('FWHMA$\downarrow$', 'FWHML$\downarrow$', Location='northeast', Interpreter='Latex'); 
set(lgn, 'Box', 'off');
ylim([0.5, 5.5])
xlim([0, 3.8])
ax = gca;
ax.FontSize = 13;
grid on;
set(gca,'color','none', 'box','off', 'TickLabelInterpreter', 'latex')

% Second Tile
nexttile
barh(1:length(names), gCNRs(selected), 0.3, 'FaceColor', [0.4940 0.1840 0.5560])
set(gca, 'ytick', [1:length(names)], 'yticklabel', dumbnames)
lgn = legend('gCNR$\uparrow$', Location='northeast', Interpreter='Latex'); 
set(lgn, 'Box', 'off');
ylim([0.5, 5.5]); 
xlim([0.6, 1.05]);
ax = gca;
ax.FontSize = 13;
grid on;
set(gca,'color','none', 'box','off', 'TickLabelInterpreter', 'latex')

% Third Tile
nexttile
barh(1:length(names), SNRs(selected), 0.3, 'FaceColor', [0.4660 0.6740 0.1880])
set(gca, 'ytick', [1:length(names)], 'yticklabel', dumbnames)
lgn = legend('SNR$\uparrow$', Location='northeast', Interpreter='Latex');  
set(lgn, 'Box', 'off');
ylim([0.5, 5.5])
xlim([0, 2.1]);

ax = gca;
ax.FontSize = 13;
grid on;
set(gca,'color','none', 'box','off', 'TickLabelInterpreter', 'latex')

%% Save the figure
savefig('scores/EC_barScores_horizontal.fig')
% Export as PDF
h = gcf;
set(h, 'Units', 'Inches');
pos = get(h, 'Position');
set(h, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)])
print(h, 'scores/EC_barScores_horizontal', '-dpdf', '-r0')
