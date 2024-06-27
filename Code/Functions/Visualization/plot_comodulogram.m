function plot_comodulogram(PAC_mat,high,low, color_range)
    
    % This function plot the comodulogram
    %   INPUTS:
    %   PAC_mat   : PAC values for required frequency
    %   high      : High frequency range for plotting the comodulogram
    %   low       : Low frequency range for plotting the comodulogram

    % plot comodulogram
    figure('WindowState', 'maximized');
    xticks = low;
    yticks=high;
    
    pcolor(low, high, PAC_mat);
    
    shading(gca,'interp'); 
    colormap(jet);
    set(gca,'FontSize',10);
    xlabel('Phase Frequency (Hz)','FontSize',10);ylabel('Amplitude Frequency (Hz)','FontSize',10);
    set(gca,'FontName','Arial');
    set(gca,'XTick',xticks);
    colorbar
    set(gca,'CLim',color_range);

end