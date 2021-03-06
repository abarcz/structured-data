
function plot3dgraph(graph, hiddenEdges=false)
% Plots a graph in 3d as unidirectional
% First three fields of node label are treated as xyz coordinates
% Requires: octave-plot
%
% usage: plot3dgraph(graph, hiddenEdges=false)
%

	adjacency = zeros(graph.nNodes);
	nEdges = graph.nEdges;
	for i = 1:nEdges
		sourceNode = graph.edgeLabels(i, 1);
		targetNode = graph.edgeLabels(i, 2);
		if hiddenEdges && graph.edgeLabels(i, 3) == 0
			continue;
		end
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
