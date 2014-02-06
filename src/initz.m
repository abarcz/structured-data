
function z = initz(fnn, inputs)
% Initialize z for SBLLM

	% unpack fnn and add bias
	nSamples = size(inputs, 1);
	inputsWithBias = [inputs'; repmat(1, 1, nSamples)];
	weights1 = [fnn.weights1, fnn.bias1];
	% hidden layer feed
	net1 = weights1 * inputsWithBias;
	hiddenOutputs = fnn.activation1(net1);

	% eta seems to do much harm to the learning process
	%eta = 0.0001;
	z = hiddenOutputs;% + (eta * 2 * (rand(size(hiddenOutputs)) - 0.5));
	%z = rand(size(hiddenOutputs)) .* 0.9 + 0.05;	% uniformly distributed over [0.05, 0.95]
	%z = rand(size(hiddenOutputs)) .* 1.8 - 0.9;	% uniformly distributed over [-0.6, 0.6]

	% scale the output so that the z values predicted by weights2 are in (-1, 1)
	%aOutputs = activation2inv(outputs);
	%zBack = ((aOutputs' .- fnn.bias2) / fnn.weights2')';
	%div = ceil(max(abs(vec(zBack))));
	%outputs = outputs ./ div;

	%aOutputs = activation2inv(outputs);
	%zBack = ((aOutputs' .- fnn.bias2) / fnn.weights2')';
	%z = (hiddenOutputs + zBack) ./2;

	% adjust the initial weights1
	%aOutputs = activation2inv(outputs);
	%zBackAdj = fnn.weights2 \ (aOutputs .- fnn.bias2);
	%weights1 = realatanh(zBackAdj) / inputsWithBias;
	%net1 = weights1 * inputsWithBias;
	%z = fnn.activation1(net1);
end
