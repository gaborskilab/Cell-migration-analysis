function [max_disp] = max_disp(trajectory)
% This function will calculate the maximum displacement of a trajectory.
%

steps = length(trajectory)-1;

x = trajectory(:,1)';
y = trajectory(:,2)';

% The loop below cycles through all the possible time increments, and constructs
% a matrix which contains all the x differences in the upper triangular portion
% of the matrix (not including the main diagonal), and does the same thing for 
% the y differences.  

xd_matr = zeros(steps+1);
yd_matr = zeros(steps+1);
sh_x = x;
sh_y = y;

 for incr = 1:steps
 	sh_x = shift(sh_x,3);
 	xd_matr(incr,:) = sh_x - x;
 	sh_y = shift(sh_y,3);
 	yd_matr(incr,:) = sh_y - y;
 end

 
 disp_matr = sqrt(xd_matr.^2+yd_matr.^2);
 disp_matr = triu(disp_matr);
 for k = 1:steps
     disp_matr(k,k) = 0;
 end

max_disp = max(max(disp_matr));