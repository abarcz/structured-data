
function plot3dgraph(graph)
% Plots a graph in 3d as unidirectional
% First three fields of node label are treated as xyz coordinates
% Requires: octave-plot
%
% usage: plot3dgraph(graph)
%

	adjacency = zeros(graph.nNodes);
	nEdges = size(graph.edgeLabels, 1);
	for i = 1:nEdges
		sourceNode = graph.edgeLabels(i, 1);
		targetNode = graph.edgeLabels(i, 2);
		adjacency(sourceNode, targetNode) = 1;
		adjacency(targetNode, sourceNode) = 1;
	end
	coordinates = graph.nodeLabels(:, 1:3);
	minAxis = min(coordinates) - 1;
	maxAxis = max(coordinates) + 1;
	gplot3(adjacency, coordinates, 'o-b');
	grid on;
	axis([minAxis(1) maxAxis(1) minAxis(2) maxAxis(2) minAxis(3) maxAxis(3)]);
	xlabel('x');
	ylabel('y');
	zlabel('z');
end
