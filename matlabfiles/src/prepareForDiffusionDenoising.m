function [resampled_beamformed_data] = prepareForDiffusionDenoising(beamformed_data, rf_scan, scan, tgcFlag)
%    % --TGC
%     time_vector = dataset.initial_time+(0:(K-1))/dataset.sampling_frequency;
%     tgc1 = time_vector'./max(time_vector);
%     tgc1 = exp(4*tgc1);            % simu_reso=4.5, simu_cont=expe_reso=expe_cont=4
%     tgc1(1:k+150) = tgc1(k+150);   % don't compensate the fist k+150 samples (avoid the darkness in above)
%     yPICMUS = yPICMUS .* tgc1;

    %-- attenuation
    if tgcFlag
        depth_vector = rf_scan.z_axis' ./ max(rf_scan.z_axis);
        tgc = exp(4*depth_vector);
        tgc(1:150) = tgc(150);   % don't compensate the fist k+150 samples (avoid the darkness in above)
        %atte_one = linspace(1,50,rf_scan.Nz); 
        atte_all = repmat(tgc, 1, rf_scan.Nx);
        atte_beamformed_data = atte_all' .* beamformed_data;
    else
        atte_beamformed_data = beamformed_data;
    end
    %-- reshape
    reshaped_beamformed_data = reshape(atte_beamformed_data,[numel(rf_scan.z_axis) numel(rf_scan.x_axis)]);
    
    
    %-- interpolate the requested grid
    resampled_beamformed_data = zeros(numel(scan.z_axis),numel(rf_scan.x_axis));
    resampled_beamformed_data(:,:) = interp1(rf_scan.z_axis,reshaped_beamformed_data(:,:),scan.z_axis,'linear',0);
    
    %resampled_beamformed_data = zeros(numel(scan.z_axis),numel(scan.x_axis));
    resampled_beamformed_data = interp1(rf_scan.x_axis,resampled_beamformed_data',scan.x_axis,'linear',0);
    resampled_beamformed_data = resampled_beamformed_data'./max(abs(resampled_beamformed_data(:)));
end