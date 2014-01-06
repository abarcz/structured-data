
function [trainedFnn minMse deltaQ1 deltaQ2 dw2 dw1 z net2z] = traincst(fnn, inputs, outputs, nIterations, expandDerivatives, zin, activationInv)
% Train FNN using Castillo method
%
% usage: [trainedFnn minMse deltaQ1 deltaQ2 dw2 dw1 z net2z] = traincst(fnn, inputs, outputs, nIterations, expandDerivatives, zin, activationInv)
%
% inputs - each row is a single sample (normalized)
% outputs - each row contains output for a single sample (normalized)

	if strcmp(fnn.outputFun, 'purelin') == 1
		activation2inv = @(x) x;
	elseif strcmp(fnn.outputFun, 'tansig') == 1
		activation2inv = @(x) realatanh(x);
	else
		error(sprintf('Unknown output activation function: %s', fnn.outputFun));
	end

	if strcmp(fnn.hiddenFun, 'logsig') == 1
		activation1inv = @(x) reallogit(x);
		activation1invd = @(x) 1 ./ (x .* (1 - x));
	elseif strcmp(fnn.hiddenFun, 'tansig') == 1
		activation1inv = @(x) realatanh(x);
		activation1invd = @(x) 1 ./ (1 - x .^ 2);
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
	%z = rand(size(hiddenOutputs)) .* 0.9 + 0.05;	% uniformly distributed over [0.05, 0.95]
	%z = rand(size(hiddenOutputs)) .* 1.8 - 0.9;	% uniformly distributed over [-0.6, 0.6]
	%z = zin;


	% scale the output so that the z values predicted by weights2 are in (-1, 1)
	%aOutputs = activation2inv(outputs);
	%zBack = ((aOutputs' .- fnn.bias2) / fnn.weights2')';
	%div = ceil(max(abs(vec(zBack))));
	%outputs = outputs ./ div;

	%aOutputs = activation2inv(outputs);
	%zBack = ((aOutputs' .- fnn.bias2) / fnn.weights2')';
	%z = (hiddenOutputs + zBack) ./2;

	% adjust the initial weights1
	aOutputs = activation2inv(outputs);
	%zBackAdj = fnn.weights2 \ (aOutputs .- fnn.bias2);
	%weights1 = realatanh(zBackAdj) / inputsWithBias;
	%net1 = weights1 * inputsWithBias;
	%z = fnn.activation1(net1);

	prevZ = z;
	z0 = z;
	count = 1;
	minMse = Inf;
	while (1)
		printf('\niteration %d\n', count);
		% Step1: calculate weights and biases

		% calculate hidden layer weights
		az = activation1inv(z);

		zChange = sum(sum(abs(z - prevZ)))
		azChange = sum(sum(abs(az - activation1inv(prevZ))))
		% multiplying by inputsWithBias'
		% (as in the original article):
		% - can result in singular matrix and yield worse results
		% - can be minimally faster
		%A1 = (inputsWithBias * inputsWithBias');
		%b1 = (net1 * inputsWithBias');
		%weights1 = b1 / A1;
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
		q1 = sum(sum(e1 .^ 2))
		net2 = weights2 * zWithBias;
		net2z = net2;
		e2 = net2 - aOutputs;
		q2 = sum(sum(e2 .^ 2))
		qSum = q1 + q2

		hiddenOutputs = fnn.activation1(net1);	% this can differ from z if z was initialized in non standard way
		hiddenOutputsWithBias = [hiddenOutputs; repmat(1, 1, nSamples)];
		net2real = weights2 * hiddenOutputsWithBias;
		evaluatedOutputs = fnn.activation2(net2real);
		sat = (sum(sum(net1 > 0.9)) + sum(sum(net1 < -0.9))) ./ size(vec(net1), 1)
		mase = sum(e2 .^ 2) / nSamples
		mse = sum((outputs - evaluatedOutputs) .^ 2) / nSamples
		if mse < minMse
			minMse = mse;
		end


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
			printf('qSum smaller\n');
			prev2Mse = prevMse;
			prev2Q = prevQ;
			prevMse = mse;
			prevQ = qSum;

			if expandDerivatives
				%e1 = net1 - az;
				%e2 = net2 - aOutputs;
				nHidden = fnn.nHiddenNeurons;
				nOutputs = fnn.nOutputNeurons;
				dw2 = zeros(nHidden, nSamples);
				for s = 1:nSamples
					for h = 1:nHidden
						acc = 0;
						for j = 1:nOutputs
							for k = 1:nHidden
								% calculate dw_jk/dz_hs
								if h == k
									% dw2/dz == 0, but we take into account wjk*zks
									curr_dw2 = weights2(j, k);
								else
									curr_dw2 = - weights2(j, k) ./ z(h, s);
								end
								acc = acc + curr_dw2;
							end
						end
						dw2(h, s) = acc;
					end
				end

				nInputs = fnn.nInputLines;
				dw1 = zeros(nHidden, nSamples);
				for s = 1:nSamples
					for h = 1:nHidden
						for i = 1:nInputs
							% calculate dw_ki/dz_hs
							% for h != k equal zero (final result)
							acc = acc + 1 ./ inputs(s, i) .* activation1invd(z(h, s));
						end
						dw1(h, s) = acc;
					end
				end
				deltaQ1 = 2 * e1 .* (dw1 - activation1invd(z));
				deltaQ2 = 2 * repmat(e2, nHidden, 1) .* dw2;
			else
				if activationInv
					deltaQ1 = -2 * e1 .* activation1invd(z);
				else
					deltaQ1 = -2 * e1 ./ fnn.activationderivative1(z);
				end
				nColsWeights2 = size(weights2, 2);
				deltaQ2 = 2 * weights2(:, 1:nColsWeights2 - 1)' * e2;
			end

			deltaQ = deltaQ1 + deltaQ2;
			deltaQnorm = sum(sum(deltaQ .^ 2))

			prevZ = z;

			deltaZConstant = stepSize * qSum / deltaQnorm
			deltaZ = deltaZConstant * deltaQ;

			qChange = sum(sum(deltaZ .* deltaQ))
			maxDeltaZ = max(max(deltaZ))
			z = z - deltaZ;
		%end
		count = count + 1;
		if count > nIterations
			break;
		end
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
