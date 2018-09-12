function [step_size] = step_dists(traj)

traj_len = length(traj);
x = traj(2:traj_len,1) - traj(1:traj_len-1,1);
y = traj(2:traj_len,2) - traj(1:traj_len-1,2);
step_size = sqrt(x.^2+y.^2);