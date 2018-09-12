function [cell] = motility_param_calc(varargin)

% example =================================================================
% [processed_cell] = motility_param_calc('cell',filtered_hPMN,'pixpermic',1/0.64,'time_step',0.25);
% =========================================================================

% =========================================================================
% FUNCTION DESCRIPTION: 'motility_parameters' calculates the parameters of
% average speed, instantaneous speed, persistence time, and mean square
% displacement base on the cell trajectories obtained from 'cell_tracking'.
% The average speed is calculated by dividing the total pathlength traveled
% by the cell by the total time of traveling.  The instantaneous speed and
% persistence time are calculated by regressing the mean squares
% displacement to the semi-persistent random walk model.  In essence, the
% persistence time represents on the average how long does it takes for a
% cell to change in direction.  The parameter r2 is the coefficient of
% determination (R2 value) obtained from the regression to the
% semi-persistent random walk model.  A r2 value of > 0.995 is
% recommended. 
%
% INPUTS: 
%           cell                : cell (with all the information stored in
%                                 the structure format)
%
%           pixpermic           : calibration of pixels per micron of
%                                 distance
%
%           time_step           : time duration between frames (in min)
%
% OUTPUTS:  
%           cell                : processed cell (with all the relevant
%                                 cell motility parameters stored in the
%                                 structure format.  These parameters
%                                 include: the average speed; pathlength,
%                                 displacement (disp), and the migratory
%                                 index (MI, which is the ratio of
%                                 displacement to pathlength and indicative
%                                 of directionality).  The number of frames
%                                 tracked is also included.
%                                 
% =========================================================================


% switch trap parses the varargin inputs
i=1;
while i <= length(varargin)
    switch lower(varargin{i})
        case 'cell'
            cell=varargin{i+1}; i=i+2;
        case 'pixpermic'
            pixpermic = varargin{i+1}; i=i+2;
        case 'time_step'
            time_step = varargin{i+1}; i=i+2;
        otherwise
            error('Unknown option: %s\n',varargin{i}); i=i+1;
    end
end

for i = 1:length(cell)
    traj = cell(i).traj;
    
    % determine the persistence time and instantaneous speed in accordance
    % to the persistent random walk (PRW) model
    len = length(traj); 
    msds{i} = msd_np(traj)/pixpermic/pixpermic;
    [p_leng, dists] = p_length(traj);
    p_leng = p_leng/pixpermic;
    p_indg = p_ind(traj);
    tot_time = (len-1)*time_step;
    pguess = p_indg*tot_time;
    rmsguess = rmsspeed(traj,time_step)/pixpermic;
    tau = [1:len-1]*time_step;
    sp_guess = [rmsguess, pguess];
    % Only use 1st 1/3 of calculated msds
    len2 = round(length(traj)/3);
    % The optimization for curfitting to the semipersistent random walk
    % model, defined by the eqn in the function "sp_func"
    options = optimset('lsqcurvefit');
    options = optimset(options, 'Display', 'off');
    options = optimset(options,'MaxFunEvals',1000); % increased 5x
    [x,resnorm,res,exitflag] = lsqcurvefit('sp_func',sp_guess,tau(1:len2),msds{i}(1:len2),[0,0],[],options);
    %     for checking the fit
    %     figure
    %     plot(tau(1:len2),msds{i}(1:len2),'b',tau(1:len2),sp_func(x,tau(1:len2)),'r');
    %     keyboard;
    rsq = GOF(msds{i}(1:len2),sp_func(x,tau(1:len2)));
    
    % determine max displacement (max distance between any two points in the cell trajectory)
    max_displacement = max_disp(traj)/pixpermic;
    
    % determine cell directionality base on the displacement vector
    [disp_angle, displacement] = cart2pol( traj(end,1)-traj(1,1), traj(1,2)-traj(end,2));
    disp_angle = disp_angle*180/pi;
    if disp_angle < 0
        disp_angle = disp_angle+360;
    end
    %disp_angle = start2end_vect_angle(traj);
    [step_angles, step_angle_change] = vect_angle(traj);
    [step_size] = step_dists(traj);
    
    % determine the directional/angle autocorrelation obtained from different time intervals
    % (see the work of Gorelik and Gautreau for more details)
    DA = dir_autocorr_gg('trajectory',traj,'plot_option',0);
    
    % determine the directionality ratio obtained from different time
    % intervals
    DR = DR_vs_time('trajectory',traj, 'plot_option',0);
    
    % store the motility parameters in a structure
    cell(i).num_frames_tracked = length(traj);          % number of frames over which the cell is tracked. (1 value)
    cell(i).avg_s = p_leng/tot_time;                    % average speed: total distance traveled/total duration of travel. (1 value)
    cell(i).rms_s = rmsguess;                           % root-mean-sqaured speed: average of step speed. (1 value, see detail below)
    cell(i).pathlength = p_leng;                        % total distance traveled. (1 value)
    cell(i).displacement = displacement;                % start-to-end distance of a given trajectyory. (1 value)
    cell(i).max_displacement = max_displacement;       % maximum distance between any two points along a trajectory. (1 value)
    cell(i).totDR = p_indg;                             % ratio of displacement to pathlength. (1 value, 1 = travel in a straight. the smaller the DR, the less persistent the cell)
    cell(i).disp_angle = disp_angle;                    % angle of the displacement. (1 value)
    cell(i).sp_fit_r2 = rsq;                            % r2 value of the PRW model fit. A minimal of 0.995 is recommended. (1 value)
    cell(i).inst_s = x(1);                              % instantaenous speed: obtained from the PRW model fit. ideally, should match the rms speed (this is generally true when the r2 is > 0.995). (1 value)
    cell(i).p = x(2);                                   % persistence time: obtained from the PRW model fit. ideally, describes the average duration between direcational change. (1 value)
    cell(i).sp_fit = sp_func(x,tau(1:len2));            % the best fit curve produced by the PRW model. (number of values ~ number of frames tracked/3)
    cell(i).step_s = step_size./pixpermic/time_step;    % step speed: distance covered by step, divided by the duration between consecutive frames. (number of values = number of frames tracked - 1)
    cell(i).MSD = msds{i};                              % mean squared displacement: average start-to-end distance covered by a cell at different time intervals. (number of values = number of frames tracked - 1)
    cell(i).step_angles = step_angles;                  % angle of each step. (number of values = number of frames tracked - 1)
    cell(i).step_angle_change = step_angle_change;      % change between consecutive step angle. (number of values = number of frames tracked - 2)
    cell(i).DA = DA;                                    % directional autocorrealtion: avereage autocorrelation between angles defined the displacement obtained from different time intervals. (number of values = number of frames tracked - 2).
    cell(i).DR = DR;                                    % directional ratio obtained from different time intervals. (number of values = number of frames tracked - 1).
end