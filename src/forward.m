
function state = forward(gnn, graph)
% FORWARD function computing state
	state = initstate(graph, gnn.stateSize);
	count = 0;
	do
		lastState = state;
		state = transition(gnn, lastState, graph);
		count = count + 1;
	until(stablestate(lastState, state));
	disp(count);
end

