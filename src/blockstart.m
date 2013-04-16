
function startIndex = blockstart(nodeIndex, stateSize)
% Helper function for Jacobian block matrix A indexing
%
% usage: startIndex = blockstart(nodeIndex, stateSize)
%
% returns starting index of block corresponding to nodeIndex

	startIndex = 1 + (nodeIndex - 1) * stateSize;
end
