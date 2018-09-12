function [angles, angle_change] = vect_angle(traj)

x_comp = shift(traj(:,1),2)-traj(:,1);
y_comp = traj(:,2) - shift(traj(:,2),2);
x_comp(1) = [];
y_comp(1) = [];
[theta,rho] = cart2pol(x_comp,y_comp);
step_angle = theta*180/pi;
step_angle(step_angle<0) = step_angle(step_angle<0)+360;
angles = step_angle;

original = angles;
shifted = shift(original, 5);
angle_change = original - shifted;
angle_change = abs(angle_change);
for i = 1:length(angle_change)
    if angle_change(i) > 180
        angle_change(i) = 360 - angle_change(i);
    end
end
angle_change(1) = [];
