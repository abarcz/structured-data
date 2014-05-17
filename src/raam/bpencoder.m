
function deltas = bpencoder(fnn, inputs, errors)
% Perform backpropagation through the encoding network

	assert(size(inputs, 1) == 1);
	assert(size(inputs, 2) == fnn.nInputLines);
	assert(size(errors, 1) == 1);
	assert(size(errors, 2) == fnn.nHiddenNeurons);

	inputs = inputs';
	errors = errors';

	% fnn feed
	net1 = fnn.weights1 * inputs + fnn.bias1;
	hiddenOutputs = fnn.activation1(net1);

	% calculate delta1 (for all hidden neurons at once)
	% each row of weights2 corresponds to single hidden neuron
	% each element of hiddenErrors corresponds to single hidden neuron
	hiddenErrors = errors;
	delta1 = hiddenErrors .* fnn.activationderivative1(net1);
	deltaWeights1 = delta1 * inputs';
	deltaBias1 = delta1;

	% calculate delta0 (for all input neurons at once)
	inputErrors = fnn.weights1' * delta1;
	delta0 = inputErrors';

	deltas = zerodeltas(fnn);
	deltas.deltaWeights1 = deltaWeights1;
	deltas.deltaBias1 = deltaBias1;
	deltas.deltaInputs = delta0;
end
