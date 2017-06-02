function shifted_matrix = shift(matrix, direction)% This function takes a matrix and shifts it in one of 6 directions,% truncating pieces which fall off the edge, and filling in zeros where% things come in off the edge%  The directions are:         1 2 %							   6 7 3%							     5 4[m,n] = size(matrix);    em = zeros(m+2,n+2);em(2:end-1,2:end-1)= matrix;% em is now an expanded version of matrix ringed with zerosswitch directioncase 1	% Shift in 1 direction	shifted_matrix = em(3:end,3:end);case 2 	shifted_matrix = em(3:end,2:end-1);case 3	shifted_matrix = em(2:end-1,1:end-2);case 4	shifted_matrix = em(1:end-2,1:end-2);case 5	shifted_matrix = em(1:end-2,2:end-1);case 6 	shifted_matrix = em(2:end-1,3:end);case 7	shifted_matrix = em(2:end-1,2:end-1);otherwise	disp('ERROR, the direction given is inapproriate');	keyboardendreturn