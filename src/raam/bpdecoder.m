
function [deltas hiddenErrors] = bpdecoder(fnn, code, errors)
% Perform backpropagation through the decoding network

	assert(size(errors, 1) == 1);
	assert(size(errors, 2) == fnn.nOutputNeurons);
	assert(size(code, 1) == 1);
	assert(size(code, 2) == fnn.nHiddenNeurons);

	errors = errors';
	hiddenOutputs = code';

	net2 = fnn.weights2 * hiddenOutputs + fnn.bias2;

	% calculate delta2 (for all visible neurons at once)
	outputErrors = errors;
	delta2 = outputErrors .* fnn.activationderivative2(net2);
	deltaWeights2 = delta2 * hiddenOutputs';
	deltaBias2 = delta2;

	hiddenErrors = (fnn.weights2' * delta2)';
	assert(size(hiddenErrors, 2) == fnn.nHiddenNeurons);

	deltas = zerodeltas(fnn);
	deltas.deltaWeights2 = deltaWeights2;
	deltas.deltaBias2 = deltaBias2;
end
