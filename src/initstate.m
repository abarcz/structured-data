
function state = initstate(gnn, graph)
% Initialize state for GNN calculation

	state = randn(graph.nNodes, gnn.stateSize);	% zero mean, unit variance
end
