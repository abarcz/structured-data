
function backward(gnn, graph, state)
% Perform the 'backward' step of GNN training
%
% usage: backward(gnn, graph, state)
%
% state: stable state, calculated by forward()

	A = calculatea(gnn.transitionNet, graph, state);
	outputs = applynet(gnn.outputNet, [graph.nodeLabels' state])';
	errorDerivative = 2 .* (graph.expectedOutput - outputs);
	b = calculateb(gnn.outputNet, graph, state);
end
