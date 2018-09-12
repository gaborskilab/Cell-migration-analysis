function [data_DA] = dac(varargin)

% example =================================================================
% [data_DA] = dir_autocorr_gg('trajectory',test_traj,'plot_option',1);
% =========================================================================


% This function superimposes virus trajectories and their associated ID#
% onto a user-specifed image.  The ID#'s will be in red and located right
% at the starting positions of the trajectories.  This function is useful
% for keeping track the virus trajectories, especially useful when one need
% to manually remove the viruses to be excluded from the analysis.  When
% the excluded_virus is also specifed the exluded trajectories will also be
% superimposed on each frame in red color.
%
% INPUTS:
%           trajectory      : trajectyory = positions over time
%
%           plot_option     : option for plotting; 1 = plot, 0 = don't plot


% OUTPUTS:  data_DA         : analyzed data in the form of a struture
%
%                           : data_DA.step_angle = the angle of each step
%
%                           : data_DA.da = the directional autocorrelation
%                             coefficient of step angles of all sizes
%
%                           : data_DA.mda = the mean directional
%                             autocorrelation coefficient of step angles of
%                             all sizes

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
% close all
% clear all
% clc
% trajectory = [100,316;71,245;57,198;67,144;115,47];
% time_per_step = 1;
% plot_option = 1;

x = trajectory(:,1)';
y = trajectory(:,2)';
N = length(x)-1;

for n = 1:N-1
    for i = 1:N-n
        a = [(x(i)-x(i+1)) (y(i)-y(i+1))];
        b = [(x(i+n)-x(i+n+1)) (y(i+n)-y(i+n+1))];
        num = a*b'; % fast way of getting a(1)*b(1) + a(2)*b(2);
        den = sqrt(a(1)^2+a(2)^2)*sqrt(b(1)^2+b(2)^2);
        if den ~= 0
            temp(i) = num/den;
        else
            temp(i) = rand(1);
        end
    end
    data_DA(n).da = [temp];
    data_DA(n).mda = [mean(temp)];
    clear temp
end

if plot_option == 1
    figure;
    plot(trajectory(:,1),-1*trajectory(:,2),'o');
    hold on;
    plot(trajectory(:,1),-1*trajectory(:,2),'-');
    plot(trajectory(1,1),-1*trajectory(1,2),'*g');
    plot(trajectory(end,1),-1*trajectory(end,2),'*r');
    hold off;
    xlabel('x-coordinate');
    ylabel('y-coordinate');
    axis equal
    set(gcf,'color','w');
    
    figure; plot([1 [data_DA.mda]],'o');
    axis([1 length(trajectory) min([data_DA.mda]) 1]);
    xlabel('step size');
    ylabel('directional autocorrleation (unitless)');
end

