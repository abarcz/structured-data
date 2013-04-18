
function res = edgeexists(graph, sourceNode, targetNode)
% Return true, if exists edge src->target
%
% usage: res = edgeexists(graph, sourceNode, targetNode)
%
	res = ismember(sourceNode, graph.sourceNodes{targetNode});
end
