
function state = forward(gnn, graph)
% Forward function of GNN model, computing node states until stable state is reached

	state = initstate(graph, gnn.stateSize);
	count = 0;
	do
		lastState = state;
		state = transition(gnn, lastState, graph);
		count = count + 1;
	until(stablestate(lastState, state, gnn.minStateDiff));
	printf('Transitions made until stable state was reached: %d\n', count);
end

