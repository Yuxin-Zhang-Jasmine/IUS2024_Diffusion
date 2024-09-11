clc
clear
path = '~/Documents/MATLAB/01_TMI/IUS2024/';
folder = 'IUS2024_Diffusion';
addpath([path, folder, '/src']);
addpath([path, folder, '/data']);

%% Prepare By (observation) for diffusion denoising
% what we need is the normalized signed beamformed data with a scan
% (256,256), so write another script 'prepareForDiffusionDenoising.m' 
% without hilbert but inerpolate directly onto the new scan
close all
load('data/createdData.mat')
rf_scan = linear_scan();
rf_scan.read_file(['src/PICMUS16_scan.hdf5'])
rf_scan.z_axis = (linspace(rf_scan.z_axis(1), rf_scan.z_axis(end), 1215))';
scan = linear_scan(linspace(-0.018,0.018,256).', linspace(0.01,0.036+0.01,256).');

for dataname = {'contrast_expe', 'carotid_cross'}
    dataname = dataname{1}; 
    if strcmp( dataname, 'contrast_expe')
        tgcFlag = 1;
    else
        tgcFlag = 0;
    end
    noise_std = 0;

    savename = [dataname num2str(noise_std) '.mat'];
    By = prepareForDiffusionDenoising(eval(dataname), rf_scan, scan, tgcFlag);
    figure; Image_realScale(By, 'EBMV 256*256', scan)
    
    % vectorize to python index
    By = By';
    By = By(:);
    figure; plot(By)
    %save([path folder '/data/By/' savename], "By");
end
