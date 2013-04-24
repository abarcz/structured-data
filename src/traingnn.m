
function [gnn state] = traingnn(gnn, graph, nIterations, learningConstant1=0.1, learningConstant2=0.01)
% Trains GNN using graph as training set
%
% usage: [gnn state] = traingnn(gnn, graph, nIterations, learningConstant1=0.1, learningConstant2=0.01)
%

	state = forward(gnn,graph);
	count = 0;
	do
		deltas = backward(gnn, graph, state);
		gnn.transitionNet = updateweights(gnn.transitionNet,...
			deltas.transition, learningConstant1);
		gnn.outputNet = updateweights(gnn.outputNet,...
			deltas.output, learningConstant2);

		state = forward(gnn, graph);
		outputs = applynet(gnn.outputNet, state); %[graph.nodeLabels state])
		graph.expectedOutput;
		err = rmse(graph.expectedOutput, outputs);
		count = count + 1;
		printf('RMSE after %d iterations: %f\n', count, err);
	until count == nIterations
end
