
function [normalized means stds] = normalize(samples)
% normalizes data (assures 0-mean, unit variance) for samples
%
% usage: [normalized means stds] = normalize(samples)
%
% samples : row = sample, column = feature

	nSamples = size(samples, 1);

	means = mean(samples, 1);
	zeroMeanSamples = samples - repmat(means, nSamples, 1);

	stds = std(zeroMeanSamples, 0, 1);
	for i = 1:size(stds, 2)
		if stds(1, i) == 0
			stds(1, i) = 1;
		end
	end
	normalized = zeroMeanSamples ./ repmat(stds, nSamples, 1);
end
