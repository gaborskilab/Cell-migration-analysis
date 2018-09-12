function tracking_fidelity_check(varargin)

% example =================================================================
% tracking_movie_make('phase_file_name','phase_w2Phase_s45_t','fluo_file_name','phase_w2SiRDNA_s45_t','num_frames',97,'im_thresh',[2000 5000],'frame_thresh',1,'cell',hdFb,'output_name','[tracking] automated B6A');
% =========================================================================


% This function makes a movie with the cell trajectories superimposed
% onto each frame.  This function is useful for checking the fidelity of
% tracking.
%
% INPUTS:
%           file_name       : name of image files
%
%           num_frames      : the number of frames to be processed
%
%           im_thresh       : the lower and upper intensity threshhold for display

%           cell            : cell (with all the information stored in the
%                             strutrue format)
%
%           excluded_cell   : excluded_cell (with all the information
%                             stored in the strutrue format)
%
%           output_name     : user-defined name of the made movie file
%
%           FPS             : the playback rate of the made movie (in
%                             frames per second)
%
% OUTPUTS:  a movie with the file name "output_name" that plays at a rate
%           of "FPS".  Superimposed on each frame of the movie are the
%           cell trajectories (specified by "cell").  If the
%           excluded_cell is also specifed the exluded trajectories will
%           also be superimposed on each frame in red color.


tic


% switch trap parses the varargin inputs
i=1;
while i <= length(varargin)
    switch lower(varargin{i})
        case 'phase_file_name'
            phase_file_name=varargin{i+1}; i=i+2;
        case 'fluo_file_name'
            fluo_file_name=varargin{i+1}; i=i+2;
        case 'display_option'
            display_option=varargin{i+1}; i=i+2;
        case 'image_range'
            image_range=varargin{i+1}; i=i+2;
        case 'im_thresh'
            im_thresh=varargin{i+1}; i=i+2;
        case 'frame_thresh'
            frame_thresh=varargin{i+1}; i=i+2;
        case 'cell'
            cell=varargin{i+1}; i=i+2;
        case 'output_name'
            output_name=varargin{i+1}; i=i+2;
        otherwise
            error('Unknown option: %s\n',varargin{i}); i=i+1;
    end
end

v = VideoWriter(output_name);
v.FrameRate = 14;
open(v);
% guarding against the case of having a null trajectory
j = 1;
for i=1:length(cell)
    if length(cell(i).traj) >= frame_thresh;
        frame_filtered_cell(j) = cell(i);
        j=j+1;
    end
end
%cell = frame_filtered_cell;


figure('units','normalized','outerposition',[0 0 1 1])
for i = image_range(1):image_range(2)
    i
    
    im_phase = imread(phase_file_name{i});
    im_fluo = imread(fluo_file_name{i});
    [imH, imW] = size(im_fluo);
    subplot('Position', [0, 0, 0.5, 1])
    imshow(imadjust(im_fluo));

    hold on;
    for ci = 1:length(frame_filtered_cell)
        % guarding against the case that the rounding of cell positoin produce
        % out of image positions. Rounding is need to assign a pixel loccation
        % for display (integer required)
        frame_match = find(frame_filtered_cell(ci).tracked_frames == i);
        if length(frame_match) > 0
            temp_traj = frame_filtered_cell(ci).traj(1:frame_match,:);
            %temp_traj = frame_filtered_cell(ci).traj;
            rx = round(temp_traj(:,1));
            ry = round(temp_traj(:,2));
            rx(find(rx == 0)) = 1;
            rx(find(rx > imW)) = imW;
            ry(find(ry == 0)) = 1;
            ry(find(ry > imH)) = imH;
            plot(rx, ry, 'color', frame_filtered_cell(ci).color_code, 'LineWidth',2);
            text(rx(end), ry(end),'o','color','r','FontSize',12,'FontWeight','Bold');
        end
        
        if max(frame_filtered_cell(ci).tracked_frames) < i
            temp_traj = frame_filtered_cell(ci).traj;
            %temp_traj = frame_filtered_cell(ci).traj;
            rx = round(temp_traj(:,1));
            ry = round(temp_traj(:,2));
            rx(find(rx == 0)) = 1;
            rx(find(rx > imW)) = imW;
            ry(find(ry == 0)) = 1;
            ry(find(ry > imH)) = imH;
            plot(rx, ry, 'color', frame_filtered_cell(ci).color_code, 'LineWidth',2);
            text(rx(end), ry(end),'o','color','r','FontSize',12,'FontWeight','Bold');
        end
    end

    subplot('Position', [0.5, 0, 0.5, 1])
    imshow(imadjust(im_phase));
    m = getframe(gcf);
    size(m.cdata)
    writeVideo(v,m)
    %m(i) = getframe(gcf);
end

%movie2avi(m,output_name,'FPS',7);
%v = VideoWriter(output_name);
%v.FrameRate = 14;

% open(v)
% Write the matrix of data A to the video file.
%writeVideo(v,m)
%close the file.
close(v)

toc

%tracking_movie_make_quick_full_ver('file_name',im_filename,'image_range',[1 tot_num_frames],'im_thresh',[0 0],'frame_thresh',0,'cell',analyzed_cell,'output_name',['[tracking] automated tracking stage ',int2str(si)]);
