
function deltas = backpropagate(fnn, inputs, errors)
% Perform backpropagation
%
% usage: deltas = backpropagate(fnn, inputs, errors)
%
% inputs : row = sample
% errors : row = error for sample (e.g. 2(expected - fnn(inputs)))
% return : struct of deltas to affect weights and biases of fnn

	assert(size(inputs, 1) == 1);
	assert(size(inputs, 2) == fnn.nInputLines);
	assert(size(errors, 1) == 1);
	assert(size(errors, 2) == fnn.nOutputNeurons);

	inputs = inputs';
	errors = errors';

	% fnn feed
	net1 = fnn.weights1 * inputs + fnn.bias1;
	hiddenOutputs = fnn.activation1(net1);
	net2 = fnn.weights2 * hiddenOutputs + fnn.bias2;

	% calculate delta2 (for all visible neurons at once)
	outputErrors = errors;
	delta2 = outputErrors .* fnn.activationderivative2(net2);
	deltaWeights2 = delta2 * hiddenOutputs';
	deltaBias2 = delta2;

	% calculate delta1 (for all hidden neurons at once)
	% each row of weights2 corresponds to single hidden neuron
	% each element of hiddenErrors corresponds to single hidden neuron
	hiddenErrors = fnn.weights2' * delta2;
	delta1 = hiddenErrors .* fnn.activationderivative1(net1);
	deltaWeights1 = delta1 * inputs';
	deltaBias1 = delta1;

	% calculate delta0 (for all input neurons at once)
	inputErrors = fnn.weights1' * delta1;
	delta0 = inputErrors';

	deltas = struct(...
		'deltaWeights1', deltaWeights1,...
		'deltaBias1', deltaBias1,...
		'deltaWeights2', deltaWeights2,...
		'deltaBias2', deltaBias2,...
		'deltaInputs', delta0);
end
