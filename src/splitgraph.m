
function graphs = splitgraph(graph)
% Splits graph into cell of graphs,
% according to graph.graphEndIndexes
%
% usage: graphs = splitgraph(graph)
%

	graphsNum = size(graph.graphEndIndexes, 1);
	graphs = {};
	for k = 1:graphsNum
		indexShift = graph.graphEndIndexes(k);
		startX = indexShift + 1;
		if k < graphsNum
			endX = graph.graphEndIndexes(k + 1);
		else
			endX = size(graph.nodeLabels, 1);
		end
		% select nodes
		nodeLabels = graph.nodeLabels(startX:endX, :);
		% select output
		if length(graph.expectedOutput) != 0
			expectedOutput = graph.expectedOutput(startX:endX, :);
		else
			expectedOutput = [];
		end
		% select corresponding edges
		edgeLabels = graph.edgeLabels(graph.edgeLabels(:, 1) >= startX, :);
		edgeLabels = edgeLabels(edgeLabels(:, 1) <= endX, :);
		edgeLabels(:, 1:2) = edgeLabels(:, 1:2) - ...
			repmat(indexShift, size(edgeLabels(:, 1:2)));

		% check if all node labels in edges are correct
		nNodes = size(nodeLabels, 1);
		assert(isempty(setdiff(unique(edgeLabels(:, 1:2)), [1:nNodes])));

		maxIndegree = 0;
		for i = 1:nNodes
			indegree = sum(edgeLabels(:, 2) == i);
			if indegree > maxIndegree
				maxIndegree = indegree;
			end
		end

		nodeLabelSize = size(nodeLabels, 2);
		edgeLabelSize = size(edgeLabels(:, 3:end), 2);
		nodeOutputSize = size(expectedOutput, 2);
		currGraph = struct(...
			'nodeLabels', nodeLabels,...
			'expectedOutput', expectedOutput,...
			'edgeLabels', edgeLabels,...
			'nodeLabelSize', nodeLabelSize,...
			'edgeLabelSize', edgeLabelSize,...
			'nNodes', nNodes,...
			'maxIndegree', maxIndegree,...
			'nodeOutputSize', nodeOutputSize);
		graphs{k} = currGraph;
	end
end
