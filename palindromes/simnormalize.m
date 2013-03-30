
function [norm1 norm2] = simnormalize(samples1, samples2)
% normalizes data (assures 0-mean, unit variance) for samples1
% uses the same tranformation for samples2
% samples : row = sample, column = feature

	nSamples1 = size(samples1, 1);

	means = mean(samples1, 1);
	zeroMeanSamples1 = samples1 - repmat(means, nSamples1, 1);

	stds = std(zeroMeanSamples1, 0, 1);
	for i = 1:size(stds, 2)
		if stds(1, i) == 0
			stds(1, i) = 1;
		end
	end
	norm1 = zeroMeanSamples1 ./ repmat(stds, nSamples1, 1);

	nSamples2 = size(samples2, 1);
	zeroMeanSamples2 = samples2 - repmat(means, nSamples2, 1);
	norm2 = zeroMeanSamples2 ./ repmat(stds, nSamples2, 1);
end
