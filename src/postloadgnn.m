
function gnn = postloadgnn(gnn)
% Restore function handlers in fnn loaded from file
% (walkaround of a bug in octave)
%
% usage: gnn = postloadgnn(gnn)
%

	gnn.outputNet = postloadfnn(gnn.outputNet);
	gnn.transitionNet = postloadfnn(gnn.transitionNet);
end
