
function graph = mergegraphs(graphs)
% Merge input cellarray of graphs to a single graph
%
% usage: graph = mergegraphs(graphs)
%

	graphs_num = size(graphs, 2);
	assert(graphs_num > 0);

	graph = graphs{1};
	for i = 2:graphs_num
		currGraph = graphs{i};
		assert(graph.nodeLabelSize == currGraph.nodeLabelSize);
		assert(graph.edgeLabelSize == currGraph.edgeLabelSize);
		assert(graph.nodeOutputSize == currGraph.nodeOutputSize);
		indexShift = size(graph.nodeLabels, 1);
		if currGraph.maxIndegree > graph.maxIndegree
			graph.maxIndegree = currGraph.maxIndegree
		end
		graph.nodeLabels = [graph.nodeLabels; currGraph.nodeLabels];
		graph.expectedOutput = [graph.expectedOutput; currGraph.expectedOutput];
		% add edgeLabels
		for i = 1:currGraph.nNodes
			for j = 1:currGraph.nNodes
				if length(currGraph.edgeLabels{i, j}) != 0
					graph.edgeLabels{i + indexShift, j + indexShift} = ...
						currGraph.edgeLabels{i, j};
				end
			end
		end
		% add sourceNodes
		for i = 1:currGraph.nNodes
			sourceNodes = currGraph.sourceNodes{i};
			sourceIndex = i + indexShift;
			if length(sourceNodes) != 0
				graph.sourceNodes{sourceIndex} = ...
					sourceNodes + repmat(indexShift, size(sourceNodes));
			end
		end
	end
	graph.nNodes = size(graph.nodeLabels, 1);
end
