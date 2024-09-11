function [] = ROIplot_full(scan,phantom)
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
    padding = 1;
    x = scan.x_matrix;
    z = scan.z_matrix;  
    for k=1:length(phantom.occlusionDiameter)
        r = phantom.occlusionDiameter(k) / 2;
        rin = r - padding * phantom.lateralResolution;
        rout1 = r + padding * phantom.lateralResolution;
        rout2 = 1.1*sqrt(rin^2+rout1^2);
        xc = phantom.occlusionCenterX(k);
        zc = phantom.occlusionCenterZ(k);
        maskOcclusion = ( ((x-xc).^2 + (z-zc).^2) <= r^2);
        maskInside = ( ((x-xc).^2 + (z-zc).^2) <= rin^2);
        maskOutside = ( (((x-xc).^2 + (z-zc).^2) >= rout1^2) & ...
                     (((x-xc).^2 + (z-zc).^2) <= rout2^2) );
    %     hold on; contour(scan.x_axis*1e3,scan.z_axis*1e3,maskOcclusion,[1 1],'y-','linewidth',1.5);
        hold on; contour(scan.x_axis*1e3,scan.z_axis*1e3,maskInside,[1 1],'r-','linewidth',1.5);
        hold on; contour(scan.x_axis*1e3,scan.z_axis*1e3,maskOutside,[1 1],'g-','linewidth',1.5);
    end
    
    padROIx = phantom.RoiPsfTimeX * phantom.lateralResolution;
    padROIz = phantom.RoiPsfTimeZ * phantom.axialResolution;   
    for k=1:length(phantom.RoiCenterX)
        %-- Compute mask inside
        x = phantom.RoiCenterX(k);
        z = phantom.RoiCenterZ(k);
        %-- Compute mask ROI
        maskROI = k * ( (scan.x_matrix > (x-padROIx(k))) & ...
                     (scan.x_matrix < (x+padROIx(k))) & ...
                     (scan.z_matrix > (z-padROIz(k))) & ...
                     (scan.z_matrix < (z+padROIz(k))) );
        hold on; contour(scan.x_axis*1e3,scan.z_axis*1e3,maskROI,[1 1],'b-','linewidth',1.5);
    end
end

