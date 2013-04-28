
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

	edges = [];
	for i = 1:graph.nNodes
		for j = 1:graph.nNodes
			edgeLabel = graph.edgeLabels{i, j};
			if length(edgeLabel) != 0
				edgeLabel = [i, j, edgeLabel];
				edges = [edges; edgeLabel];
			end
		end
	end
	csvwrite(edgesFilename, edges);

	if length(graph.expectedOutput) != 0
		csvwrite(expectedOutputFilename, graph.expectedOutput);
	end
end
