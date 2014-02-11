
function graph = transform3dgraph(graph, matrix)
% Apply affine transformation matrix to graph
% First three fields of node label are treated as xyz coordinates
% Requires: octave-geometry
%
% usage: graph = transform3dgraph(graph, matrix)
%

	coords = graph.nodeLabels(:, 1:3);
	newCoords = transformPoint3d(coords, matrix);
	graph.nodeLabels(:, 1:3) = newCoords;
end
