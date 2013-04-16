
function endIndex = blockend(startIndex, stateSize)
% Helper function for Jacobian block matrix A indexing
%
% usage: endIndex = blockend(startIndex, stateSize)
%
% returns starting index of block corresponding to nodeIndex

	endIndex = startIndex + stateSize - 1;
end
