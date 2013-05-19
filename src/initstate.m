
function state = initstate(nNodes, stateSize)
% Initialize state for GNN calculation
%
%usage:
%

	state = randn(nNodes, stateSize);	% zero mean, unit variance
end
