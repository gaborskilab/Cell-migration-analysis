function [msds,s,p,r2,flags] = msd_sp(trajectories,timestep,pixpermic)
% Should calculate msd, s, p, and r-squared from trajectories (a cell array of trajectories).

warning('off')

if ~exist('timestep')
    % timestep = 5;
    timestep = 12.97/100;    
end
if ~exist('pixpermic')
    %pixpermic = 0.226; %appropriate for 4x decoupled pictures
    pixpermic = 1; % for simulations, units are already microns
end

for i = 1:length(trajectories)
    %if mod(i,25)~=0
       % fprintf('%d ',i);
   % else
       % fprintf('\n%d ',i);
   % end
    traj = trajectories{i};
    len = length(traj);
    msds{i} = msd_np(trajectories{i})/pixpermic/pixpermic;
     p_indg = p_ind(traj);
    tot_time = (len-1)*timestep;
    pguess = p_indg*tot_time;
     rmsguess = rmsspeed(traj,timestep)/pixpermic;
    tau = [1:len-1]*timestep;
    sp_guess = [rmsguess, pguess];    
%    sp_guess = [.9, 9.5];
    % Only use 1/3 of calculated msds
    len2 = round(length(msds{i})/3);
        
    % The optimization
    options = optimset('lsqcurvefit');
    options = optimset(options, 'Display', 'off');
    options = optimset(options,'MaxFunEvals',1000); % increased 5x
    [x,resnorm,res,exitflag] = lsqcurvefit('sp_func',sp_guess,tau(1:len2),msds{i}(1:len2),[0,0],[],options);
%     for checking the fit
%     figure
%     plot(tau(1:len2),msds{i}(1:len2),'b',tau(1:len2),sp_func(x,tau(1:len2)),'r');
%     keyboard;
    rsq = GOF(msds{i}(1:len2),sp_func(x,tau(1:len2)));
    r2(i) = rsq;
    s(i) = x(1);
    p(i) = x(2);
    flags(i) = exitflag;
    
end