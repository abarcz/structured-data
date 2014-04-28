
function [trainedFnn mse q nSaturated z] = sbllm(fnn, inputs, outputs, nIterations, z0, useInputBias=true)
% Train FNN using SBLLM method - internal function used by trainsbllm
%
% usage: [trainedFnn mse q nSaturated z] = sbllm(fnn, inputs, outputs, nIterations, z0, useInputBias=true)
%
% inputs - each row is a single sample (normalized)
% outputs - each row contains output for a single sample (normalized)
% z0 - initial values of z (can be initialized by trainsbllm)

	if strcmp(fnn.outputFun, 'logsig') == 1
		activation2inv = @(x) reallogit(x);
	elseif strcmp(fnn.outputFun, 'tansig') == 1
		activation2inv = @(x) realatanh(x);
	elseif strcmp(fnn.outputFun, 'purelin') == 1
		activation2inv = @(x) x;
	else
		error(sprintf('Unknown output activation function: %s', fnn.outputFun));
	end

	if strcmp(fnn.hiddenFun, 'logsig') == 1
		activation1inv = @(x) reallogit(x);
		activation1invd = @(x) 1 ./ (x .* (1 - x));
	elseif strcmp(fnn.hiddenFun, 'tansig') == 1
		activation1inv = @(x) realatanh(x);
		activation1invd = @(x) 1 ./ (1 - x .^ 2);
	elseif strcmp(fnn.hiddenFun, 'purelin') == 1
		activation1inv = @(x) x;
		activation1invd = @(x) 1;
	else
		error(sprintf('Unknown hidden activation function: %s', fnn.hiddenFun));
	end

	% Step0: initialize
	outputs = outputs';
	prevQ = Inf;
	prevMse = Inf;
	prev2Q = Inf;
	prev2Mse = Inf;
	minQChange = 1e-1;
	minMseChange = 1e-14;
	stepSize = 1;
	nSamples = size(inputs, 1);
	aOutputs = activation2inv(outputs);
	% unpack fnn and add bias
	if useInputBias == true
		inputsWithBias = [inputs'; repmat(1, 1, nSamples)];
		weights1 = [fnn.weights1, fnn.bias1];
	else
		inputsWithBias = inputs';
		weights1 = fnn.weights1;
	end
	weights2 = [fnn.weights2, fnn.bias2];

	mse = zeros(nIterations, 1);
	q = zeros(nIterations, 1);
	nSaturated = zeros(nIterations, 1);
	z = z0;
	prevZ = z;
	for i = 1:nIterations
		% Step1: calculate weights and biases

		% calculate hidden layer weights

		% multiplying by inputsWithBias'
		% (as in the original article):
		% - can result in singular matrix and yield worse results
		% - can be minimally faster
		%A1 = (inputsWithBias * inputsWithBias');
		%b1 = (net1 * inputsWithBias');
		%weights1 = b1 / A1;
		az = activation1inv(z);
		weights1 = az / inputsWithBias;

		% calculate output layer weights
		zWithBias = [z; repmat(1, 1, nSamples)];
		%A2 = (zWithBias * zWithBias');
		%b2 = (aOutputs * zWithBias');
		%weights2 = b2 / A2;
		weights2 = aOutputs / zWithBias;


		% Step2: evaluate sum of squared errors using calculated weights
		net1 = weights1 * inputsWithBias;
		e1 = net1 - az;
		q1 = sum(sum(e1 .^ 2));	% error of z compared to w1 * x

		net2 = weights2 * zWithBias;
		e2 = net2 - aOutputs;
		q2 = sum(sum(e2 .^ 2));	% error of aO compared to w2 * z (not equal to w2 * f2(w1 * x)!)

		qSum = q1 + q2;
		q(i) = qSum;

		hiddenOutputsWithBias = [fnn.activation1(net1); repmat(1, 1, nSamples)];
		evaluatedOutputs = fnn.activation2(weights2 * hiddenOutputsWithBias);
		mse(i) = sum(sum((outputs - evaluatedOutputs) .^ 2)) / nSamples;
		nSaturated(i) = sum(sum(abs(net1) > 0.9));	% number of saturated hidden neurons

		% Step3: convergence check
		%if (abs(mse - prevMse) < minMseChange) || (abs(qSum - prevQ) < minQChange)
		%	break;
		%end

		% Step4 + 5: check improvement and update intermediate outputs
		%if qSum > prevQ
		%	printf('qSum larger than before\n');
		%	stepSize = stepSize / 2
		%	z = prevZ;
		%	prevMse = prev2Mse;
		%	prevQ = prev2Q;
		%else
			prev2Mse = prevMse;
			prevMse = mse(i);
			prev2Q = prevQ;
			prevQ = qSum;
			prevZ = z;

			deltaQ1 = -2 * e1 .* activation1invd(z);
			deltaQ2 = 2 * weights2(:, 1:size(weights2, 2) - 1)' * e2;

			deltaQ = deltaQ1 + deltaQ2;
			deltaQnorm = sum(sum(deltaQ .^ 2));
			deltaZConstant = stepSize * qSum / deltaQnorm;
			deltaZ = deltaZConstant * deltaQ;
			z = z - deltaZ;
		%end
	end

	% pack fnn and return
	if useInputBias == true
		fnn.weights1 = weights1(:, 1:size(weights1, 2) - 1);
		fnn.bias1 = weights1(:, size(weights1, 2));
	else
		fnn.weights1 = weights1;
		fnn.bias1 = zeros(fnn.nHiddenNeurons, 1);
	end
	fnn.weights2 = weights2(:, 1:size(weights2, 2) - 1);
	fnn.bias2 = weights2(:, size(weights2, 2));

	trainedFnn = fnn;
end
