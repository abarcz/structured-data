
function plotcrystal(graph, hiddenEdges=false)
% Plots a graph in 3d as unidirectional
% First three fields of edge label are treated as xyz (abc) distances
% First node is treated as 0,0,0 point
%
% Requires: octave-plot
%
% usage: plotcrystal(graph)
%

	graphn = noderepr(graph);
	plot3dgraph(graphn, hiddenEdges);
end
