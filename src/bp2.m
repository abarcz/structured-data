
function delta0 = bp2(fnn, inputs, errors)
% Perform matrix backpropagation (for all inputs at once)a
%
% usage: delta0 = bp2(fnn, inputs, errors)
%
% inputs : row = sample
% errors : row for a sample
% return : row of inputErrors

	nSamples = size(inputs, 1);
	inputs = inputs';
	errors = errors';

	% fnn feed
	net1 = fnn.weights1 * inputs + repmat(fnn.bias1, 1, nSamples);
	hiddenOutputs = fnn.activation1(net1);
	net2 = fnn.weights2 * hiddenOutputs + repmat(fnn.bias2, 1, nSamples);

	% calculate delta2 (for all visible neurons at once)
	outputErrors = errors;
	delta2 = outputErrors .* fnn.activationderivative2(net2);
	
	% calculate delta1 (for all hidden neurons at once)
	% each row of weights2 corresponds to single hidden neuron
	% each element of hiddenErrors corresponds to single hidden neuron
	hiddenErrors = fnn.weights2' * delta2;
	delta1 = hiddenErrors .* fnn.activationderivative1(net1);

	% calculate delta0 (for all input neurons at once)
	inputErrors = fnn.weights1' * delta1;
	delta0 = inputErrors';
end
