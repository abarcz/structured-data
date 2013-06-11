
function [weightDeltas nSteps penaltyAdded] = backward(gnn, graph, state, 
maxBackwardSteps)
% Perform the 'backward' step of GNN training
%
% usage: [weightDeltas nSteps penaltyAdded] = backward(gnn, graph, state, 
% maxBackwardSteps)
%
% state : stable state, calculated by forward
% return : deltas for both transition and output networks of gnn

	outputs = applynet(gnn.outputNet, state);
	outputErrors = 2 .* (graph.expectedOutput - outputs);
	if graph.nodeOrientedTask == false
		selectedNodeErrors = outputErrors(1, :);
		outputErrors = zeros(size(outputErrors));
		outputErrors(1, :) = selectedNodeErrors;
	end

	outputDeltas = outputdeltas(gnn.outputNet, graph, state, outputErrors);

	% sparse matrix calculations, cause size(A) = N x N x s^2
	% A can contain whole training set as a single graph
	A = calculatea(gnn.transitionNet, graph, state);
	b = sparse(calculateb(gnn.outputNet, graph, state, outputErrors));
	accumulator = b;	% accumulator contains dew/do * dG/wx
	nSteps = 0;
	do
		% if there are too many backward steps, we can get infinities 
		if nSteps > maxBackwardSteps
			break;
		end
		lastAccumulator = accumulator;
		% for each source node, backpropagate error of its target nodes
		% A : influence of source nodes on target nodes
		% accumulator : errors de/dx from previous timestep (t + 1)
		% b : de/do * dG/dx error, injected at each step
		accumulator = accumulator * A + b;
		nSteps = nSteps + 1;
	until(stablestate(lastAccumulator, accumulator, gnn.minErrorAccDiff));

	transitionErrors = reshape(accumulator, graph.nNodes, gnn.stateSize);
	transitionDeltas = transitiondeltas(gnn.transitionNet, graph, state, 
transitionErrors);

	% calculate penalty dp/dw, assuring that F is a contraction map
	[penaltyDerivative penaltyAdded] = penaltyderivative(gnn,graph,state,A);
	penaltyDeltas = reshapedeltas(gnn.transitionNet, penaltyDerivative);

	weightDeltas = struct(...
		'output', outputDeltas,...
		'transition', transitionDeltas,...
		'transitionPenalty', penaltyDeltas);
end
