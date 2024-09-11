function [] = Image_realScale(img1, tit1, scan0, varargin)

    vrange = [-60 0];
    im = reshape(abs(img1),[scan0.Nz,scan0.Nx]);
    im = 20*log10(im./max(im(:)));

    %-- setting axis limits (mm)
    x_lim = [min(scan0.x_matrix(:)) max(scan0.x_matrix(:))]*1e3; 
    z_lim = [min(scan0.z_matrix(:)) max(scan0.z_matrix(:))]*1e3;
    
    imagesc((scan0.x_axis)*1e3,(scan0.z_axis)*1e3, im); 
    shading flat; colormap gray; caxis(vrange);  hold on; axis equal manual;  
    xlabel('x [mm]'); ylabel('z [mm]'); 
    set(gca,'YDir','reverse'); 
    %colorbar;
    set(gca,'fontsize',10);  axis([x_lim z_lim]); title(tit1); 
    axis off
end

