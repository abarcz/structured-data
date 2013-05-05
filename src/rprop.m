
function [rpropState weightUpdates] = rprop(rpropState, errorDerivatives)
% Perform a step of RPROP algorithm for weight update calculation
%
% usage: [rpropState weightUpdates] = rprop(rpropState, errorDerivatives)
%
% weightUpdates - deltas that should be added to fnn weights

	errors = errorDerivatives;
	rpropState.weights1 = rpropupdate(rpropState.weights1, errors.deltaWeights1, rpropState.deltaMin, rpropState.deltaMax);
	rpropState.bias1 = rpropupdate(rpropState.bias1, errors.deltaBias1, rpropState.deltaMin, rpropState.deltaMax);
	rpropState.weights2 = rpropupdate(rpropState.weights2, errors.deltaWeights2, rpropState.deltaMin, rpropState.deltaMax);
	rpropState.bias2 = rpropupdate(rpropState.bias2, errors.deltaBias2, rpropState.deltaMin, rpropState.deltaMax);

	weightUpdates = struct(...
		'deltaWeights1', rpropState.weights1.weightUpdates,...
		'deltaBias1', rpropState.bias1.weightUpdates,...
		'deltaWeights2', rpropState.weights2.weightUpdates,...
		'deltaBias2', rpropState.bias2.weightUpdates,...
		'deltaInputs', errors.deltaInputs);
end
