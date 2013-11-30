
function trainedFnn = traincst(fnn, inputs, outputs)
% inputs - each row is a single sample (normalized)
% outputs - each row contains output for a single sample (normalized)

	if strcmp(fnn.activation2name, 'purelin') == 1
		activation2inv = @(x) x;
	elseif strcmp(fnn.activation2name, 'tansig') == 1
		activation2inv = @(x) realatanh(x);
	else
		error(sprintf('Unknown activation function: %s', fnn.activation2name));
	end

	% Step0: initialize
	outputs = outputs';
	prevQ = Inf;
	prevMse = Inf;
	prev2Q = Inf;
	prev2Mse = Inf;
	minQChange = 1e-10;
	minMseChange = 1e-10;
	eta = 0.0001;
	stepSize = 1;
	nSamples = size(inputs, 1);
	% unpack fnn and add bias
	inputsWithBias = [inputs'; repmat(1, 1, nSamples)];
	weights1 = [fnn.weights1, fnn.bias1];
	weights2 = [fnn.weights2, fnn.bias2];
	% hidden layer feed
	net1 = weights1 * inputsWithBias;
	hiddenOutputs = fnn.activation1(net1);

	% eta seems to do much harm to the learning process
	z = hiddenOutputs;% + (eta * 2 * (rand(size(hiddenOutputs)) - 0.5));
	prevZ = z;

	aOutputs = activation2inv(outputs);
	count = 1;
	while (1)
		printf('\niteration %d\n', count);
		% Step1: calculate weights and biases

		% calculate hidden layer weights
		az = realatanh(z);

		zChange = sum(sum(abs(z - prevZ)))
		azChange = sum(sum(abs(realatanh(z) - realatanh(prevZ))))
		weights1 = az / inputsWithBias;

		% calculate output layer weights
		zWithBias = [z; repmat(1, 1, nSamples)];
		weights2 = aOutputs / zWithBias;


		% Step2: evaluate sum of squared errors using calculated weights
		net1 = weights1 * inputsWithBias;
		e1 = net1 - az;
		q1 = sum(sum(e1 .^ 2));
		net2 = weights2 * zWithBias;
		e2 = net2 - aOutputs;
		q2 = sum(sum(e2 .^ 2));
		qSum = q1 + q2
		evaluatedOutputs = fnn.activation2(net2);
		mse = sum((outputs - evaluatedOutputs) .^ 2) / nSamples


		% Step3: convergence check
		if (abs(mse - prevMse) < minMseChange) || (abs(qSum - prevQ) < minQChange)
			break;
		end


		% Step4 + 5: check improvement and update intermediate outputs
		if qSum > prevQ
			printf('qSum larger than before\n');
			stepSize = stepSize / 2
			z = prevZ;
			prevMse = prev2Mse;
			prevQ = prev2Q;
		else
			printf('qSum smaller\n');
			prev2Mse = prevMse;
			prev2Q = prevQ;
			prevMse = mse;
			prevQ = qSum;

			deltaQ1 = -2 * e1 ./ fnn.activationderivative1(z);
			nColsWeights2 = size(weights2, 2);
			deltaQ2 = 2 * weights2(:, 1:nColsWeights2 - 1)' * e2;
			deltaQ = deltaQ1 + deltaQ2;
			deltaQnorm = sum(sum(deltaQ .^ 2))

			prevZ = z;

			deltaZConstant = stepSize * qSum / deltaQnorm
			deltaZ =  deltaZConstant * deltaQ;

			qChange = sum(sum(deltaZ .* deltaQ))
			maxDeltaZ = max(max(deltaZ))
			z = z - deltaZ;
		end
		count = count + 1;
	end

	% pack fnn and return
	nCols1 = size(weights1, 2);
	fnn.weights1 = weights1(:, 1:nCols1 - 1);
	fnn.bias1 = weights1(:, nCols1);

	nCols2 = size(weights2, 2);
	fnn.weights2 = weights2(:, 1:nCols2 - 1);
	fnn.bias2 = weights2(:, nCols2);
	trainedFnn = fnn;
end
