
function [net rmsErrors trainCorrectRates validationCorrectRates] = trainnet(net, samples, nEpochs, learningConstant)
% trains two-layer neural network
% returns: v - hidden layer weights, w - visible layer weights
% samples - row = sample (without class information)

	tic();

	% batch mode is dysfunctional and shouldn't be used before major corrections
	batch = false;
	disp('Changed mode to non-batch');

	sampleSize = size(samples, 2) - 1;
	nClasses = size(unique(samples(:, 1)), 1);

	inputWeights = net.inputWeights;
	intraWeights = net.intraWeights;
	activation = net.activation;
	activationderivative = net.activationderivative;

	nInputsToHiddenNeuron = size(inputWeights, 1);
	nHiddenNeurons = size(inputWeights, 2);
	assert(nInputsToHiddenNeuron == sampleSize + 1);

	nInputsToVisibleNeuron = size(intraWeights, 1);
	nVisibleNeurons = size(intraWeights, 2);
	assert(nInputsToVisibleNeuron == nHiddenNeurons + 1);
	assert(nClasses == nVisibleNeurons);

	[trainSamples validationSamples] = splitset(samples, 0.5);
	trainLabels = trainSamples(:, 1);
	trainSamples = trainSamples(:, 2:end);

	nTrainSamples = size(trainSamples, 1);
	trainSamples = addbias(trainSamples);

	% prepare expected results matrix
	% we assume labels are 1..10
	expectedResults = zeros(nTrainSamples, nVisibleNeurons);
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

	v = inputWeights;
	w = intraWeights;

	% 360 epochs == 1000s
	trainCorrectRateLog = fopen('trainCorrectRateLog.txt', 'w');
	validationCorrectRateLog = fopen('validationCorrectRateLog.txt', 'w');
	rmsLog = fopen('rmsLog.txt', 'w');
	for i = 1:nEpochs
		if batch
			% hidden layer feed
			netv = trainSamples * v;
			zv = addbias(activation(netv));

			% visible layer feed
			netw = zv * w;
			zw = activation(netw);

			% calculate delta_zw (for all samples and for all visible neurons at once)
			delta_zw = 0.5 * (expectedResults - zw) .* activationderivative(zw);
			delta_W = zv' * (learningConstant * delta_zw);

			% calculate delta_zv (for all samples and for all hidden neurons at once)
			delta_zv = 0.5 * activationderivative(zv) .* (delta_zw * w');
			delta_V = trainSamples' * (learningConstant * delta_zv);

			% add deltas to weights of neuron layers
			w = w + delta_W;
			v = v + delta_V(:, 1:end-1);

			rmsError = sum(sum((expectedResults - zw) .^ 2)) / nTrainSamples / nClasses;

			% calculate correct rate
			[maxValues predictedClasses] = max(zw');
			predictedClasses = predictedClasses';
			errorCount = sum(sum(predictedClasses != trainLabels));
			trainCorrectRate = (nTrainSamples - errorCount) ./ nTrainSamples * 100;

		else
			permutedIndexes = randperm(nTrainSamples)';
			trainSamples = trainSamples(permutedIndexes, :);
			trainLabels = trainLabels(permutedIndexes, 1);
			expectedResults = expectedResults(permutedIndexes, :);
			rmsError = 0;
			errorCount = 0;
			for j = 1:nTrainSamples
				sample = trainSamples(j, :);
				expectedResult = expectedResults(j, :);

				% hidden layer feed
				netv = sample * v;
				zv = addbias(activation(netv));

				% visible layer feed
				netw = zv * w;
				zw = activation(netw);

				% calculate delta_zw (for all visible neurons at once)
				delta_zw = 0.5 * (expectedResult - zw) .* activationderivative(zw);
				delta_W = zv' * (learningConstant * delta_zw);
				

				% calculate delta_zv (for all hidden neurons at once)
				delta_zv = 0.5 * activationderivative(zv) .* (delta_zw * w');
				delta_V = sample' * (learningConstant * delta_zv);

				w = w + delta_W;
				v = v + delta_V(:, 1:end-1);

				rmsError = rmsError + sum((expectedResult - zw) .^ 2);
				[maxValue predictedClass] = max(zw);
				if predictedClass != trainLabels(j, 1)
					errorCount = errorCount + 1;
				end
			end
			rmsError = rmsError / nClasses / nTrainSamples;
			trainCorrectRate = (nTrainSamples - errorCount) ./ nTrainSamples * 100;
		end
		
		% use validation set
		net.inputWeights = v;
		net.intraWeights = w;
		confusionMatrix = classify(net, validationSamples);
		validationCorrectRate = interpretconfusionmatrix(confusionMatrix)(1) * 100;

		fprintf(trainCorrectRateLog, '%d\n', trainCorrectRate);
		fprintf(validationCorrectRateLog, '%d\n', validationCorrectRate);
		fprintf(rmsLog, '%f\n', rmsError);
		%printf('E: %f CR: %d%% lc:%f\n', rmsError, trainCorrectRate, learningConstant);

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
	fclose(trainCorrectRateLog);
	fclose(validationCorrectRateLog);
	fclose(rmsLog);

	disp(trainCorrectRate);
	disp(validationCorrectRate);
	disp(toc());
end
