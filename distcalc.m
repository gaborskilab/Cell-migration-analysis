function [traj, spm] = distcalc(frames,maxdistpix)% This function constructs the trajectories and the starting point matrix (spm) given% centroids for each frame% Initializing stufftraj= cell(1,1);lpet= [-1 -1];nextnewtraj = 1;% BIG loopfor k = 1:(length(frames)-1)	disp('frame')	disp(k)	    clear fr1 fr2 nc1 nc2 fr1x fr1y fr2x fr2y            % plant a dummy object if there are less than 2 objects found on the    % image... this solve the index out of bound problem...        fr1 = frames{k};    fr2 = frames{k+1};        [m n] = size(fr1);    [p q] = size(fr2);        if m < 2 || p <2        fr1(1, end+1) = 1;        fr1(2, end+1) = 1;        fr2(1, end+1) = 2;        fr2(2, end+1) = 1;    end    	fr1x = fr1(:,1);	fr1y = fr1(:,2);			fr2x = fr2(:,1);	fr2y = fr2(:,2);        	% next I need to construct the pairwise distance matrix		nc1 = length(fr1x); %320 in first frame 	nc2 = length(fr2x); %359 in second frame		x1 = repmat(fr1x,1,nc2);	x2 = repmat(fr2x',nc1,1);	y1 = repmat(fr1y,1,nc2);	y2 = repmat(fr2y',nc1,1);		dist = sqrt((x1-x2).^2 + (y1-y2).^2);		[val_rt,ind_rt] = min(dist,[],2);	[val_bot,ind_bot] = min(dist,[],1);		ind_bot;	ind_rt;	ind_bot(ind_rt);	    vect_rt = ind_bot(ind_rt) - (1:length(ind_rt));		% vect has zeros where there are matches and non-zero where there is no match	% next those that match need to be verified as not being too far away from each other		paired_rt = find(vect_rt==0);	%paired_bot = find(vect_bot==0);		dist_paired_rt = val_rt(paired_rt);	%dist_paired_bot = val_bot(paired_bot);		toofar = find(dist_paired_rt > maxdistpix);	paired_rt(toofar) = [];%this drops points which are too far apart from the list of                              %paired points		dist_paired_rt = val_rt(paired_rt);						 	%maybetoofar = find((dist_paired_rt > 5) & (dist_paired_rt < 10))		% [bigval,indmax] = max(dist_paired_rt);	% 	% orig_ind1 = paired_rt(indmax)  % this line finds the original index in frame one of 	%                               % the cell which moved the farthest distance	% %How do I find the original index in frame 2?                             	% orig_ind2 = ind_rt(orig_ind1)			% Next set up cell array to hold trajectories and a temp matrix to hold the 	% previous final points of trajectories (for matching)		% Also need to check that distances are not too great (like 11)	%traj = cell(1,10);		%lpet = [-1 -1];  % last point in existing trajectories		%nextnewtraj = 1;		%need actual points		%frame 1 points are	fr1p = [fr1x(paired_rt) fr1y(paired_rt)];		%frame 2 points are	fr2p = [fr2x(ind_rt(paired_rt)) fr2y(ind_rt(paired_rt))];		%Compare frame 1 points with final points of existing trajectories	[sharedvals, indtraj, indfr1] = intersect(lpet,fr1p,'rows');		%mtf_ind = intersect(maybetoofar,indfr1);		%This identifies continuing trajectories	%The row index in lpet must correspond to the cell index of that trajectory	%in traj	%Those trajectories not continuing must be marked as ended (-1 -1) in lpet	for i = 1:length(indtraj)        traj{indtraj(i)}(end+1,:) = fr2p(indfr1(i),:);        lpet(indtraj(i),:) = fr2p(indfr1(i),:);	end		% Existing trajectories have now been extended. Next new ones must be created and 	% ended ones must be marked as such		% First, ending ones	% ending trajectories are those which were there in the last round but found no	% pair in the new frame.  	lpet_copy = lpet;	lpet_copy(indtraj,:) = -1;	endedind = find(lpet_copy ~= -1);	lpet(endedind) = -1;		%Check the above		% New Trajectories	fr1p(indfr1,:) = []; % This eliminates continued trajectory points	fr2p(indfr1,:) = []; % Same for fr2p		numnewtrajs = size(fr1p,1);	traj{nextnewtraj+numnewtrajs-1} = []; %this is a mild form of preallocation		for i = 1:numnewtrajs        traj{nextnewtraj} = [fr1p(i,:); fr2p(i,:)];        lpet(nextnewtraj,:) = fr2p(i,:);		spm(nextnewtraj,:) = [fr1p(i,:) k]; %this records trajectory starting coords 											%and the frame in which it starts        nextnewtraj = nextnewtraj+1;	end		% Now I just need a loop...	enddisp('number of trajectories is')size(spm,1)return