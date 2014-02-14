
function graphe = edgerepr(graph)
% Transform 3d graph from node representation
% (each node label contain x,y,z coordinates)
% to edge representation
% (distances between nodes are encoded in edges, first node is 0,0,0)

	edgecoords = zeros(graph.nEdges, 3);
	for i = 1:graph.nEdges
		source = graph.edgeLabels(i, 1);
		target = graph.edgeLabels(i, 2);
		edgecoords(i, :) = graph.nodeLabels(target, 1:3) - graph.nodeLabels(source, 1:3);
	end
	graphe = graph;
	graphe.nodeLabels = graph.nodeLabels(:, 4:graph.nodeLabelSize);
	graphe.nodeLabelSize = graph.nodeLabelSize - 3;
	graphe.edgeLabels = [graph.edgeLabels(:, 1:2), edgecoords];
	if graph.edgeLabelSize > 0
		graphe.edgeLabels = [graphe.edgeLabels, graph.edgeLabels(:, 3:graph.edgeLabelSize + 2)];
	end
	graphe.edgeLabelSize = graph.edgeLabelSize + 3;
end
