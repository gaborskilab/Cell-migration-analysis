function cell_ID_display(varargin)

% example =================================================================
% cell_ID_display('cell',filtered_hPMN,'file_name','sIL8_grad_d_1.tiff');
% =========================================================================


% This function superimposes virus trajectories and their associated ID#
% onto a user-specifed image.  The ID#'s will be in red and located right
% at the starting positions of the trajectories.  This function is useful
% for keeping track the virus trajectories, especially useful when one need
% to manually remove the viruses to be excluded from the analysis.  When
% the excluded_virus is also specifed the exluded trajectories will also be
% superimposed on each frame in red color.
%
% INPUTS:
%           file_name       : name of image files
%
%           cell            : cell (with all the information stored in the
%                             structure format)
%
%           excluded_cell   : excluded_cell (with all the information
%                             stored in the structure format)
%
% OUTPUTS:  an image with the trajectories (specified by "cell")
%           superimposed.  The associated ID#'s of the trajectories will
%           also be displayed in red and located right at the starting
%           positions of the trajectories.  When the excluded_cell is also
%           specifed the exluded trajectories will also be superimposed on
%           each frame in red color.


% switch trap parses the varargin inputs
i=1;
while i <= length(varargin)
    switch lower(varargin{i})
        case 'display_option'
            display_option=varargin{i+1}; i=i+2;
        case 'cell'
            cell=varargin{i+1}; i=i+2;
        case 'file_name'
            file_name=varargin{i+1}; i=i+2;
        case 'im_thresh'
            im_thresh=varargin{i+1}; i=i+2;
        case 'frame_thresh'
            frame_thresh=varargin{i+1}; i=i+2;
        otherwise
            error('Unknown option: %s\n',varargin{i}); i=i+1;
    end
end


figure;
im = imread(file_name);
im = im(:,:,1);
if im_thresh == [0 0]
    imshow(imadjust(im))
else
    imshow(im, im_thresh);
end

% guarding against the case of having a null trajectory
j = 1;
for i=1:length(cell);
    if length(cell(i).traj) > frame_thresh;
        frame_filter(j) = cell(i);
        j=j+1;
    end
end
cell = frame_filter;

[nRows, nCols] = size(im);
hold on; %enables the trajectories of all cells to be plotted on the same axis as the tiff image
for i=1:length(cell)
    % guarding against the case that the rounding of cell positoin produce
    % out of image positions. Rounding is need to assign a pixel loccation
    % for display (integer required)
    temp_traj = cell(i).traj;
    rx = round(temp_traj(:,1));
    ry = round(temp_traj(:,2));
    rx(find(rx == 0)) = 1;
    rx(find(rx > nCols)) = nCols;
    ry(find(ry == 0)) = 1;
    ry(find(ry > nRows)) = nRows;
    plot(rx, ry, 'Color', cell(i).color_code, 'LineWidth',2);
    if display_option ==1
        text(rx(1), ry(1), num2str(cell(i).id),'Color', 'r', 'FontWeight','Bold', 'FontSize',12);
    end
end
hold off
% set background color to white
set(gcf, 'color', 'white');
