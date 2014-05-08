
function graph = addgraphinfo(graph, normalizeLabels=true)
% Add extra structures to graph, facilitating graph processing

	nNodes = graph.nNodes;
	edgeLabels = graph.edgeLabels;

	% add source nodes
	sourceNodes = {};
	for targetIndex = 1:nNodes
		sourceNodes{targetIndex} = edgeLabels(edgeLabels(:, 2) == targetIndex, 1)';
	end

	% add target nodes
	targetNodes = {};
	for sourceIndex = 1:nNodes
		targetNodes{sourceIndex} = edgeLabels(edgeLabels(:, 1) == sourceIndex, 2)';
	end

	% create cell array of edge labels, for better indexing
	if normalizeLabels
		edgeLabels(:, 3:end) = normalize(edgeLabels(:, 3:end));
	end
	edgeLabelsCell = {};
	for i = 1:size(edgeLabels, 1)
		sourceNode = edgeLabels(i, 1);
		targetNode = edgeLabels(i, 2);
		label = edgeLabels(i, 3:end);
		edgeLabelsCell{sourceNode, targetNode} = label;
	end

	graph.sourceNodes = sourceNodes;
	graph.targetNodes = targetNodes;
	graph.edgeLabelsCell = edgeLabelsCell;
end
