
function gnnDeltas = backward(gnn, graph, state)
% Perform the 'backward' step of GNN training
%
% usage: b = backward(gnn, graph, state)
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
	accumulator = sparse(randn(1, graph.nNodes * gnn.stateSize));	% zero mean, unit variance
	count = 0;
	do
		lastAccumulator = accumulator;
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

	gnnDeltas = struct('output', outputDeltas, 'transition', transitionDeltas);
end
