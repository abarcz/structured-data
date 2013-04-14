
function state = initstate(nNodes, stateSize)
% Initialize state: a state vector xn for every n'th node of the graph

	state = {};
	for i = 1:nNodes
		state{i} = randn(1, stateSize);	% zero mean, unit variance
	end
end
