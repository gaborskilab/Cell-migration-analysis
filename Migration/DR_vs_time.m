function [DR_vs_t] = DR_vs_time(varargin)

% example =================================================================
% [data_DR] = DR_vs_time('trajectory',test_traj,'plot_option',1);
% =========================================================================

% switch trap parses the varargin inputs
i=1;
while i <= length(varargin)
    switch lower(varargin{i})
        case 'trajectory'
            trajectory = varargin{i+1}; i=i+2;
        case 'plot_option'
            plot_option = varargin{i+1}; i=i+2;
        otherwise
            error('Unknown option: %s\n',varargin{i}); i=i+1;
    end
end

% calculate directionality ratio of a cell trajectory through the
% progression of time.

for i = 1:length(trajectory)
    temp_trajectory = trajectory(1:i,:);
    x = temp_trajectory(:,1);
    y = temp_trajectory(:,2);
    
    sh_x = shift(x,2);
    sh_y = shift(y,2);
    
    x(end) = [];
    y(end) = [];
    sh_x(end)=[];
    sh_y(end) = [];
    
    x_diff = x - sh_x;
    y_diff = y - sh_y;
    
    x2 = x_diff.^2;
    y2 = y_diff.^2;
    
    dists = sqrt(x2+y2);
    pathlength = sum(dists);
    displacement = sqrt((temp_trajectory(end,1)-temp_trajectory(1,1))^2 + (temp_trajectory(end,2)-temp_trajectory(1,2))^2);
    DR_vs_t(i) = displacement/pathlength;
end
DR_vs_t(1) = [];
if plot_option == 1
    figure;
    plot(DR_vs_t);
end

return
