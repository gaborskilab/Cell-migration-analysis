function CI = CI_median(data, num_resampling)

n = length(data);
if n == 1
    CI = [data data];
    disp('only one data point, so there is no CI');
else
    for i = 1:num_resampling
        pos = ceil((n-1)*rand(n,1));
        resample = data(pos);
        m(i) =median(resample);
    end
    CI = prctile(m,[5,95]);
end