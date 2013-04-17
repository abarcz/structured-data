
function outputs = applynet(fnn, inputs)
% Apply given FNN to (non-biased) inputs
%
% usage: outputs = applynet(fnn, inputs)
%
% inputs - each column is a single sample
% outputs - each column contains output for a single sample

	nSamples = size(inputs, 2);

	% hidden layer feed
	net1 = fnn.weights1 * inputs + repmat(fnn.bias1, 1, nSamples);
	hiddenOutputs = fnn.activation1(net1);

	% visible layer feed
	net2 = fnn.weights2 * hiddenOutputs + repmat(fnn.bias2, 1, nSamples);
	outputs = fnn.activation2(net2);
end
