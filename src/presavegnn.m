
function gnn = presavegnn(gnn)
% Remove function handlers, so that gnn can be saved to file
% (walkaround of a bug in octave)
%
% usage: gnn = presavegnn(gnn)
%
	gnn.outputNet = presavefnn(gnn.outputNet);
	gnn.transitionNet = presavefnn(gnn.transitionNet);
end
