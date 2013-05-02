
function [gnn rmserrors] = traingnn(gnn, graph, nIterations, learningConstant1=0.1, learningConstant2=0.01, max_forward_steps=50, max_backward_steps=200)
% Trains GNN using graph as training set
%
% usage: [gnn rmserrors] = traingnn(gnn, graph, nIterations, learningConstant1=0.1, learningConstant2=0.01, max_forward_steps=50, max_backward_steps=200)
%
% return: best gnn obtained during training and all errors
%

	% normalize edge and node labels
	% store normalization info inside result gnn
	[graph.nodeLabels gnn.nodeLabelMeans gnn.nodeLabelStds] = ...
		normalize(graph.nodeLabels);
	[graph.edgeLabels(:, 3:end) gnn.edgeLabelMeans gnn.edgeLabelStds] = ...
		normalize(graph.edgeLabels(:, 3:end));
	graph = addgraphinfo(graph);

	state = forward(gnn, graph, max_forward_steps);
	rmserrors = zeros(nIterations, 1);
	count = 0;
	minError = Inf;
	bestGnn = gnn;
	rpropTransitionState = initrprop(gnn.transitionNet);
	rpropOutputState = initrprop(gnn.outputNet);
	do
		deltas = backward(gnn, graph, state, max_backward_steps);

		outputDerivatives = deltas.output;
		[rpropOutputState outputWeightUpdates] = rprop(rpropOutputState, outputDerivatives);

		transitionDerivatives = adddeltas(deltas.transition, deltas.transitionPenalty);
		[rpropTransitionState transitionWeightUpdates] = rprop(rpropTransitionState, transitionDerivatives);

		gnn.outputNet = updateweights(gnn.outputNet,...
			outputWeightUpdates, 1);
		gnn.transitionNet = updateweights(gnn.transitionNet,...
			transitionWeightUpdates, 1);

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
		rmserrors(count) = err;
		if err < minError
			minError = err;
			bestGnn = gnn;
		end
	until count == nIterations
	gnn = bestGnn;
end
