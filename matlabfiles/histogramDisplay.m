% EXPERIMENT
% -statistical behavior of the reconstruction on EC
% FUNCTION
% -plot the histogram

clc
clear
close all
path = '~/Documents/MATLAB/01_TMI/IUS2024/';
folder = 'IUS2024_Diffusion';
addpath([path, folder, '/src']);
addpath([path, folder, '/data']);
scan = linear_scan(linspace(-0.018,0.018,256).', linspace(0.01,0.036+0.01,256).');

c = 20;
X = zeros(c,256,256);
for i = 1: c
    load(['data/ebmvdeno/contrast_expe/' num2str(i) '_-1.mat'])
    X(i,:,:) = squeeze(x);
end

xPosIdx = 160;
xPos = scan.x_axis(xPosIdx)*1e3;
histoSkip = 1;
histoIdices = 1:histoSkip:256;
histoNum = length(histoIdices);
edges = -0.15 : 0.003: 0.15;

% Initialization
histoData = zeros(length(edges)-1, histoNum);
for k = 1: histoNum
    histoIdx = histoIdices(k);
    histoData(:,k) = histogram(squeeze(X(:, histoIdx, xPosIdx)), edges).Values;
end
close


% Narrow view for the speckle comparison
startIdx = 180; 
endIdx = 210; 
startPos = scan.z_axis(startIdx)*1e3;
endPos = scan.z_axis(endIdx)*1e3;
z_lim = [startPos, endPos]; %[0.035 0.04]*1e3
x_lim = [0.002 0.014]*1e3;

pos1 = [0.1,0.7,0.4,0.35];
pos2 = [0.02,0.0,0.48,0.65];
pos3 = [0.58,0.1,0.39,0.85];

hf = figure('Position', [66 154 748 700]);

ax1 = axes('Position', pos1); % Define the position for the first subplot
t1 = tiledlayout(1, 1,'TileSpacing','none', 'Padding', 'none', 'Position', pos1);
nexttile(t1);
% EBMV image plot
load data/By/contrast_expe0.mat
signedImg = (reshape(By,[256,256]))';
Image_realScale(signedImg, '', scan); 
axis([x_lim z_lim]); colorbar off;  axis on
plot(xPos*ones(1,length(startPos:0.1:endPos)), startPos:0.1:endPos,'green:', 'LineWidth',2)
xlabel('x [mm]'); ylabel('z [mm]'); title('EBMV') 
set(gca,'fontsize',13);


ax2 = axes('Position', pos2); % Define the position for the first subplot
t2 = tiledlayout(5, 2,'TileSpacing','none', 'Padding', 'none', 'Position', pos2);
% Display one samples
nexttile(t2);
Image_realScale(squeeze(X(1,:,:)), '', scan);
axis([x_lim z_lim]);  axis off; colorbar off;
for i = 2:10
    nexttile
    Image_realScale(squeeze(X(i,:,:)), '', scan);
    axis([x_lim z_lim]);  axis off; colorbar off;
end


annotation(gcf,'textbox',...
    [0.035 0.63 0.45 0.05],...
    'String',{'10 Samples from \bf{EBMV+DUS}'},...
    'LineStyle','none',...
    'Interpreter','latex',...
    'FontSize',15,...
    'FitBoxToText','off');


ax3 = axes('Position', pos3); 
t3 = tiledlayout(1, 2,'TileSpacing','none', 'Padding', 'none', 'Position', pos3);
nexttile(t3);
% display the EBMV RF values 
plot(signedImg(startIdx:endIdx, xPosIdx),startIdx:endIdx, 'LineWidth',2, 'Color',"#77AC30");
yticks([startIdx, endIdx])
yticklabels({num2str(startPos,3),num2str(endPos,3)})
ylabel('z [mm]'); 
xlabel({'RF data';'(\bf{EBMV})'}, Interpreter='latex');
set(gca,'fontsize',13);  
set(gca,'YDir','reverse'); 
set(gca,'color','none', 'box','off')

% display the histogram
nexttile;
superplot(edges(1:end-1), histoData(:, startIdx:endIdx)); %view(90,90);
set(gca,'ydir','reverse')
set(gca,'ytick',[])
xlabel({'RF data'; '(\bf{EBMV+DUSvar})'}, Interpreter='latex');
% title('EBMV+DUS')
set(gca,'fontsize',13);
set(gca,'color','none', 'box','off')


savefig('pic/EC_ones.fig')
% export as PDF
h = gcf;
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'pic/EC_ones','-dpdf','-r0')
