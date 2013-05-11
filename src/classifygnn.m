
function [outputs nForwardSteps] = classifygnn(gnn, graph, maxForwardSteps=200)
% Classify graph nodes using gnn
%
% usage: [outputs nForwardSteps] = classifygnn(gnn, graph, maxForwardSteps=200)
%

	% normalize graph labels using information stored by traingnn
	graph.nodeLabels = normalize(graph.nodeLabels, ...
		gnn.nodeLabelMeans, gnn.nodeLabelStds);
	graph.edgeLabels(:, 3:end) = normalize(graph.edgeLabels(:, 3:end), ...
		gnn.edgeLabelMeans, gnn.edgeLabelStds);
	graph = addgraphinfo(graph);

	[state nForwardSteps] = forward(gnn,graph, maxForwardSteps);
	outputs = applynet(gnn.outputNet, state);
end
