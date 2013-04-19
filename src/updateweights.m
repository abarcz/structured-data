
function fnn = updateweights(fnn, deltas, learningConstant)
% Update fnn weights according to learningConstant
%
% usage: fnn = updateweights(fnn, deltas, learningConstant)
%

		fnn.weights1 = fnn.weights1 + learningConstant * deltas.deltaWeights1;
		fnn.weights2 = fnn.weights2 + learningConstant * deltas.deltaWeights2;
		fnn.bias1 = fnn.bias1 + learningConstant * deltas.deltaBias1;
		fnn.bias2 = fnn.bias2 + learningConstant * deltas.deltaBias2;
end
