
function state = getnewstate(inputStruct, lastState)
% Get new state from inputStruct filled with stateContributions
% (after doing applynet() on inputStruct.inputMatrix)

	nNodes = inputStruct.nNodes;
	stateSize = inputStruct.stateSize;
	inputMatrix = inputStruct.inputMatrix;
	stateFirstIndex = inputStruct.stateFirstIndex;

	state = zeros(nNodes, stateSize);
	for i = 1:nNodes
		firstRow = inputStruct.stateFirstRow(i);
		lastRow = inputStruct.stateLastRow(i);
		if (firstRow != 0)
			contributions = inputMatrix(firstRow:lastRow, stateFirstIndex:end);
			nodeState = sum(contributions, 1);
		else
			nodeState = lastState(i, :);
		end
		state(i, :) = nodeState;
	end
end
