%% What this code does
% This code will take data from migrations and give you the speed,
% displacement, and directionality ratio within each
% condition. Therefore, this code allows you to compare the stages of each
% condition to each other. You can specify which stages and time ranges
% you would like to analyze for each condition.

% The chunk of code below clears all previous MATLAB data and sets colors
% used in plots. It does not need to be edited.
cmap_r = colormap('Autumn');
cmap_g = colormap('Summer');
cmap_b = colormap('Winter');
cmap_k = colormap('Bone');
close all
clc

%% Edit these

%  The total number of frames that were imaged (NOT the total that are
%  being analyzed, but the total overall).
num_frames = 2*48;

% The list of conditions that are being analyzed, stored as strings.
condition_list = {'DMEM Only', 'Exo Free', 'DMEM+', 'ADSC', 'EGF', 'HUVEC', 'FB 100%', 'FB 50-50%'};

% Location of analyzed cell stage
main_dir_analyzed_cell = 'L:\Image Data\Aslan\Summer 2018\Exosome Migration\Second Wound Healing\[ Aslan Analysis ]\';

% The name of the "analyzed cell stage" files from BATCH_tracking_2. Does
% not need to be changed unless you changed the name of the output in that
% code.
cell_stage_filename = 'analyzed_cell stage ';

% Where code saves images
dest_dir = 'L:\Image Data\Aslan\Summer 2018\Exosome Migration\Second Wound Healing\[ Aslan Analysis ]\Migration\';

% Amount of time that passed between each consequtive image being taken divided by 60.
% ex. if images were taken every 30 minutes, timelapse = 30/60 = 0.5.
timelapse = 0.5;

% [For statistics]
num_bootstrapping = 1e3;

% The name of the files that will be output
dest_file = '[intra stats] ';

% Total path name to "analyzed cell stage" files. This should not need to
% be edited.
file_name = [main_dir_analyzed_cell, cell_stage_filename];

% Saves all of the above data for the next code, intergroup_stats. This
% should not be edited!
save('needed_files.mat', 'file_name', 'condition_list', 'dest_dir', 'num_bootstrapping');

%% Stage master (edit this)
% Follows the same pattern as that described in BATCH_WHA. It may be
% easiest to copy and paste the stage master list from previous code.

stage_master{1} = [13 14 15 133 134 135]; %DMEM Only
stage_master{2} = [37 38 39 125 126 127]; %Exo free
stage_master{3} = [117 118 119]; %DMEM+
stage_master{4} = [93 94 95]; %ADSC
stage_master{5} = [77 78 79]; %EGF
stage_master{6} = [85 86 87]; %HUVEC
stage_master{7} = [101 102 103]; %FB 100%
stage_master{8} = [109 110 111]; %FB 50/50%

%% Time master (edit this)
% Set the time ranges that you would like intragroup and intergroup
% analysis to occur at. These should occur in order. For example, if you
% would like to analyze your data from frames 12-24 and 1-12, frames 1-12
% should appear on the list FIRST, then frames 12-24.

% Speed, directionality, and displacement plots will only be
% created for the last time_master in the list.

% Create your time_master list here:

time_master{1} = [1 24]; % Time range is in frames
time_master{2} = [24 48];
time_master{3} = [1 48]; % This time master would be the only time range to have plots saved to the dest_dir folder.

%% Analysis and Plot Creation (this does not need to be edited).

for i = 1:length(time_master)
    for ii = 1:length(condition_list)
        stage = stage_master{ii};
        frame_range = time_master{i};
        
        %Grabbing the recovery data and saving it for use in our plot.
        for iii = 1:length(stage)
            stage_label{iii} = ['stage ',int2str(stage(iii))];
        end
        
        frame_range = [time_master{i}(1) time_master{i}(2)];
        dest_filename = [dest_dir, dest_file, condition_list{ii}, ' ', time_master{i}(2), ' hr'];
        
        % This function will find the speed, displacement, and
        % directionality ratio of all the conditions at each time point.
        % These values will be saved in stats_var_tmpt, which will be
        % loaded into intergroup_stats for further analysis.
        stats_var_tmpt{i,ii} = intragroup_stats_ver2('file_name',file_name,'stage',stage,'frame_range',frame_range,...
            'num_frames',num_frames,'timelapse',timelapse,'num_bootstrapping',num_bootstrapping);
        lgd = legend(stage_label,'Location','north','Orientation','horizontal');
        
        % Saves the speed, MSD, and DR plots as "[intra stats] (insert
        % condition)" in both .eps and .pdf form.
        if time_master{i} == time_master{end}
        saveas(gcf,[dest_dir,'[intra stats] ',condition_list{ii},'.eps'],'epsc');
        saveas(gcf,[dest_dir ,'[intra stats] ',condition_list{ii},'.pdf'],'pdf');
        end
        close all
    end
end

% This is what saves all of the data we collected for each condition at
% each time point. This will be loaded into intergroup_stats for further
% analysis.
save('stats_var_tmpt.mat', 'stats_var_tmpt');
