clc
clear
close all
path = '~/Documents/MATLAB/01_TMI/IUS2024/';
folder = 'IUS2024_Diffusion';
addpath([path, folder, '/src']);
addpath([path, folder, '/data']);

%% Displaying the results: EC_abs  
setIndex = 1;
scan = linear_scan(linspace(-0.018,0.018,256).', linspace(0.01,0.036+0.01,256).');
path_phantom = ['src/phantoms/picmus_phantom_4.hdf5'];
phantom = us_phantom();
phantom.read_file(path_phantom);

x_lim = [0.00625 0.01225]*1e3; 
z_lim = [0.0361 0.0389]*1e3;

nr = 2; nc = 4;
hf = figure('Position', [63 10 870 870]);

% DAS75, DAS1, DASdenoMedian, DASdenoVar, EBMV, EBMVnoisy, ebmvDenoMedian ebmvDenoVar
% Define positions for an 8-subplot (2x4) layout
pos1 = [0.005 0.47 0.24 0.47]; % Top-left
pos2 = [0.255 0.47 0.24 0.47]; % Top-center-left
pos3 = [0.505 0.47 0.24 0.47]; % Top-center-right
pos4 = [0.755 0.47 0.24 0.47]; % Top-right

%pos5 = [0.005 -0.05 0.24 0.47]; % Bottom-left
pos6 = [0.255 -0.05 0.24 0.47]; % Bottom-center-left
pos7 = [0.505 -0.05 0.24 0.47]; % Bottom-center-right
pos8 = [0.755 -0.05 0.24 0.47]; % Bottom-right

% GT
imgIndex = 1;
algoIndex = 1;
ax1 = axes('Position', pos1); % Define the position for the first subplot
t1 = tiledlayout(2, 1,'TileSpacing','none', 'Padding', 'none', 'Position', pos1);
nexttile(t1);
load data/DAS75/contrast_expe.mat 
Image_realScale(x, 'DAS75', scan);
ImageSet{setIndex, algoIndex} = us_image();
ImageSet{setIndex, algoIndex}.scan = scan;
ImageSet{setIndex, algoIndex}.number_plane_waves=1;
ImageSet{setIndex, algoIndex}.postenv = 0;
ImageSet{setIndex, algoIndex}.data = abs(x); 
ROIplot_full(scan, phantom)

nexttile;
Image_realScale(x, 'DAS75', scan);
ROIplot_full(scan, phantom)
axis([x_lim z_lim]);
set(gca,'fontsize',21); colorbar off; axis off; title('')

