
function [bestGnn trainStats] = traingnn(gnn, graph, nIterations, maxForwardSteps=200, maxBackwardSteps=200)
% Trains GNN using graph as training set
%
% usage: [bestGnn trainStats] = traingnn(gnn, graph, nIterations, maxForwardSteps=200, maxBackwardSteps=200)
%
% return:
% - best gnn obtained during training and all errors
% - trainStats, containing in ith row:
%		+ RMSE after (i - 1) iterations
%		+ forward steps made
%		+ backward steps made
%		+ contraction penalty was added during backpropagation (0/1)
%	the first row contains RMSE of initial network
%	the last row contains RMSE of the final network and doesn't contain any backpropagation information
%

	% constants for indexing training stats
	RMSE = 1;
	FORWARD_STEPS = 2;
	BACKWARD_STEPS = 3;
	PENALTY_ADDED = 4;
	trainStats = zeros(nIterations + 1, 4);

	% normalize edge and node labels
	% store normalization info inside result gnn
	[graph.nodeLabels gnn.nodeLabelMeans gnn.nodeLabelStds] = ...
		normalize(graph.nodeLabels);
	[graph.edgeLabels(:, 3:end) gnn.edgeLabelMeans gnn.edgeLabelStds] = ...
		normalize(graph.edgeLabels(:, 3:end));
	graph = addgraphinfo(graph);

	minError = Inf;
	bestGnn = gnn;
	rpropTransitionState = initrprop(gnn.transitionNet);
	rpropOutputState = initrprop(gnn.outputNet);
	for iteration = 1:nIterations
		[state nForwardSteps] = forward(gnn, graph, maxForwardSteps);
		trainStats(iteration, FORWARD_STEPS) = nForwardSteps;

		outputs = applynet(gnn.outputNet, state);
		err = rmse(graph.expectedOutput, outputs);
		trainStats(iteration, RMSE) = err;
		if err < minError
			minError = err;
			bestGnn = gnn;
		end

		[deltas nBackwardSteps penaltyAdded] = backward(gnn, graph, state, maxBackwardSteps);
		trainStats(iteration, BACKWARD_STEPS) = nBackwardSteps;
		trainStats(iteration, PENALTY_ADDED) = penaltyAdded;

		outputDerivatives = deltas.output;
		[rpropOutputState outputWeightUpdates] = rprop(rpropOutputState, outputDerivatives);

		transitionDerivatives = adddeltas(deltas.transition, deltas.transitionPenalty);
		[rpropTransitionState transitionWeightUpdates] = rprop(rpropTransitionState, transitionDerivatives);

		gnn.outputNet = updateweights(gnn.outputNet,...
			outputWeightUpdates, 1);
		gnn.transitionNet = updateweights(gnn.transitionNet,...
			transitionWeightUpdates, 1);
	end

	% calculate RMSE of final GNN
	iteration = nIterations + 1;

	[state nForwardSteps] = forward(gnn, graph, maxForwardSteps);
	trainStats(iteration, FORWARD_STEPS) = nForwardSteps;

	outputs = applynet(gnn.outputNet, state);
	err = rmse(graph.expectedOutput, outputs);
	trainStats(iteration, RMSE) = err;
	%printf('RMSE after %d iterations: %f\n', iteration - 1, err);
	if err < minError
		minError = err;
		bestGnn = gnn;
	end
end
