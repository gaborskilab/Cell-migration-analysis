function cell_ID_display(varargin)

% example =================================================================
% cell_ID_display('cell',filtered_hPMN,'excluded_cell',[],'file_name','sIL8_grad_d_1.tiff', 'im_thresh',[0 0]);
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
%           im_thresh       : threshold for adjusting image contrast, use
%                             [0 0] for authothresholding
%
% OUTPUTS:  an image with the trajectories (specified by "cell") 
%           superimposed.  The associated ID#'s of the trajectories will
%           also be displayed in red and located right at the starting
%           positions of the trajectories. 

% switch trap parses the varargin inputs
i=1;
while i <= length(varargin)
    switch lower(varargin{i})
        case 'cell'
            cell=varargin{i+1}; i=i+2;
        case 'file_name'
            file_name=varargin{i+1}; i=i+2;
        case 'im_thresh'
            im_thresh=varargin{i+1}; i=i+2;
        otherwise
            error('Unknown option: %s\n',varargin{i}); i=i+1;
    end
end


figure('Name','Cell Tracking','NumberTitle','off'); %adds the window title 
im = imread(file_name);
im = im(:,:,1);

imshow(im,im_thresh); %shows the image that was just read
hold on; %enables the trajectories of all cells to be plotted on the same axis as the tiff image

%plotting the trajectories of each cell on the same figure
for i=1:length(cell)
    plot(round(cell(i).traj(:,1)),round(cell(i).traj(:,2)), 'Color', cell(i).color_code);
    text(round(cell(i).traj(1,1)),round(cell(i).traj(1,2)), num2str(cell(i).id),'Color', 'r', 'FontWeight','Bold', 'FontSize',10);
    hold on; %enables all trajectories to be plotted on a single plot
end

% set background color to white
set(gcf, 'color', 'white');
