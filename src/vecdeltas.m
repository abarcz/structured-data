
function column = vecdeltas(deltas)
% Put all dF/dw deltas into a single column in specified order
	
	column = [vec(deltas.deltaWeights1); vec(deltas.deltaBias1);...
		vec(deltas.deltaWeights2); vec(deltas.deltaBias2)];
end
