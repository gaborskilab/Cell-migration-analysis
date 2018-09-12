function [group_stats group_evolution] = intragroup_stats(varargin)
% switch trap parses the varargin inputs
i=1;
while i <= length(varargin)
    switch lower(varargin{i})
        case 'file_name'
            file_name = varargin{i+1}; i=i+2;
        case 'stage'
            stage = varargin{i+1}; i=i+2;
        case 'frame_range'
            frame_range = varargin{i+1}; i=i+2;
        case 'num_frames'
            num_frames = varargin{i+1}; i=i+2;
        case 'timelapse'
            timelapse = varargin{i+1}; i=i+2;
        case 'num_bootstrapping'
            num_bootstrapping = varargin{i+1}; i=i+2;
        otherwise
            error('Unknown option: %s\n',varargin{i}); i=i+1;
    end
end


stats_s = [];
stats_s_cat = [];
stats_disp = [];
stats_disp_cat = [];
stats_DR = [];
stats_DR_cat = [];
num_bootstrapping = 1000;
for i = 1:length(stage)
    % create a structure to group the same experiment type together
    doi = load([file_name,int2str(stage(i)),'.mat']);
%     doi = doi.healer_cell;
    doi = doi.analyzed_cell;
    % The number of cells that were detected.
    n(i) = length(doi);
    
    % ============================= speed ==================================
    [ensemble, m_v_t, se_v_t] = evolution_speed('frame_thresh',0,'cell',doi,'num_frames',num_frames,'frame_range',frame_range);
    s_v_t(i,:) = m_v_t;
    wanted = [];
    iii = 1;
    [num_cells num_time_pts] = size(ensemble);
    for ii = 1:num_cells
        if length(find(ensemble(ii,frame_range(1):frame_range(2)) == -1)) ~= frame_range(2)-frame_range(1)+1
            wanted(iii) = mean(ensemble(ii,find(ensemble(ii,:) ~= -1)));
            iii = iii + 1;
        end
    end
    moi(i).speed= mean(wanted);
    eoi(i).speed= std_err_m(wanted);
    stats_s = [stats_s wanted];
    temp_cat = i.*ones(1, length(wanted));
    stats_s_cat = [stats_s_cat temp_cat];
    
    
    % ============================= msd ==================================
    
    [ensemble, m_v_t, se_v_t] = evolution_msd('frame_thresh',0,'cell',doi,'num_frames',num_frames,'frame_range',frame_range);
    msd_v_t(i,:) = m_v_t;
    ii = 1;
    %    [num_cells num_time_pts] = size(ensemble);
    wanted = [];
    iii = 1;
    for ii = 1:num_cells
        if length(find(ensemble(ii,frame_range(1):frame_range(2)) == -1)) ~= frame_range(2)-frame_range(1)+1
            pos = max(find(ensemble(ii,frame_range(1):frame_range(2)) ~= -1))+frame_range(1)-1;
            wanted(iii) = ensemble(ii,pos);
            iii = iii + 1;
        end
    end
    moi(i).MSD = median(wanted);
    CI = CI_median(wanted,num_bootstrapping);
    eoi(i).MSD_low = CI(1);
    eoi(i).MSD_high = CI(2);
    stats_MSD = [stats_disp wanted];
    temp_cat = i.*ones(1, length(wanted));
    stats_MSD_cat = [stats_disp_cat temp_cat];
    
    % ============================= DR ==================================
    [ensemble, m_v_t, se_v_t] = evolution_DR('frame_thresh',0,'cell',doi,'num_frames',num_frames,'frame_range',frame_range);
    DR_v_t(i,:) = m_v_t;
    wanted = [];
    iii = 1;
    %    [num_cells num_time_pts] = size(ensemble);
    for ii = 1:num_cells
        if length(find(ensemble(ii,frame_range(1):frame_range(2)) == -1)) ~= frame_range(2)-frame_range(1)+1
            pos = max(find(ensemble(ii,frame_range(1):frame_range(2)) ~= -1))+frame_range(1)-1;
            wanted(iii) = ensemble(ii,pos);
            iii = iii + 1;
        end
    end
    moi(i).DR = median(wanted);
    CI = CI_median(wanted,num_bootstrapping);
    eoi(i).DR_low = CI(1);
    eoi(i).DR_high = CI(2);
    stats_DR = [stats_DR wanted];
    temp_cat = i.*ones(1, length(wanted));
    stats_DR_cat = [stats_DR_cat temp_cat];
