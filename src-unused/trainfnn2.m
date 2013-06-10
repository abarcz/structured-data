
function [fnn rmsErrors trainCorrectRates validationCorrectRates] = trainfnn2(fnn, samples, nEpochs, learningConstant)
% trains two-layer neural network
%
% usage: [fnn rmsErrors trainCorrectRates validationCorrectRates] = trainfnn2(fnn, samples, nEpochs, learningConstant)
%
% each 'samples' row = [class sample]

	tic();

	sampleSize = size(samples, 2) - 1;
	nClasses = size(unique(samples(:, 1)), 1);

	assert(fnn.nInputLines == sampleSize);

	nOutputNeurons = fnn.nOutputNeurons;
	assert(nClasses == nOutputNeurons);

	[trainSamples validationSamples] = splitset(samples, 0.5);
	trainLabels = trainSamples(:, 1);
	trainSamples = trainSamples(:, 2:end);

	nTrainSamples = size(trainSamples, 1);

	% prepare expected results matrix
	% we assume labels are 1..10
	expectedResults = zeros(nTrainSamples, nOutputNeurons);
	for i = 1:nTrainSamples
		label = trainLabels(i, 1);
		expectedResults(i, label) = 1;
	end

	rmsErrors = [];
	trainCorrectRates = [];
	validationCorrectRates = [];
	lConstants = [];
	validationCorrectRateDeterCount = 0;
	lastRmsError = 10;

	% 360 epochs == 1000s
	for i = 1:nEpochs
		permutedIndexes = randperm(nTrainSamples)';
		trainSamples = trainSamples(permutedIndexes, :);
		trainLabels = trainLabels(permutedIndexes, 1);
		expectedResults = expectedResults(permutedIndexes, :);
		rmsError = 0;
		errorCount = 0;
		for j = 1:nTrainSamples
			sample = trainSamples(j, :);
			expectedResult = expectedResults(j, :);

			outputs = applynet(fnn, sample);
			errors = 0.5 .* (expectedResult - outputs);
			deltas = backpropagate(fnn, sample, errors);
			fnn = updateweights(fnn, deltas, learningConstant);

			rmsError = rmsError + sum((expectedResult' - outputs') .^ 2);
			[maxValue predictedClass] = max(outputs');
			if predictedClass != trainLabels(j, 1)
				errorCount = errorCount + 1;
			end
		end
		rmsError = rmsError / nClasses / nTrainSamples;
		trainCorrectRate = (nTrainSamples - errorCount) ./ nTrainSamples * 100;
		
		% use validation set
		confusionMatrix = classifyfnn(fnn, validationSamples);
		validationCorrectRate = interpretconfusionmatrix(confusionMatrix)(1) * 100;

	%	if rmsError > lastRmsError
	%		learningConstant = learningConstant * 0.90;
	%	else
	%		learningConstant = learningConstant + 0.01;
	%	end
	%	lastRmsError = rmsError;

		rmsErrors = [rmsErrors; rmsError];
		trainCorrectRates = [trainCorrectRates; trainCorrectRate];
		validationCorrectRates = [validationCorrectRates; validationCorrectRate];

%		if size(validationCorrectRates, 1) > 1
%			if validationCorrectRate < validationCorrectRates(size(validationCorrectRates, 1) - 1, 1)
%				validationCorrectRateDeterCount = validationCorrectRateDeterCount + 1;
%			else
%				validationCorrectRateDeterCount = 0;
%			end
%		end

%		if validationCorrectRateDeterCount > 5
%			printf('Validation set correct rate deteriorated %d times in a row, stopping after epoch %d \n', validationCorrectRateDeterCount, i);
%			break;
%		end
	end

	disp(trainCorrectRate);
	disp(validationCorrectRate);
	disp(toc());
end
