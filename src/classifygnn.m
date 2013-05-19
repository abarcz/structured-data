
function [outputs nForwardSteps] = classifygnn(gnn, graph, maxForwardSteps=200, state=0)
% Classify graph nodes using gnn
%
% usage: [outputs nForwardSteps] = classifygnn(gnn, graph, maxForwardSteps=200, state=0)
%

	if state != 0
		assert(size(state, 1) == graph.nNodes);
		assert(size(state, 2) == gnn.stateSize);
	end

	% normalize graph labels using information stored by traingnn
	graph.nodeLabels = normalize(graph.nodeLabels, ...
		gnn.nodeLabelMeans, gnn.nodeLabelStds);
	graph.edgeLabels(:, 3:end) = normalize(graph.edgeLabels(:, 3:end), ...
		gnn.edgeLabelMeans, gnn.edgeLabelStds);
	graph = addgraphinfo(graph);

	[finalState nForwardSteps] = forward(gnn,graph, maxForwardSteps, state);
	outputs = applynet(gnn.outputNet, finalState);
	if graph.nodeOrientedTask == false
		outputs = outputs(1, :);
	else
end
