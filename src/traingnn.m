
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
%		+ percentage of transition network weights reverted by rprop
%		+ percentage of output network weights reverted by rprop
%		+ transitionstats() output
%	the first row contains RMSE of initial network
%	the last row contains RMSE of the final network and doesn't contain any backpropagation information
%

	% constants for indexing training stats
	RMSE = 1;
	FORWARD_STEPS = 2;
	BACKWARD_STEPS = 3;
	PENALTY_ADDED = 4;
	RPROP_REVERTED_TRANS = 5;
	RPROP_REVERTED_OUT = 6;
	TRANS_STATS_START = 7;
	TRANS_STATS_END = TRANS_STATS_START + 3;
	trainStats = zeros(nIterations + 1, TRANS_STATS_END);

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
		if graph.nodeOrientedTask == false
			err = rmse(graph.expectedOutput(1, :), outputs(1, :));
		else
			err = rmse(graph.expectedOutput, outputs);
		end
		trainStats(iteration, RMSE) = err;
		if err < minError
			minError = err;
			bestGnn = gnn;
		end

		[deltas nBackwardSteps penaltyAdded] = backward(gnn, graph, state, maxBackwardSteps);
		trainStats(iteration, BACKWARD_STEPS) = nBackwardSteps;
		trainStats(iteration, PENALTY_ADDED) = penaltyAdded;
		trainStats(iteration, TRANS_STATS_START:TRANS_STATS_END) = round(transitionstats(deltas));

		outputDerivatives = deltas.output;
		[rpropOutputState outputWeightUpdates nOutputReverted] = rprop(rpropOutputState, outputDerivatives);
		trainStats(iteration, RPROP_REVERTED_OUT) = round(nOutputReverted * 100 / gnn.outputNet.nWeights);

		transitionDerivatives = adddeltas(deltas.transition, deltas.transitionPenalty);
		[rpropTransitionState transitionWeightUpdates nTransitionReverted] = rprop(rpropTransitionState, transitionDerivatives);
		trainStats(iteration, RPROP_REVERTED_TRANS) = round(nTransitionReverted * 100 / gnn.transitionNet.nWeights);

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
	if graph.nodeOrientedTask == false
		err = rmse(graph.expectedOutput(1, :), outputs(1, :));
	else
		err = rmse(graph.expectedOutput, outputs);
	end
	trainStats(iteration, RMSE) = err;
	%printf('RMSE after %d iterations: %f\n', iteration - 1, err);
	if err < minError
		minError = err;
		bestGnn = gnn;
	end
end
