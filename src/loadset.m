
function graphs = loadset(basename, nGraphs)
% Load dataset consisting of graphs named <basename>_<graphNumber>,
% where graphNumber = 1..nGraphs
%
% usage: graphs = loadset(basename, nGraphs)
%

	assert(nGraphs > 1);
	graphs = {};

	% load first graph
	graphName = sprintf('%s_%d', basename, 1);
	graph = loadgraph(graphName);
	graphs{1} = graph;
	for i = 2:nGraphs
		graphName = sprintf('%s_%d', basename, i);
		currGraph = loadgraph(graphName);
		% compare with the first graph
		assert(graph.nodeLabelSize == currGraph.nodeLabelSize);
		assert(graph.edgeLabelSize == currGraph.edgeLabelSize);
		assert(graph.nodeOutputSize == currGraph.nodeOutputSize);
		graphs{i} = currGraph;
	end
end
