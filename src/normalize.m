
function [normalized means stds] = normalize(samples, means, stds)
% normalizes data (assures 0-mean, unit variance) for samples
%
% usage: [normalized means stds] = normalize(samples, means, stds)
%
% samples : row = sample, column = feature

	if nargin == 3
		assert(size(means, 2) == size(samples, 2));
		assert(size(means, 1) == 1);
		assert(size(stds, 2) == size(samples, 2));
		assert(size(stds, 1) == 1);
		nSamples = size(samples, 1);
		zeroMeanSamples = samples - repmat(means, nSamples, 1);
		normalized = zeroMeanSamples ./ repmat(stds, nSamples, 1);
	else if nargin == 1
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
	else
		error(sprintf('Wrong number of params for normalize(): %d', nargin));
	end
end