% DAS1
imgIndex = imgIndex + 1;
algoIndex = algoIndex + 1;
ax2 = axes('Position', pos2);
t2 = tiledlayout(2, 1,'TileSpacing','none', 'Padding', 'none', 'Position', pos2);
load data/By/contrast_expe_das.mat
nexttile(t2);
Image_realScale((reshape(By,[256,256]))', 'DAS1', scan);
ImageSet{setIndex, algoIndex} = us_image();
ImageSet{setIndex, algoIndex}.scan = scan;
ImageSet{setIndex, algoIndex}.number_plane_waves=1;
ImageSet{setIndex, algoIndex}.postenv = 0;
ImageSet{setIndex, algoIndex}.data = (reshape(abs(By),scan.Nz, scan.Nx))'; 
ROIplot_reso(scan, phantom)

nexttile;
Image_realScale((reshape(By,[256,256]))', 'DAS1', scan);
ROIplot_reso(scan, phantom)
axis([x_lim z_lim]);
set(gca,'fontsize',21); colorbar off; axis off; title('')

% DAS DiffusionDenoising (Median)
imgIndex = imgIndex + 1;
ax3 = axes('Position', pos3);
t3 = tiledlayout(2, 1,'TileSpacing','none', 'Padding', 'none', 'Position', pos3);
nexttile(t3);
c = 10;
X = zeros(c,256,256);
for i = 1: c
    load(['data/dasdeno/contrast_expe/' num2str(i) '_-1.mat'])
    X(i,:,:) = squeeze(x);
end
Image_realScale(squeeze(median(X,1)), 'DAS1+DUSmedian', scan);
ROIplot_reso(scan, phantom)

nexttile;
Image_realScale(squeeze(median(X,1)), 'DAS1+DUSmedian', scan);
ROIplot_reso(scan, phantom)
axis([x_lim z_lim]);
set(gca,'fontsize',21); colorbar off; axis off; title('')


% DAS DiffusionDenoising (Variance)
imgIndex = imgIndex + 1;
algoIndex = algoIndex + 1;
ax4 = axes('Position', pos4);
t4 = tiledlayout(2, 1,'TileSpacing','none', 'Padding', 'none', 'Position', pos4);
nexttile(t4);
Image_realScale(squeeze(var(X,1)), 'DAS+DUSvar', scan);
ImageSet{setIndex, algoIndex} = us_image();
ImageSet{setIndex, algoIndex}.scan = scan;
ImageSet{setIndex, algoIndex}.number_plane_waves=1;
ImageSet{setIndex, algoIndex}.postenv = 0;
ImageSet{setIndex, algoIndex}.data = reshape(squeeze(var(X,1)),scan.Nz, scan.Nx); 
ROIplot_reso(scan, phantom)

nexttile;
Image_realScale(squeeze(var(X,1)), 'DAS+DUSvar', scan);
ROIplot_reso(scan, phantom)
axis([x_lim z_lim]);
set(gca,'fontsize',21); colorbar off; axis off; title('')


% EBMV
imgIndex = imgIndex + 1;
algoIndex = algoIndex + 1;
ax6 = axes('Position', pos6);
t6 = tiledlayout(2, 1,'TileSpacing','none', 'Padding', 'none', 'Position', pos6);
load data/By/contrast_expe0.mat
nexttile(t6);
Image_realScale((reshape(By,[256,256]))', 'EBMV', scan);
ImageSet{setIndex, algoIndex} = us_image();
ImageSet{setIndex, algoIndex}.scan = scan;
ImageSet{setIndex, algoIndex}.number_plane_waves=1;
ImageSet{setIndex, algoIndex}.postenv = 0;
ImageSet{setIndex, algoIndex}.data = reshape(abs((reshape(By,[256,256]))'),scan.Nz, scan.Nx); 
ROIplot_reso(scan, phantom)

nexttile;
Image_realScale((reshape(By,[256,256]))', 'EBMV', scan);
ROIplot_reso(scan, phantom)
axis([x_lim z_lim]);
set(gca,'fontsize',21); colorbar off; axis off; title('')


% EBMV DiffusionDenoising (Median)
imgIndex = imgIndex + 1;
ax7 = axes('Position', pos7);
t7 = tiledlayout(2, 1,'TileSpacing','none', 'Padding', 'none', 'Position', pos7);
nexttile(t7);
c = 10;
X = zeros(c,256,256);
for i = 1: c
    load(['data/ebmvdeno/contrast_expe/' num2str(i) '_-1.mat'])
    if size(x,1) == 1 
        X(i,:,:) = squeeze(x);
    else
        X(i,:,:) = squeeze(mean(x));
    end
end
Image_realScale(squeeze(median(X,1)), 'EBMV+DUSmedian', scan);
ROIplot_reso(scan, phantom)

nexttile;
Image_realScale(squeeze(median(X,1)), 'EBMV+DUSmedian', scan);
ROIplot_reso(scan, phantom)
axis([x_lim z_lim]);
set(gca,'fontsize',21); colorbar off; axis off; title('')


% EBMV DiffusionDenoising (Variance)
imgIndex = imgIndex + 1;
algoIndex = algoIndex + 1;
ax8 = axes('Position', pos8);
t8 = tiledlayout(2, 1,'TileSpacing','none', 'Padding', 'none', 'Position', pos8);
nexttile(t8);
Image_realScale(squeeze(var(X,1)), 'EBMV+DUSvar', scan);
ImageSet{setIndex, algoIndex} = us_image();
ImageSet{setIndex, algoIndex}.scan = scan;
ImageSet{setIndex, algoIndex}.number_plane_waves=1;
ImageSet{setIndex, algoIndex}.postenv = 0;
ImageSet{setIndex, algoIndex}.data = reshape(abs(squeeze(var(X,1))),scan.Nz, scan.Nx); 
ROIplot_reso(scan, phantom)

nexttile;
Image_realScale(squeeze(var(X,1)), 'EBMV+DUSvar', scan);
ROIplot_reso(scan, phantom)
axis([x_lim z_lim]);
set(gca,'fontsize',21); colorbar off; axis off; title('')

% Tune the size and save the figure
hf.Position =  [63 10 575 579]; 
annotation(gcf,'arrow',[0.224347826086957 0.295652173913044],...
    [0.0231796200345423 0.0621761658031088],'Color',[1 0 0],'LineWidth',3,...
    'HeadWidth',15,...
    'HeadLength',15);
annotation(gcf,'arrow',[0.373913043478262 0.445217391304349],...
    [0.0231796200345423 0.0621761658031088],'Color',[1 0 0],'LineWidth',3,...
    'HeadWidth',15,...
    'HeadLength',15);
annotation(gcf,'arrow',[0.481739130434786 0.553043478260873],...
    [0.0145440414507772 0.0535405872193437],'Color',[1 0 0],'LineWidth',3,...
    'HeadWidth',15,...
    'HeadLength',15);
annotation(gcf,'arrow',[0.634782608695657 0.706086956521745],...
    [0.0128169257340242 0.0518134715025906],'Color',[1 0 0],'LineWidth',3,...
    'HeadWidth',15,...
    'HeadLength',15);

pause(0.5)
colorbar('Position', [0.1 0.02 0.07 0.8], 'FontSize',12); % has to be after hf.Position
pause(1)
savefig('pic/EC_abs.fig')

% export as PDF
h = gcf;
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'pic/EC_abs','-dpdf','-r0')



%% Displaying the results: cross_abs
scan = linear_scan(linspace(-0.018,0.018,256).', linspace(0.01,0.036+0.01,256).');

nr = 1; nc = 5;
figure('Position', [109 373 1166 187]); 
% DAS75, DAS1, DASdenoVar, EBMV, ebmvDenoVar
tCross = tiledlayout(1, 5,'TileSpacing','compact', 'Padding', 'compact', 'Position', [0.05,0.08,0.89,0.93]);

% DAS75
nexttile(tCross);
load data/DAS75/carotid_cross.mat
Image_realScale(x, 'DAS75', scan);
axis on
colorbar;

% DAS1
nexttile;
load data/By/carotid_cross_das.mat
Image_realScale((reshape(By, [256, 256]))', 'DAS1', scan);
axis on
colorbar;

% DASdenoVar 
nexttile;
c = 10;
X = zeros(c, 256, 256);
for i = 1: c
    load(['data/dasdeno/carotid_cross/' num2str(i) '_-1.mat']);
    X(i,:,:) = squeeze(x);
end 
Image_realScale(squeeze(var(X,1)), 'DAS1+DUSvar', scan);
axis on
colorbar;

% EBMV
nexttile;
load data/By/carotid_cross0.mat
Image_realScale((reshape(By,[256,256]))', 'EBMV', scan);
axis on
colorbar;

% ebmvDenoVar
nexttile;
c = 10;
X = zeros(c,256,256);
for i = 1: c
    load(['data/ebmvdeno/carotid_cross/' num2str(i) '_-1.mat'])
    X(i,:,:) = squeeze(x);
end
Image_realScale(squeeze(var(X,1)), 'EBMV+DUSvar', scan);
axis on
colorbar;

savefig('pic/Cross_abs.fig')
% export as PDF
h = gcf;
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'pic/Cross_abs','-dpdf','-r0')


%% Evaluation of EC results
flag_display = 0;
j = 1;
for i = 1: algoIndex
    [~, ~, CNRs(j,i), gCNRs(j,i), SNRs(j,i), KSs(j,i)] = evaluation(path_phantom, ImageSet{j, i}, flag_display);
    
    ImageSet{j, i}.postenv = 1;
    [FWHMAs(j,i), ~, ~, ~, ~, ~] = evaluation(path_phantom, ImageSet{j, i}, flag_display);

    ImageSet{j, i}.postenv = 2;
    [~, FWHMLs(j,i), ~, ~, ~, ~] = evaluation(path_phantom, ImageSet{j, i}, flag_display);

end
% DAS75, DAS1, DAS+DUSvar, EBMV, EBMV+DUSvar
save([path  filesep folder '/scores/EC_Metrics_Abs'],"FWHMAs", "FWHMLs", "gCNRs", "SNRs")

