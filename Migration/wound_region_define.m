%% Defining the wound region of wound stages
% This code will allow you to trace over the first phase image of each
% wound region stage and define where the wound region is.

%% You will need to run ONLY this portion of the code first.
% This portion of the code is where you will trace the image and create the
% wound region.
filename = '/L:\Image Data\Chung\2018-07-02 cancer migration assay\cma_w1SiRDNA_s1_t1.TIF';
scratch_im = imread(filename); %reads the image above from the folder and saves it as scratch_im
[roi, selection] = region_select_multi('image',scratch_im,'plot_option',0);
figure; imshow(roi);

%% You will need to run ONLY this portion of the code second.
% This portion of the code will allow you to make corrections the the wound
% region, as there will be some gaps that need to be filled in from the
% manual tracing.

% new_roi = roi;
% new_roi(1:10,1:277) = 1;          % Top left corner of wound region.
% new_roi(1:10,725:end) = 1;        % Top right corner.
% new_roi(end-10:end,1:196) = 1;    % Bottom left corner.
% new_roi(end-10:end,743:end) = 1;  % Bottom right corner.
% new_roi(1:end,1:10) = 1;          % Left side of image (along cells).
% new_roi(1:end,end-10:end) = 1;    % Right side of image (along cells).
% figure; imshow(new_roi)           % (Shows the image)

