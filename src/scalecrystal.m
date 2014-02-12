
function graph = scalecrystal(graph, a, b, c)
% Scale a crystal using a,b,c as scaling multipliers
%
% usage: graph = scalecrystal(graph, a, b, c)
%

	for i = 1:graph.nEdges
		graph.edgeLabels(i, 3) = graph.edgeLabels(i, 3) * a;
		graph.edgeLabels(i, 4) = graph.edgeLabels(i, 4) * b;
		graph.edgeLabels(i, 5) = graph.edgeLabels(i, 5) * c;
	end
end
