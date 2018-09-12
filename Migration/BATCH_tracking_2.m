%% Tracking / Movie Creation Code
% This code will track all cells from raw images of data and create movies
% out of them. It will also output information about these cells that will
% be used in later codes for analysis.

% This closes and clears all previous data. It also sets the colors that
% will be used in plots.
clear all
cmap_r = colormap('Autumn');
cmap_g = colormap('Summer');
cmap_b = colormap('Winter');
cmap_k = colormap('Bone');
close all
clc

%% Edit these

% pixel to micron calibration. ex. 10x = 1/1.13 microns per pix. For 20x,
% multiply the denominator by 2 (10*2 = 20)
pixpermic = 1/(1.13*2);

% duration between consecutive frames (in mins)
time_step = 15;

% The path name to the folder containing the raw SiRDNA images.
main_dir = 'L:\Image Data\Chung\2018-07-12 cancer migration assay\H&H (2018-07-11)) cma\';

% The path name to the folder containing the raw phase images. This may be
% the same as that for SiRDNA.
phase_dir = 'L:\Image Data\Chung\2018-07-12 cancer migration assay\H&H (2018-07-11)) cma\';

% The range of frames that you imaged, written within brackets and
% separated by a space. If desired, you can use this to limit how many
% images the code uses to create a movie. For example, if you took 100
% images but want to exclude the last 20, you may set the frame range to [1 80]
% instead of [1 100].
frame_range = [1 2*97];

% bw_thresh is the intensity threshold automatically determined by the program to define cells.
% ex. if above 1300, the object is a cell. There are times when the
% auto-detection is not good, i.e. all cells are 1000, so the 1300 criteria
% is too strict. you can multiply bw_thresh by bw_thresh_correction to
% lower. ex. bw_thresh_correction = 0.6, so 1300*0.6 = 780. Now we can
% detect cells (1000).
bw_thresh_correction = 1;

% Used to edit the minimum area that is perceived as a "cell" in the code.
% If you notice that the code is picking up a lot of junk, increasing
% area_min may help get rid of the issue. If many cells are not being
% detected, it may be helpful to decrease area_min.
area_range = [70 10000];

% The range of stages that you would like to run the code for, written
% within brackets and separated by a space. ex. for stages 1-14,
% stage_range = [1 14]. If you would like to only run the code for one
% stage, you only need to write that one stage number within brackets. ex.
% if you only want to run stage 19, stage_range = [19].
stage_list = [29 34];

% The minimum length (in microns) that a cell needs to migrate in order to
% be considered a cell. This helps filter out any cells that are not
% moving, including dead cells. A good starting point is mg_disp_thresh =
% 50. If many cells that dont move are still being tracked, this number
% should be increased. If several moving cells are not being detected, it 
% could be helpful to decrease this number.
mg_disp_thresh = 50;

%% Runs the code. First few lines may need to be edited!

