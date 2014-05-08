
function graphn = noderepr(graph)
% Transform 3d graph from edge representation
% (distances between nodes are encoded in edges, first node is 0,0,0)
% to node representation
% (each node label contain x,y,z coordinates)

	% fill coordinates of points starting from 0,0,0 node (first node)
	coordinates = zeros(graph.nNodes, 3);
	filled = zeros(1, graph.nNodes);
	filled(1) = 1;
	coordinates(1, :) = [0 0 0];
	graph = addgraphinfo(graph, false);
	visited = zeros(graph.nNodes);
	nodeQueue = [1];
	visited(1) = 1;
	while size(nodeQueue, 2) > 0
		% pop first element
		node = nodeQueue(1);
		nodeQueue = nodeQueue(2:size(nodeQueue, 2));
		targetNodes = graph.targetNodes{node};
		for i = 1:size(targetNodes, 2)
			target = targetNodes(i);
			if visited(target)
				continue;
			else
				visited(target) = 1;
			end
			nodeQueue(size(nodeQueue, 2) + 1) = target;
			coordinates(target, :) = coordinates(node, :) + graph.edgeLabelsCell{node, target}(1:3);
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
