
function b = backward(gnn, graph, state)
% Perform the 'backward' step of GNN training
%
% usage: b = backward(gnn, graph, state)
%
% state: stable state, calculated by forward()

	A = calculatea(gnn.transitionNet, graph, state);
	outputs = applynet(gnn.outputNet, [graph.nodeLabels state]);
	errorDerivative = 2 .* (graph.expectedOutput - outputs);
	penaltyDerivative = penaltyderivative(gnn, graph, state, A)
end
