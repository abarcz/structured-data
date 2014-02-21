
function [state nSteps gnn] = forward(gnn, graph, maxForwardSteps, state=0)
% Perform the 'forward' step of GNN training
% compute node states until stable state is reached
%
% usage: [state nSteps gnn] = forward(gnn, graph, maxForwardSteps, state=0)

	if state == 0
		state = initstate(graph.nNodes, gnn.stateSize);
		gnn.initialStates = cellappend(gnn.initialStates, state);
	end
	inputStruct = buildinputs(graph, gnn.stateSize);
	stateFirstIndex = inputStruct.stateFirstIndex;
	nSteps = 1;
	do
		if nSteps > maxForwardSteps
			% printf('Too many forward steps: %d, aborting\n', nSteps);
			return;
		end
		lastState = state;
		inputStruct = fillinputs(inputStruct, lastState);
		stateContributions = applynet(gnn.transitionNet, inputStruct.inputMatrix);
		inputStruct.inputMatrix(:, stateFirstIndex:end) = stateContributions;
		state = getnewstate(inputStruct, lastState);
		nSteps = nSteps + 1;
	until(stablestate(lastState, state, gnn.minStateDiff));
end