end

[p_s,a,s] = anova1(stats_s, stats_s_cat,'off');
% [c_s,m,h,nms] = multcompare(s,'alpha',0.05,'ctype','tukey-kramer','displayopt','off');
% a = c_s(find(c_s(:,6)<0.05),1);
% b = c_s(find(c_s(:,6)<0.05),2);
% s_outliers = unique([a' b']);
%
[p_disp,a,s] = anova1(stats_MSD, stats_MSD_cat,'off');
% [c_disp,m,h,nms] = multcompare(s,'alpha',0.05,'ctype','dunn-siDRk','displayopt','off');
% a = c_disp(find(c_disp(:,6)<0.05),1);
% b = c_disp(find(c_disp(:,6)<0.05),2);
% disp_outliers = unique([a' b']);
%
[p_DR,a,s] = anova1(stats_DR, stats_DR_cat,'off');
% [c_DR,m,h,nms] = multcompare(s,'alpha',0.05,'ctype','dunn-siDRk','displayopt','off');
% a = c_DR(find(c_DR(:,6)<0.05),1);
% b = c_DR(find(c_DR(:,6)<0.05),2);
% DR_outliers = unique([a' b']);



figure('units','normalized','outerposition',[0 0 1 1])
subplot(2,3,1)
for i = 1:length(stage)
    bar(i, [moi(i).speed]); hold on
    xticks(1:length(stage))
    xlab{i} = ['stage ',int2str(stage(i))];
end
xticklabels(xlab)
xtickangle(45);
errorbar(1:length(stage), [moi.speed],[eoi.speed],'k.')
ylabel('speed (\mum/min)');
if p_s > 0.05
    title('no differences seen between samples');
end
% else
%     title({'differences seen between samples:',int2str(s_outliers)});
% end

subplot(2,3,2)
hold on
% This gives you different colors for each bar
for i = 1:length(stage)
    bar(i, moi(i).MSD);
    xticks(1:length(stage))
    xlab{i} = ['stage ',int2str(stage(i))];
end
xticklabels(xlab)
xtickangle(45);
errorbar(1:length(stage),[moi.MSD],[eoi.MSD_low]-[moi.MSD],[eoi.MSD_high]-[moi.MSD],'k.')
ylabel('mean squared displacement (\mum^2)');
if p_disp > 0.05
    title('no differences seen between samples');
end
% else
%     title({'differences seen between samples:',int2str(disp_outliers)});
% end

subplot(2,3,3)
for i = 1:length(stage)
    bar(i, [moi(i).DR]); hold on
    xticks(1:length(stage))
    xlab{i} = ['stage ',int2str(stage(i))];
end
xticklabels(xlab)
xtickangle(45);
errorbar(1:length(stage),[moi.DR],[eoi.DR_low]-[moi.DR],[eoi.DR_high]-[moi.DR],'k.')
ylabel('directionality ratio (unitless)');
if p_DR > 0.05
    title('no differences seen between samples');
end
% else
%     title({'differences seen between samples:',int2str(DR_outliers)});
% end

subplot(2,3,4)
hold on
for i = 1:length(stage)
    plot(timelapse*[frame_range(1):frame_range(2)-1], s_v_t(i,1:frame_range(2)-frame_range(1)));
end
xlabel('time (hr)')
ylabel('speed (\mum/min)');

subplot(2,3,5)
hold on
for i = 1:length(stage)
    plot(timelapse*[frame_range(1):frame_range(2)-1], msd_v_t(i,1:frame_range(2)-frame_range(1)));
end
xlabel('time (hr)')
ylabel('mean squared displacement (\mum^2)');

subplot(2,3,6)
hold on
for i = 1:length(stage)
    plot(timelapse*[frame_range(1):frame_range(2)-1], DR_v_t(i,1:frame_range(2)-frame_range(1)));
end
xlabel('time (hr)')
ylabel('directional ratio (unitless)');


group_stats = moi;
group_evolution.speed = mean(s_v_t);
group_evolution.msd = mean(msd_v_t);
group_evolution.DR = mean(DR_v_t);


