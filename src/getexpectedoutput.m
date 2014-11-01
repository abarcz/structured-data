
function output = getexpectedoutput(graph)

	if graph.nodeOrientedTask
		output = graph.expectedOutput;
	else
		output = graph.expectedOutput(graph.graphOutputIndexes, :);
	end
end
