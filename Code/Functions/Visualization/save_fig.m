function save_fig(save_path, fig_title)

    if exist(save_path, 'dir') ~= 7
        mkdir(save_path);
    end
    
    figFilePath = strcat(save_path, fig_title, '.fig');
    savefig(figFilePath);
    % Save the figure as .png
    pngFilePath = strcat(save_path, fig_title, '.png');
    saveas(gcf, pngFilePath);
end