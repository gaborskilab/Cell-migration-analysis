function [healer, n] = healer_seek(varargin)

% switch trap parses the varargin inputs
i=1;
while i <= length(varargin)
    switch lower(varargin{i})
        case 'cell'
            cell = varargin{i+1}; i=i+2;
        case 'wound_region'
            wound_region = varargin{i+1}; i=i+2;
        case 'num_frames'
            num_frames = varargin{i+1}; i=i+2;
        case 'frame_thresh'
            frame_thresh = varargin{i+1}; i=i+2;
        case 'frame_range'
            frame_range = varargin{i+1}; i=i+2;
        otherwise
            error('Unknown option: %s\n',varargin{i}); i=i+1;
    end
end

[n_rows,n_cols] = size(wound_region);
% guarding against the case of having a null or short trajectory
j = 1;
for i=1:length(cell);
    if length(cell(i).traj) > frame_thresh;
        frame_filtered_cell(j) = cell(i);
        j=j+1;
    end
end

% find the cells of interest (e.g. those with final position inside the
% wound region)
j=1;
for i = 1:length(frame_filtered_cell)
    traj_map = zeros(n_rows,n_cols);
    end_x = frame_filtered_cell(i).traj(end,1);
    end_y = frame_filtered_cell(i).traj(end,2);
    rx = round(end_x);
    ry = round(end_y);
    rx(find(rx == 0)) = 1;
    rx(find(rx > n_cols)) = n_cols;
    ry(find(ry == 0)) = 1;
    ry(find(ry > n_rows)) = n_rows;
    
    traj_map(ry, rx) = 1;
    if sum(sum(traj_map.*wound_region))==1
        healer(j) = frame_filtered_cell(i);
        j=j+1;
    end
    
end

% make sure to have an output even if no cells were found in the wound
% region
if j == 1
    healer = [];
end

cell_map = zeros(n_rows,n_cols,num_frames); % Image of cell position
% track the number of cells migrating into the wound region over time
for i = 1:length(cell)
    x = cell(i).traj(:,1);
    y = cell(i).traj(:,2);
    rx = round(x);
    ry = round(y);
    rx(find(rx <= 0)) = 1;
    rx(find(rx > 1004)) = n_cols;
    ry(find(ry <= 0)) = 1;
    ry(find(ry > 1002)) = n_rows;
    ts = cell(i).tracked_frames(1); % time start
    te = cell(i).tracked_frames(end); % time end
    for j = ts:te
        cell_map(ry(j-ts+1),rx(j-ts+1),j) = 1; % j = different frames, ry and rx = positions
    end
end

% This truncates data to the specified frame range.
truncated = cell_map(:,:,frame_range(1):frame_range(2));

for i = 1:frame_range(2)-frame_range(1)+1
    n(i) = sum(sum(truncated(:,:,i).*wound_region)); %number of cells in wound
end



