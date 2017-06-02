function [cell] = migration_stats(varargin)

% example =================================================================
% [processed_cell] = motility_param_calc('cell',filtered_hPMN,'micperpix',1.31,'time_step',15);
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
%           micperpix           : calibration of microns per pixel
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

% in this step the necessary information is being added so the code can
% provide the correct outputs

% cell information, pixels per micron and frame speed (all explained
% above) are being inputed 

i=1;
while i <= length(varargin)
    switch lower(varargin{i})
        case 'cell'
            cell=varargin{i+1}; i=i+2;
        case 'micperpix'
            micperpix = varargin{i+1}; i=i+2;
        case 'time_step'
            time_step = varargin{i+1}; i=i+2;
        otherwise
            error('Unknown option: %s\n',varargin{i}); i=i+1;
    end
end

%this loop provides the code for all of the equations to find the different
%parameters of the cell migration 
for i = 1:length(cell)
    traj = cell(i).traj;
    % determine the persistence time and instantaneous speed in accordance
    % to the semipersistent random walk model
    len = length(traj); 
    msds{i} = msd_np(traj)*micperpix*micperpix;
    [p_leng, dists] = p_length(traj);
    p_leng = p_leng*micperpix;
    p_indg = p_ind(traj);
    tot_time = (len-1)*time_step;
    pguess = p_indg*tot_time;
    rmsguess = rmsspeed(traj,time_step)*micperpix;
    tau = [1:len-1]*time_step;
    sp_guess = [rmsguess, pguess];
    % Only use 1st 1/3 of calculated msds
    % Due to a loss in sample size for high step number, only the first third of
    % msds is used
    RMS_speed = rmsspeed(traj, time_step);
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
  
    % determine displacement (start-to-end distance)
    [displacement, disp_x, disp_y] = tot_disp(traj);
    displacement = displacement*micperpix;
    
    % determine cell directionality base on the displacement vector
    disp_x = disp_x*micperpix;
    disp_y = disp_y*micperpix;
    [step_angles, step_angle_change] = vect_angle(traj);
    [step_disp] = step_dists(traj);
    
    %adding all of the information to the structure 
    cell(i).average_speed = p_leng/tot_time;
    cell(i).pathlength = p_leng;
    cell(i).displacement = displacement;
    cell(i).num_frames_tracked = length(traj);
    cell(i).dir_ratio = p_indg;
    cell(i).step_angles = step_angles;
    cell(i).step_angle_Change = step_angle_change;
    cell(i).step_disp = step_disp.*micperpix;
    cell(i).PRW_fit_r2 = rsq; %PRW = persistent random walk model 
    cell(i).instantenous_speed = x(1);
    cell(i).persistence = x(2);
    cell(i).MSD = msds{i};
    cell(i).speed_persistence_Fit = sp_func(x,tau(1:len2));
    cell(i).RMS_speed = RMS_speed;
end