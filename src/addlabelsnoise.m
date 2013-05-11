
function addlabelsnoise(basename, nGraphs, standardDeviation=0.25)
% Add Gaussian noise to graph node labels.
% Saves graphs in-place.
%
% usage: addlabelsnoise(basename, nGraphs, standardDeviation=0.25)
%

	for i = 1:nGraphs
		graphName = sprintf('%s_%d', basename, i);
		graph = loadgraph(graphName);
		graph.nodeLabels = addgaussian(graph.nodeLabels, standardDeviation);
		savegraph(graphName, graph);
	end
end
