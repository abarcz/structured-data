
function [rpropState weightUpdates nReverted] = rprop(rpropState, errorDerivatives)
% Perform a step of RPROP algorithm for weight update calculation
%
% usage: [rpropState weightUpdates nReverted] = rprop(rpropState, errorDerivatives)
%
% weightUpdates - deltas that should be added to fnn weights

	errors = errorDerivatives;
	[rpropState.weights1 nReverted1] = rpropupdate(rpropState.weights1, errors.deltaWeights1, rpropState.deltaMin, rpropState.deltaMax);
	[rpropState.bias1 nReverted2] = rpropupdate(rpropState.bias1, errors.deltaBias1, rpropState.deltaMin, rpropState.deltaMax);
	[rpropState.weights2 nReverted3] = rpropupdate(rpropState.weights2, errors.deltaWeights2, rpropState.deltaMin, rpropState.deltaMax);
	[rpropState.bias2 nReverted4] = rpropupdate(rpropState.bias2, errors.deltaBias2, rpropState.deltaMin, rpropState.deltaMax);

	weightUpdates = struct(...
		'deltaWeights1', rpropState.weights1.weightUpdates,...
		'deltaBias1', rpropState.bias1.weightUpdates,...
		'deltaWeights2', rpropState.weights2.weightUpdates,...
		'deltaBias2', rpropState.bias2.weightUpdates,...
		'deltaInputs', errors.deltaInputs);

	nReverted = nReverted1 + nReverted2 + nReverted3 + nReverted4;
end
