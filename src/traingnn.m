
function gnn = traingnn(gnn, graph, nIterations, learningConstant1=0.1, learningConstant2=0.01, max_forward_steps=50)
% Trains GNN using graph as training set
%
% usage: gnn = traingnn(gnn, graph, nIterations, learningConstant1=0.1, learningConstant2=0.01, max_forward_steps=50)
%

	% normalize edge and node labels
	% store normalization info inside result gnn
	[graph.nodeLabels gnn.nodeLabelMeans gnn.nodeLabelStds] = ...
		normalize(graph.nodeLabels);
	[graph.edgeLabels(:, 3:end) gnn.edgeLabelMeans gnn.edgeLabelStds] = ...
		normalize(graph.edgeLabels(:, 3:end));
	graph = addgraphinfo(graph);

	state = forward(gnn, graph, max_forward_steps);
	count = 0;
	do
		deltas = backward(gnn, graph, state);
		gnn.outputNet = updateweights(gnn.outputNet,...
			deltas.output, learningConstant2);

		gnn.transitionNet = updateweights(gnn.transitionNet,...
			deltas.transition, learningConstant1);
		gnn.transitionNet = updateweights(gnn.transitionNet,...
			deltas.transitionPenalty, learningConstant1);

		try
			contractionPreserved = true;
			state = forward(gnn, graph, max_forward_steps);
		catch
			disp(lasterr());
		end
		outputs = applynet(gnn.outputNet, state);
		graph.expectedOutput;
		err = rmse(graph.expectedOutput, outputs);
		count = count + 1;
		printf('RMSE after %d iterations: %f\n', count, err);
	until count == nIterations
end
