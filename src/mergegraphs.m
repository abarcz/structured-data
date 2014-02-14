
function graph = mergegraphs(graphs)
% Merge input cellarray of graphs to a single graph
%
% usage: graph = mergegraphs(graphs)
%

	nGraphs = size(graphs, 2);
	assert(nGraphs > 0);

	graph = graphs{1};
	graphEndIndexes = zeros(nGraphs, 1);
	for i = 2:nGraphs
		currGraph = graphs{i};
		assert(graph.nodeLabelSize == currGraph.nodeLabelSize);
		assert(graph.edgeLabelSize == currGraph.edgeLabelSize);
		assert(graph.nodeOutputSize == currGraph.nodeOutputSize);
		indexShift = size(graph.nodeLabels, 1);
		graphEndIndexes(i, 1) = indexShift;
		if currGraph.maxIndegree > graph.maxIndegree
			graph.maxIndegree = currGraph.maxIndegree;
		end
		graph.nodeLabels = [graph.nodeLabels; currGraph.nodeLabels];
		graph.expectedOutput = [graph.expectedOutput; currGraph.expectedOutput];
		% add edgeLabels
		newEdgeLabels = currGraph.edgeLabels;
		newEdgeLabels(:, 1:2) = newEdgeLabels(:, 1:2) + ...
			repmat(indexShift, size(newEdgeLabels(:, 1:2)));
		graph.edgeLabels = [graph.edgeLabels; newEdgeLabels];
	end
	graph.nNodes = size(graph.nodeLabels, 1);
	graph.nEdges = size(graph.edgeLabels, 1);
	graph.graphEndIndexes = graphEndIndexes;
end
