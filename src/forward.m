
function state = forward(gnn, graph, max_forward_steps=200)
% Perform the 'forward' step of GNN training
% compute node states until stable state is reached
%
% usage: state = forward(gnn, graph, max_forward_steps=200)

	state = randn(graph.nNodes, gnn.stateSize);	% zero mean, unit variance
	count = 0;
	do
		if count > max_forward_steps
			error(sprintf('Too many forward steps: %d', count));
		end
		lastState = state;
		state = transition(gnn.transitionNet, lastState, graph);
		count = count + 1;
	until(stablestate(lastState, state, gnn.minStateDiff));
	printf('Transitions made until stable state was reached: %d\n', count);
end