for si = stage_list
    
    % This accounts for the fact that, sometimes, multiple days have
    % different file names. If this is not the case, leave the first set of
    % for loops completely commented out and only the first for loop of the
    % bottom uncommented.
    
    num_frames_day = 97;
    
    % FIRST FOR-LOOP SECTION
    for i = 1:num_frames_day
        day{i} = '';
    end
    for i = num_frames_day+1:2*num_frames_day
        day{i} = 'day2_';
    end
    %     for i = 2*num_frames_day+1+1:3*num_frames_day
    %         day{i} = '3';
    %     end
    %     for i = 2*num_frames_day+1:4*num_frames_day
    %         day{i} = '4';
    %     end
    
    % SECOND FOR-LOOP SECTION
    for i = 1:num_frames_day
        fr_i{i} = int2str(i);
    end
    for i = num_frames_day+1:2*num_frames_day
        fr_i{i} = int2str(i-num_frames_day);
    end
    %     for i = 2*num_frames_day+1:3*num_frames_day
    %         fr_i{i} = int2str(i-2*num_frames_day);
    %     end
    %     for i = 3*num_frames_day+1:4*num_frames_day
    %         fr_i{i} = int2str(i-3*num_frames_day);
    %     end
    
    % These for-loops will load in the images required to make the movies. If
    % you had to edit the above for-loops, be sure to insert day{i} where
    % appropriate.
    for i = frame_range(1):frame_range(2)
        im_filename{i} =  [main_dir,'cma_',day{i},'w1SiRDNA_s',int2str(si),'_t',fr_i{i},'.TIF'];
    end
    
    for i = frame_range(1):frame_range(2)
        phase_filename{i} = [phase_dir,'cma_',day{i},'w2DIC_s',int2str(si),'_t',fr_i{i},'.TIF'];
    end
    
    % Automatically finds the best threshold to binarize the image.
    for fi = frame_range(1):frame_range(2)
        % obtain information on the distribution of image intensity
        im = imread(im_filename{fi});
        [rec_disp_thresh, rec_bw_thresh] = im_inten_distr('plot_option',0,'image',im,'dynamic_range_max',16000,'percentile_range',[1 99]);
        bw_thresh(fi) = rec_bw_thresh*bw_thresh_correction;
        disp_thresh{fi} = rec_disp_thresh;
    end
    
    [cell, frames, n] = cell_tracking_simple_method('file_name',im_filename,'frame_range',frame_range,'maxdistpix',100,'bw_thresh',bw_thresh,'area_thresh',area_range);
    
    % "tic" simply begins a timer that will tell you how long this section
    % of the code takes to run.
    tic
    
    % Filters out any cells that migrated for less than 12 frames. for the
    % persistent random walk (PRW) model, only the first 1/3 of the data is
    % used for regression (curve fitting) to obtain the instantaneous speed
    % and the persistence time. A minimal tracking of 12 frames means at
    % least 4 data points for the regression.
    j = 1;
    for i = 1:length(cell)
        if length(cell(i).traj) >=12
            frame_filtered_cell(j) = cell(i);
            j = j+1;
        end
    end
    [analyzed_cell] = motility_param_calc('cell',frame_filtered_cell,'pixpermic',pixpermic,'time_step',time_step);
    toc
    

  % Filters out non-migratory cells (e.g. dead cells that were tracked)
% in thise case, only cells that migrated more than 50 microns (mg_disp_thresh) in
% displacement are included in the analysis
temp_cell = analyzed_cell;
    j = 1;
    for i = 1:length(temp_cell)
        if length(analyzed_cell(i).displacement) >= mg_disp_thresh
            temp_cell (j) = analyzed_cell(i);
            j = j+1;
        end
    end

analyzed_cell = temp_cell;


    % This section will automatically save the following outputs. A brief
    % description of each output is above the line of code. Outputs will be
    % saved to the same folder as that holding the code.
    
    % Displays the trajectories of the tracked and frame filtered cells.
    % Saved as 
    cell_ID_display('display_option',1,'cell',analyzed_cell,'file_name',[im_filename{1}],'im_thresh',[0 0],'frame_thresh',0);
    % A screenshot of the code with cell ID numbers for each individual
    % cell.
    saveas(gcf,['[cell ID] analyzed cell stage ',int2str(si),'.eps'],'epsc')
    % Creates a movie out of the tracked cells. Movie will show SiRDNA and
    % phase tracking sequences side-by-side.
    tracking_fidelity_check('display_option',1,'phase_file_name',phase_filename,'fluo_file_name',im_filename,'image_range',frame_range,'im_thresh',[0 0],'frame_thresh',0,'cell',analyzed_cell,'output_name',['[tracking] stage ',int2str(si)]);
    % MATLAB matrix containing all of the cell information (ex. ID number,
    % trajectory, directionality ratio, etc)
    save(['analyzed_cell stage ',int2str(si),'.mat'],'analyzed_cell')
    % MATLAB matrix of the cell position at each frame.
    save(['frames stage ',int2str(si),'.mat'],'frames')
    % MATLAB matrix of the number of cells in each frame.
    save(['n stage ',int2str(si),'.mat'],'n')
    % Plot of cell count over time (in frames).
    figure; plot(n);
    saveas(gcf,['[cell count] stage ',int2str(si),'.eps'],'epsc')
    close all
end