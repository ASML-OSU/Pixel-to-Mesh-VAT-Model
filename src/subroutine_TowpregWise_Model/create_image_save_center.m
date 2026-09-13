%% Setup the image

fig = figure(203);
ax = gca;
set(gcf,'color','w')

% 1. Set fixed axis limits
xlim(ax, [0, Plate.length]);
ylim(ax, [0, Plate.width]);
axis(ax, 'manual');  % lock axis limits
axis(ax, 'off');     % optional: hide axis ticks and labels

% 2. Make the axes fill the figure (important for cropping)
set(ax, 'Units', 'normalized', 'Position', [0 0 1 1]);

% 3. Set figure size (optional but useful for precise control)
set(fig, 'Units', 'inches', 'Position', [1 1 4 3]);  % 4 in x 3 in figure
set(fig, 'PaperUnits', 'inches', 'PaperPosition', [0 0 4 3]);
set(fig, 'PaperPositionMode', 'manual');

% 4. Export the figure cropped to this axis region

full_file_path = [lamina_layer_tows_no_folder filesep 'single_tape_' num2str(real_tape_num)];

export_fig(full_file_path, '-png', '-r300', '-nocrop');

% 5. Save centerline of this tape for subsequent fiber path calculation

tape_centerline = ['centerline_' num2str(real_tape_num) '.txt'];
data_full_file_path = fullfile(lamina_layer_tows_no_folder,tape_centerline);
writematrix(middle_line,data_full_file_path,'Delimiter','tab')

