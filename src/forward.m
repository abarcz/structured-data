
function state = forward(gnn, graph)
% Perform the 'forward' step of GNN training
% compute node states until stable state is reached

	state = initstate(graph.nNodes, gnn.stateSize);
	count = 0;
	do
		lastState = state;
		state = transition(gnn, lastState, graph);
		count = count + 1;
	until(stablestate(lastState, state, gnn.minStateDiff));
	printf('Transitions made until stable state was reached: %d\n', count);
end
