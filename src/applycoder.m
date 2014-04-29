
function outputs = applycoder(fnn, inputs)
% Apply the coder part of RAAM to (non-biased) inputs
%
% usage: outputs = applynet(fnn, inputs)
%
% inputs - each row is a single sample
% outputs - each row contains output for a single sample

	inputs = inputs';
	nSamples = size(inputs, 2);

	% hidden layer feed
	net1 = fnn.weights1 * inputs + repmat(fnn.bias1, 1, nSamples);
	hiddenOutputs = fnn.activation1(net1);

	outputs = hiddenOutputs';
end
