
function outputs = classifygnn(gnn, graph, max_forward_steps=200)
% Classify graph nodes using gnn
%
% usage: outputs = classifygnn(gnn, graph, max_forward_steps=200)
%

	% normalize graph labels using information stored by traingnn
	graph.nodeLabels = normalize(graph.nodeLabels, ...
		gnn.nodeLabelMeans, gnn.nodeLabelStds);
	graph.edgeLabels(:, 3:end) = normalize(graph.edgeLabels(:, 3:end), ...
		gnn.edgeLabelMeans, gnn.edgeLabelStds);
	graph = addgraphinfo(graph);

	state = forward(gnn,graph, max_forward_steps);
	outputs = applynet(gnn.outputNet, state);
end
