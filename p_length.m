function [leng, dists] = p_length(trajectory)% Calculates path length of trajectory% Trajectory should be a n by 2 matrix with x values in the first column% if size(trajectory,2) ~= 2% 	disp('The trajectory must have data in columns!')% 	return% end% The shift function will cause the X and Y values to be moved over by one% so that the difference can be calculated without the use of an "if" of% "for" loop% Creates a variable that represents the data from the matrix with the% coordinates % x is the coordinates from the first row % y is the coordinates from the second rowx = trajectory(:,1);y = trajectory(:,2);% this shifts x and y over by 1sh_x = shift(x,2);sh_y = shift(y,2);x(end) = [];y(end) = [];sh_x(end)=[];sh_y(end) =[];% x_diff and y_diff find the difference between each of the x and y values% in the vector created above x_diff = x - sh_x;y_diff = y - sh_y;% x2 and y2 then squares each of the x_diff and y_diffx2 = x_diff.^2;y2 = y_diff.^2;% dists is a variable that stores all of the distances between the% coordinate couple (x,y) it uses the squared differences (x2, y2) as well% as the distance equation ( distance = sqrt((x2-x1)^2+(y2-y1)^2)) )dists = sqrt(x2+y2);% length finds the overal pathlength of the cell's trajectory by adding all% of the individual distances (dists) into one variable (leng) leng = sum(dists);return