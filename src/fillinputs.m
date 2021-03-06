
function inputStruct = fillinputs(inputStruct, state=0)
% Fill the state part of inputMatrix.
% A source state is used multiple times in the inputMatrix.

	assert(size(state, 1) == inputStruct.nNodes);
	assert(size(state, 2) == inputStruct.stateSize);
	stateFirstIndex = inputStruct.stateFirstIndex;
	for nodeIndex = 1:inputStruct.nNodes
		nodeState = state(nodeIndex, :);
		dstRows = inputStruct.dstRows{nodeIndex};
		for i = 1:size(dstRows, 2)
			rowIndex = dstRows(i);
			inputStruct.inputMatrix(rowIndex, stateFirstIndex:end) = nodeState;
		end
	end
end
