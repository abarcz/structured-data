
function savegraph(graphName, graph)
% Save graph to .csv files:
% <graphName>_nodes.csv
% <graphName>_edges.csv
% <graphName>_output.csv if output exists in graph
%
% usage: savegraph(graphName, graph)
%

	nodesFilename = strcat(graphName, '_nodes.csv');
	edgesFilename = strcat(graphName, '_edges.csv');
	expectedOutputFilename = strcat(graphName, '_output.csv');

	csvwrite(nodesFilename , graph.nodeLabels);
	csvwrite(edgesFilename, graph.edgeLabels);

	if length(graph.expectedOutput) != 0
		csvwrite(expectedOutputFilename, graph.expectedOutput);
	end
end
