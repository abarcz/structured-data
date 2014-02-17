
function graph = mergegraphs(graphs)
% Merge input cellarray of graphs to a single graph
% Can be used only on not merged previously graphs!
%
% usage: graph = mergegraphs(graphs)
%

	nGraphs = size(graphs, 2);
	assert(nGraphs > 0);

	graph = graphs{1};
	graphEndIndexes = zeros(nGraphs, 1);
	graphOutputIndexes = zeros(nGraphs, 1);
	if graph.nodeOrientedTask == false
		if size(graph.graphOutputIndexes, 1) > 1
			error('mergegraphs not implemented for merged graphs');
		end
		graphOutputIndexes(1) = graph.graphOutputIndexes(1);
	end
	for i = 2:nGraphs
		currGraph = graphs{i};
		assert(graph.nodeLabelSize == currGraph.nodeLabelSize);
		assert(graph.edgeLabelSize == currGraph.edgeLabelSize);
		assert(graph.nodeOutputSize == currGraph.nodeOutputSize);
		indexShift = size(graph.nodeLabels, 1);
		graphEndIndexes(i, 1) = indexShift;
		if graph.nodeOrientedTask == false
			if size(currGraph.graphOutputIndexes, 1) > 1
				error('savegraph not implemented for merged graphs');
			end
			graphOutputIndexes(i) = indexShift + currGraph.graphOutputIndexes(1);
		end
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
	graph.graphOutputIndexes = graphOutputIndexes;
end
