
function backward(gnn, graph, state)
% Perform the 'backward' step of GNN training
%
% state: stable state, calculated by forward()

	outputs = applynet(gnn.outputNet, [graph.nodeLabels' state]);
	A = calculatea(gnn, graph, state);
end
