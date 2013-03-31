
function [trainingSet testSet] = splitset(samples, fraction)
% given a set of samples (row = sample), splits it with respect to classes
% fraction : fraction of each class to be retained in trainingSet

	% separate samples into classes
	classes = sepclasses(samples);
	nClasses = size(classes, 1);

	trainingSet = [];
	testSet = [];
	for i = 1:nClasses
		classSamples = classes{i, 1};
		nSamples = size(classSamples, 1);

		% randomly choose indexes to be retained
		indexes = randperm(nSamples);
		nRetainedSamples = ceil(nSamples .* fraction);

		indexesA = indexes(1, 1:nRetainedSamples);
		indexesB = indexes(1, (nRetainedSamples + 1):size(indexes, 2));

		% add retained samples to result
		trainingSet = [trainingSet; classSamples(indexesA, :)];
		testSet = [testSet; classSamples(indexesB, :)];
	end

	% apply permutation to mix classes
	trainingSet = permuteset(trainingSet);
	testSet = permuteset(testSet);
end

function permutedSet = permuteset(dataset)
	nSamples = size(dataset, 1);
	permutedSet = dataset(randperm(nSamples), :);
end
