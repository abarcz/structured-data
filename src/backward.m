
function weightDeltas = backward(gnn, graph, state)
% Perform the 'backward' step of GNN training
%
% usage: weightDeltas = backward(gnn, graph, state)
%
% state : stable state, calculated by forward(graph, state, transitionErrors);)
% return : deltas for both transition and output networks of gnn

	outputs = applynet(gnn.outputNet, state);
	outputErrors = 2 .* (graph.expectedOutput - outputs);

	outputDeltas = outputdeltas(gnn.outputNet, graph, state, outputErrors);

	% sparse matrix calculations, cause size(A) = N x N x s^2
	% A can contain whole training set as a single graph
	A = calculatea(gnn.transitionNet, graph, state);
	b = sparse(calculateb(gnn.outputNet, graph, state, outputErrors));
	accumulator = b;	% accumulator contains dew/do * dG/wx, to be propagated
	count = 0;
	do
		lastAccumulator = accumulator;
		% for each source node, backpropagate error of its target nodes
		% A : influence of source nodes on target nodes
		% accumulator : errors de/dx from previous timestep (t + 1)
		% b : de/do * dG/dx error, injected at each step
		accumulator = accumulator * A + b;
		count = count + 1;
	until(stablestate(lastAccumulator, accumulator, gnn.minErrorAccDiff));
	printf('Transitions made until error accumulator reached stable state: %d\n', count);

	transitionErrors = reshape(accumulator, graph.nNodes, gnn.stateSize);
	transitionDeltas = transitiondeltas(gnn.transitionNet, graph, state, transitionErrors);

	% calculate penalty dp/dw, assuring that F is a contraction map
	penaltyDerivative = penaltyderivative(gnn, graph, state, A);
	penaltyDeltas = reshapedeltas(gnn.transitionNet, penaltyDerivative);

	transitionDeltas = adddeltas(transitionDeltas, penaltyDeltas);

	weightDeltas = struct('output', outputDeltas, 'transition', transitionDeltas);
end
