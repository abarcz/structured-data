
function outputs = applynetsingle(fnn, inputs)
% Apply given FNN to (non-biased) single input
%
% usage: outputs = applynet(fnn, inputs)
%
% inputs - single row containing sample
% outputs - single row containing output for sample

	inputs = inputs';
	nSamples = size(inputs, 2);

	% hidden layer feed
	net1 = fnn.weights1 * inputs + fnn.bias1;
	hiddenOutputs = fnn.activation1(net1);

	% visible layer feed
	net2 = fnn.weights2 * hiddenOutputs + fnn.bias2;
	outputs = fnn.activation2(net2)';
end
