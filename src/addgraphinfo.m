
function graph = addgraphinfo(graph)
% Add extra structures to graph, facilitating graph processing

	% add source nodes
	sourceNodes = {};
	maxIndegree = 0;
	nNodes = graph.nNodes;
	edgeLabels = graph.edgeLabels;
	for targetIndex = 1:nNodes
		sourceNodes{targetIndex} = edgeLabels(edgeLabels(:, 2) == targetIndex, 1)';
		targetIndegree = size(sourceNodes{targetIndex}, 1);
		if targetIndegree > maxIndegree
			maxIndegree = targetIndegree;
		end
	end

	% create cell array of edge labels, for better indexing
	edgeLabels(:, 3:end) = normalize(edgeLabels(:, 3:end));
	edgeLabelsCell = {};
	for i = 1:size(edgeLabels, 1)
		sourceNode = edgeLabels(i, 1);
		targetNode = edgeLabels(i, 2);
		label = edgeLabels(i, 3:end);
		edgeLabelsCell{sourceNode, targetNode} = label;
	end

	graph.sourceNodes = sourceNodes;
	graph.edgeLabelsCell = edgeLabelsCell;
end
