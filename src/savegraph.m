
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
		if graph.nodeOrientedTask
			csvwrite(expectedOutputFilename, graph.expectedOutput);
		else
			if size(graph.graphOutputIndexes, 1) > 1
				error('savegraph not implemented for merged graphs');
			end
			csvwrite(expectedOutputFilename, graph.expectedOutput(1, :));
		end
	end
end
