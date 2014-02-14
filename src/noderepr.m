
function graphn = noderepr(graph)
% Transform 3d graph from edge representation
% (distances between nodes are encoded in edges, first node is 0,0,0)
% to node representation
% (each node label contain x,y,z coordinates)

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
	graphn = graph;
	graphn.nodeLabels = [coordinates, graph.nodeLabels];
	graphn.edgeLabels = graph.edgeLabels(:, 1:2);
	if graph.edgeLabelSize > 3
		graphn.edgeLabels = [graphn.edgeLabels, graph.edgeLabels(:, 6:graph.edgeLabelSize + 2)];
	else
		graphn.edgeLabels(:, 3) = zeros(graph.nEdges, 1);
	end
	graphn.nodeLabelSize = size(graphn.nodeLabels, 2);
	graphn.edgeLabelSize = size(graphn.edgeLabels, 2) - 2;
end
