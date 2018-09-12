function [rec_disp_thresh, rec_bw_thresh] = im_inten_distr(varargin)
% example: [rec_disp_thresh, rec_grey_thresh] = im_sig_prct('image',im,'dynamic_range_max,16000,''percentile_range',[1 99]);

% switch trap parses the varargin inputs
i=1;
while i <= length(varargin)
    switch lower(varargin{i})
        case 'plot_option'
            plot_option = varargin{i+1}; i=i+2;
        case 'image'
            im = varargin{i+1}; i=i+2;
        case 'dynamic_range_max'
            dynamic_range_max = varargin{i+1}; i=i+2;
        case 'percentile_range'
            prct_range = varargin{i+1}; i=i+2;
        otherwise
            error('Unknown option: %s\n',varargin{i}); i=i+1;
    end
end

cmap_r = colormap('Autumn');
cmap_g = colormap('Summer');
close gcf

% obtain intensity distribution from the image
[n_rows, n_cols] = size(im);
lin_im = double(reshape(im, [n_rows*n_cols,1]));

% create a histogram of the intensity distribution
bincounts = histc(lin_im,[1:round(dynamic_range_max/200):dynamic_range_max]);

% filter the distribution via moving average
num_occur = bincounts;
windowSize = 5;
b = (1/windowSize)*ones(1,windowSize);
a = 1;
smoothed = filter(b,a,num_occur);


% derivative of intensity distribution
d = smoothed(2:end)-smoothed(1:end-1);
windowSize = 5;
b = (1/windowSize)*ones(1,windowSize);
a = 1;
d_smoothed = filter(b,a,d);
rec_bw_thresh = find(d_smoothed == max(d_smoothed))*round(dynamic_range_max/200);

if plot_option == 1
    figure
    hold on;
    plot([1:length(smoothed)]*round(dynamic_range_max/200),smoothed,'color',cmap_r(35,:,:))
    plot([1:length(d_smoothed)]*round(dynamic_range_max/200), d_smoothed,'color',cmap_g(25,:,:))
    plot(rec_bw_thresh, max(d_smoothed),'v','MarkerEdgeColor',cmap_r(25,:,:),'MarkerFaceColor',cmap_r(25,:,:))
end
rec_disp_thresh = [prctile(lin_im, prct_range(1)) prctile(lin_im, prct_range(2))];