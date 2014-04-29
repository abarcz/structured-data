
function outputs = applydecoder(fnn, inputs)
% Apply decoder part of RAAM network
%
% usage: outputs = applynet(fnn, inputs)
%
% inputs - each row is a single sample
% outputs - each row contains output for a single sample

	inputs = inputs';
	nSamples = size(inputs, 2);

	% visible layer feed
	net2 = fnn.weights2 * inputs + repmat(fnn.bias2, 1, nSamples);
	outputs = fnn.activation2(net2)';
end
