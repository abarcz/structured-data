
function state = initstate(nNodes, stateSize)
% Initialize state for GNN calculation
%
% usage: state = initstate(nNodes, stateSize)
%

	state = randn(nNodes, stateSize);	% zero mean, unit variance
end
