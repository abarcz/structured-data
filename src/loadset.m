
function graphs = loadset(basename, nGraphs, startIndex=1)
% Load dataset consisting of graphs named <basename>_<graphNumber>,
% where graphNumber = startIndex..startIndex + nGraphs - 1
%
% usage: graphs = loadset(basename, nGraphs, startIndex=1)
%

	assert(nGraphs > 1);
	graphs = {};

	% load first graph
	graphName = sprintf('%s_%d', basename, startIndex);
	graph = loadgraph(graphName);
	graphs{1} = graph;
	endIndex = startIndex + nGraphs - 1;
	for i = (startIndex + 1):endIndex
		graphName = sprintf('%s_%d', basename, i);
		currGraph = loadgraph(graphName);
		% compare with the first graph
		assert(graph.nodeLabelSize == currGraph.nodeLabelSize);
		assert(graph.edgeLabelSize == currGraph.edgeLabelSize);
		assert(graph.nodeOutputSize == currGraph.nodeOutputSize);
		graphs{i - startIndex + 1} = currGraph;
	end
end
