function [ensemble, m_v_t, se_v_t] = evolution_DA(varargin)
% switch trap parses the varargin inputs
i=1;
while i <= length(varargin)
    switch lower(varargin{i})
        case 'frame_thresh'
            frame_thresh = varargin{i+1}; i=i+2;
        case 'cell'
            cell = varargin{i+1}; i=i+2;
        case 'num_frames'
            num_frames = varargin{i+1}; i=i+2;
        case 'frame_range'
            frame_range = varargin{i+1}; i=i+2;
        otherwise
            error('Unknown option: %s\n',varargin{i}); i=i+1;
    end
end

j = 1;
for i=1:length(cell);
    if length(cell(i).traj) >= frame_thresh;
        frame_filtered(j) = cell(i);
        j=j+1;
    end
end
cell = frame_filtered;

% =========================================================================
% create a matrix to hold data
% =========================================================================
num_cells = length(cell);
ensemble = -1*ones(num_cells, num_frames);
for j = 1:num_cells
    strt_frame = cell(j).tracked_frames(1);
    end_frame = cell(j).tracked_frames(end);
    ensemble(j,strt_frame+1:end_frame) = [cell(j).DR]';
end
% temp = ensemble(:,num_frames);
% ensemble = temp;

% =========================================================================
% average the data over all cells
% =========================================================================
for i = 1:num_frames
    temp = ensemble(:,i);
    filtered = temp(find(temp ~= -1));
    n(i) = length(filtered);
    m_v_t(i) = mean(filtered);
    se_v_t(i) = std(filtered)/sqrt(n(i));
    clear temp filtered
end


