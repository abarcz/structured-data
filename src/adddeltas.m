
function deltas = adddeltas(deltas1, deltas2)
% Sum two structures returned by backpropagate()
%
% usage: deltas = adddeltas(deltas1, deltas2)
%

	deltas.deltaWeights1 = deltas1.deltaWeights1 + deltas2.deltaWeights1;
	deltas.deltaWeights2 = deltas1.deltaWeights2 + deltas2.deltaWeights2;
	deltas.deltaBias1 = deltas1.deltaBias1 + deltas2.deltaBias1;
	deltas.deltaBias2 = deltas1.deltaBias2 + deltas2.deltaBias2;
	deltas.deltaInputs = deltas1.deltaInputs + deltas2.deltaInputs;
end
