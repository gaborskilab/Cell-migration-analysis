function [cell, frames, n] = cell_tracking_simple_method(varargin)

% example =================================================================
% [traj, spm, frames] = cell_tracking_simple_method('file_name','image','num_frames',17,'maxdistpix',10,'edge_detection_method','sobel','expansion_factor',2, 'area_thresh', [10,40]);
%
% the 'edge_detection_method' can be 'sobel', 'prewitt', 'roberts', 'log',
% 'zerocross', and 'canny'
% 'sobel' and 'log' is highly recommended.
% =========================================================================



% This function takes in a moviename string ('file_name') and the proposed
% maximum distance a cell can move from one frame to another ('maxdistpix')
% and calculates cell trajectories ('traj'), starting point matrix ('spm'), and points
% identified as cells in each frame ('frames').  The cells are deteced
% using the edge detection method, as described in the function
% 'cell_ID_edge_detection_method'



% INPUTS:   file_name   : name of tiff stack in which images have been compiled
%           num_frames  : the number of frames of images to be analyzed
%
%           maxdistpix  : maximum distance in pixles a cell can move from
%                         one frame to the next. Usually for a sampling time of 5 min we
%                         used a distance of 10pix (2.5 min = 5 pix)
%
%           edge_detection_method: the method can either be [] or 'log'
%
%           expansion_factor: number of pixels to expand
%           area_thresh  : the range of the number of pixels that a cell area can be



% OUTPUTS:  traj        : This is a (MATLAB) cell array of what the
%                         algorithm figures are (biological) cell trajectories,
%                         one (MATLAB) cell per trajectory.  Each trajectory is
%                         an Nx2 matrix where each row has the x and y coordinates
%                         for the centroid of the cell at that point in the trajectory.
%                         The units on the coordinates are image pixels
%
%           spm         : SPM stands for starting point matrix.  This is an Nx4 matrix
%                         where each row contains information about the corresponding
%                         trajectory in traj.  So, spm(i,:) has info about the trajectory
%                         in traj{i}.  The first two columns contain the starting x and y
%                         coordinates for each trajectory, the third column contains the
%                         starting frame number for that trajectory, and the fourth column
%                         is the number of frames in that trajectory (=size(traj{i},1)).
%
%           frames      : This is a cell array of lists of every single cell centroid
%                         identified during processing in each frame of the movie.  So,
%                         if there were N cells identified in frame 1, then frames{1}
%                         is an Nx2 matrix listing the x and y coordinates of each centroid
%                         found.

tic

% switch trap parses the varargin inputs
i=1;
while i <= length(varargin)
    switch lower(varargin{i})
        case 'file_name'
            file_name = varargin{i+1}; i=i+2;
        case 'frame_range'
            frame_range = varargin{i+1}; i=i+2;
        case 'maxdistpix'
            maxdistpix = varargin{i+1}; i=i+2;
        case 'bw_thresh'
            bw_thresh = varargin{i+1}; i=i+2;
        case 'area_thresh'
            area_thresh = varargin{i+1}; i=i+2;
        otherwise
            error('Unknown option: %s\n',varargin{i}); i=i+1;
    end
end


for i = frame_range(1):frame_range(2)
    i
    im = imread(file_name{i});
    
    di = i - frame_range(1)+1;
   
    
    bw_im = im > bw_thresh(i);
    se = strel('disk',3);
    bw_im = imerode(bw_im,se);
    %figure; imshow(bw_im);
    min_area = area_thresh(1);
    max_area = area_thresh(2);
    
    % Label 8-connected objects
    label_mat = bwlabeln(bw_im,8);
    if max(max(label_mat))~=0 %features were found
        % Collect centroids and areas
        p = regionprops(label_mat, 'Area', 'Centroid');
        areas = cat(1, p.Area);
        toosmall = find(areas<min_area | areas>max_area);
        p(toosmall) = [];
        centroids = cat(1, p.Centroid);
    else	% no cells found
        centroids = [];
    end
    % Store centroids for this frame
    frames{di} = centroids;
    n(di) = length(frames{di});
    disp(['There are ' num2str(length(centroids)) ' found in this frame'])
    
end

[traj, spm] = distcalc(frames,maxdistpix);

% traj is a cell array of trajectories and spm is an index of starting
% coordinates of trajectories along with the frame in which they start

for i = 1:length(traj)
    len(i) = length(traj{i});
end
% len is the length of each trajectory in steps
spm(:,4) = len';

toc
for i=1:length(traj);
    a(i)=length(traj{i});
end
figure
hist(a,50); %creates a histrogram of the number of frames over which a cell is tracked vs. how often this value occurs
ylabel('occurence');
xlabel('number of frames over which a cell is tracked');
title('Cell Tracking vs. Occurence');

for i = 1:length(traj)
    cell(i).id = i;
    cell(i).traj = traj{i};
    cell(i).color_code = [rand rand rand];
    cell(i).tracked_frames = [spm(i,3):spm(i,3)+spm(i,4)-1];
end

return


