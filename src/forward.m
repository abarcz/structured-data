
function [state nSteps] = forward(gnn, graph, maxForwardSteps, state=0)
% Perform the 'forward' step of GNN training
% compute node states until stable state is reached
%
% usage: [state nSteps] = forward(gnn, graph, maxForwardSteps, state=0)

	if state == 0
		state = initstate(gnn, graph);
	end
	nSteps = 0;
	do
		if nSteps > maxForwardSteps
			% printf('Too many forward steps: %d, aborting\n', nSteps);
			return;
		end
		lastState = state;
		state = transition(gnn.transitionNet, lastState, graph);
		nSteps = nSteps + 1;
	until(stablestate(lastState, state, gnn.minStateDiff));
	% printf('Transitions made until stable state was reached: %d\n', nSteps);
end
