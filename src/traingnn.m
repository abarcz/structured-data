
function gnn = traingnn(gnn, graph, nIterations, learningConstant1=0.1, learningConstant2=0.01, max_forward_steps=200)
% Trains GNN using graph as training set
%
% usage: gnn = traingnn(gnn, graph, nIterations, learningConstant1=0.1, learningConstant2=0.01, max_forward_steps=200)
%

	state = forward(gnn, graph, max_forward_steps);
	count = 0;
	do
		deltas = backward(gnn, graph, state);
		gnn.outputNet = updateweights(gnn.outputNet,...
			deltas.output, learningConstant2);

		gnn.transitionNet = updateweights(gnn.transitionNet,...
			deltas.transition, learningConstant1);
		gnn.transitionNet = updateweights(gnn.transitionNet,...
			deltas.transitionPenalty, 1);

		try
			contractionPreserved = true;
			state = forward(gnn, graph);
		catch
			disp(lasterr());
		end
		outputs = applynet(gnn.outputNet, state); %[graph.nodeLabels state])
		graph.expectedOutput;
		err = rmse(graph.expectedOutput, outputs);
		count = count + 1;
		printf('RMSE after %d iterations: %f\n', count, err);
	until count == nIterations
end
