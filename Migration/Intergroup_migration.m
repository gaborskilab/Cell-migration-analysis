%% Intergroup Analysis
% Creates a set of plots for speed, displacement, and directionality for each condition. 
% This allows you to compare each condition to each other.

% Clears all previous data and sets colors for graphs.
clear all
cmap_r = colormap('Autumn');
cmap_g = colormap('Summer');
cmap_b = colormap('Winter');
cmap_k = colormap('Bone');
close all
clc

% Loads in the needed files from the intragroup code.
load('stats_var_tmpt.mat')
load('needed_files.mat')

%% Edit here

% Time between consequtive images divided by 60. ex. if images were
% taken every 30 minutes, timelapse = 30/60 = 0.5.
timelapse = 0.5;

% List of conditions as strings
condition_list = {'DMEM', 'Exo Free', 'DMEM+', 'ADSC', 'EGF', 'HUVEC', 'FB100', 'FB50'};

%% Stage Master
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

%% Time Master
% Follows the same pattern as that described in the intragroup code. It may be
% easiest to copy and paste the time master list from previous code.

time_master{1} = [1 24]; % Time range is in frames
time_master{2} = [24 48];
time_master{3} = [1 48];

%% Plot Details (does not need to be edited)
% A section of code that sets plot details, such as the legend, for later
% use.

for i = 1:length(time_master) % Setting the legend.
    % Sets the time ranges that are used as labels in the legend. Creates
    % the label by reading the frames from time master, converting to
    % hours by multiplying by timelapse, and rounding to the nearest hour.
    if time_master{i}(1) == 1
        time1(i) = 0;
    else
        time1(i) = time_master{i}(1)*timelapse;
        time1(i) = round(time1(i));
    end
    time2(i) = time_master{i}(2)*timelapse;
    time2(i) = round(time2(i));
    % Determines what the legend will say. ex. "0-24 hours"
    legendinfo{i} = [int2str(time1(i)),'-',int2str(time2(i)),' hours'];
end
% x1 is used as the x-value for plots.
x1 = 1:1:length(condition_list);

%% Obtaining averages and errors of speed, displacement, and DR.

% doi = "data of interest." The data used in this code comes from the
% intragroup code under the variable "stats_var_tmpt."
doi = stats_var_tmpt;

% Automatically determines the number of time ranges and number of
% conditions.
[num_time_range,num_conditions] = size(doi);
for i = 1:num_time_range
    for j = 1:num_conditions
        % Saving all of the speed/displacement/directionality data from 
        % stats_var_tmpt under separate variables.
        data(i).speed = [doi{i,j}.speed];
        data(i).MSD = [doi{i,j}.MSD];
        data(i).DR = [doi{i,j}.DR];
        
        % Calculating the moi (mean of interest) and eoi (error of interest)
        % values for each data type.
        moi.speed = mean(data(i).speed);
        eoi.speed = std_err_m(data(i).speed);
        moi.displacement = median(data(i).MSD);
        CI = CI_median([data(i).MSD],num_bootstrapping);
        eoi.displacement = CI;
        moi.totDR = median(data(i).DR);
        CI = CI_median((data(i).DR),num_bootstrapping);
        eoi.totDR = CI;
        % Calculating the min and max error values for
        % displacement/directionality.
        e_diff_a = ([eoi.displacement(1,1)] - [moi.displacement]);
        e_diff_b = ([eoi.displacement(1,end)] - [moi.displacement]);
        e_dir_a = ([eoi.totDR(1,1)] - [moi.totDR]);
        e_dir_b = ([eoi.totDR(1,end)] - [moi.totDR]);
        
        % Saving averages as a new matrix (needed to be sorted
        % differently).
        a_sp(j,i) = moi.speed;
        a_disp(j,i) = moi.displacement;
        a_dir(j,i) = moi.totDR;
        
        % Saving errors as new matrix (needed to be sorted differently).
        e_sp(j,i) = eoi.speed;
        disp_err1(j,i) = e_diff_a;
        disp_err2(j,i) = e_diff_b;
        dir_err1(j,i) = e_dir_a;
        dir_err2(j,i) = e_dir_a;
    end
end

%% Speed Graph
figure('units','normalized','outerposition',[0 0 1 0.5])
% Allows all four graphs to be included in one figure.
subplot(1,3,1)
% Creates the bar plot for speed.
h1 = bar(x1, a_sp); hold on
ytxt = num2str(a_sp, '%.1f');
% Calculating the width for each bar group so errorbars are centered within
% each bar.i
groupwidth = min(0.8, length(time_master)/(length(time_master) + 1.5));
for i = 1:length(time_master)
    % Calculate center of each bar
    y = (1:length(condition_list)) - groupwidth/2 + (2*i-1) * groupwidth / (2*length(time_master));
    errorbar(y, a_sp(:,i), e_sp(:,i), 'k', 'linestyle', 'none');
    legend(legendinfo,'Autoupdate','off','Location','northoutside','Orientation','horizontal');
end
lg.Location = 'BestOutside';
lg.Orientation = 'Horizontal';
ylabel('speed (\mum/min)');
xtickangle(45);
xticklabels(condition_list);

%% Displacement Graph
subplot(1,3,2)
h2 = bar(x1, a_disp); hold on
for i = 1:length(time_master)
    %     Calculate center of each bar
    z = (1:length(condition_list)) - groupwidth/2 + (2*i-1) * groupwidth / (2*length(time_master));
    errorbar(z, a_disp(:,i), disp_err1(:,i), disp_err2(:,i), 'k.', 'linestyle', 'none');
    legend(legendinfo,'Autoupdate','off','Location','northoutside','Orientation','horizontal');
end
lg.Location = 'BestOutside';
lg.Orientation = 'Horizontal';
ylabel('mean squared displacement (\mum^2)');
xtickangle(45);
xticklabels(condition_list);

%% Directionality

subplot(1,3,3)
h= bar(x1, a_dir); hold on
n2groups = size(a_dir, 1);
n2bars = size(a_dir, 2);
for i = 1:n2bars
    % Calculate center of each bar
    z1 = (1:n2groups) - groupwidth/2 + (2*i-1) * groupwidth / (2*n2bars);
    errorbar(z1, a_dir(:,i), dir_err1(:,i), dir_err2(:,i), 'k.', 'linestyle', 'none');
    legend(legendinfo,'Autoupdate','off','Location','northoutside','Orientation','horizontal');
end
lg.Location = 'BestOutside';
lg.Orientation = 'Horizontal';
xtickangle(45);
xticklabels(condition_list);
ylabel('directionality (unitless)')

% Saves the intergroup stats plot as "[inter stats] plots" in both .eps and
% .pdf form.
saveas(gcf,[dest_dir ,'[inter stats] plots.pdf'],'pdf');
saveas(gcf,[dest_dir ,'[inter stats] plots.eps'],'eps');