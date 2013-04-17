
function endIndex = blockend(nodeIndex, stateSize)
% Helper function for Jacobian block matrix A indexing
%
% usage: endIndex = blockend(nodeIndex, stateSize)
%
% returns starting index of block corresponding to nodeIndex

	endIndex = nodeIndex * stateSize;
end
