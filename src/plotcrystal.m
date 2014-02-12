
function plotcrystal(graph)
% Plots a graph in 3d as unidirectional
% First three fields of edge label are treated as xyz (abc) distances
% First node is treated as 0,0,0 point
%
% Requires: octave-plot
%
% usage: plotcrystal(graph)
%

	adjacency = zeros(graph.nNodes);
	for i = 1:graph.nEdges
		sourceNode = graph.edgeLabels(i, 1);
		targetNode = graph.edgeLabels(i, 2);
		adjacency(sourceNode, targetNode) = 1;
		adjacency(targetNode, sourceNode) = 1;
	end

	% fill coordinates of points starting from 0,0,0 node (first node)
	% TODO: very unoptimal, should do a recursive search
	coordinates = zeros(graph.nNodes, 3);
	filled = zeros(1, graph.nNodes);
	filled(1) = 1;
	coordinates(1, :) = [0 0 0];
	while sum(filled) < size(filled, 2)
		for i = 1:graph.nNodes
			if filled(i)
				edges = graph.edgeLabels(graph.edgeLabels(:, 1) == i, :);
				nEdges = size(edges, 1);
				for j = 1:nEdges
					target = edges(j, 2);
					if !filled(target)
						coordinates(target, :) = coordinates(i, :) + edges(j, 3:5);
						filled(target) = 1;
						if sum(filled) == size(filled, 2)
							break;
						end
					end
				end
			end
			if sum(filled) == size(filled, 2)
				break;
			end
		end
	end
	minAxis = min(coordinates) - 1;
	maxAxis = max(coordinates) + 1;
	gplot3(adjacency, coordinates, 'o-b');
	grid on;
	axis([minAxis(1) maxAxis(1) minAxis(2) maxAxis(2) minAxis(3) maxAxis(3)]);
	xlabel('x');
	ylabel('y');
	zlabel('z');
end
