function [] = ROIplot_reso(scan,phantom)
    maskROI = zeros(size(scan.x_matrix));
    padROI = 1.6e-3 * 1;
    for k=1:size(phantom.sca,1)             
        %-- Compute mask inside
        x = phantom.sca(k,1);
        z = phantom.sca(k,3);                
        %-- Compute mask ROI
        mask = k * ( (scan.x_matrix > (x-padROI*1.9)) & ...
                     (scan.x_matrix < (x+padROI*1.9)) & ...
                     (scan.z_matrix > (z-padROI*0.9)) & ...
                     (scan.z_matrix < (z+padROI*0.9)) );
        maskROI = maskROI + mask;                
    end
    hold on; contour(scan.x_axis*1e3,scan.z_axis*1e3,maskROI,[1 1],'y-','linewidth',1.5);
    
end

