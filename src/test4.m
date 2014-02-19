
function test4(graphs, nGnns, nIterations, testname)
%
% usage: test4(graphs, nGnns, nIterations, testname)
%

	graph = mergegraphs(graphs);
	for i = 1:nGnns
		tic();
		gnn = initgnn(graph, 10, [10 10], 'tansig');
		gnn.contractionConstant = 19;
		[gnn stats] = traingnn(gnn, graph, nIterations);
		evalStats = evaluate(classifygnn(gnn, graph), graph.expectedOutput);

		packedGnn = presavegnn(gnn);
		time = toc();
		filename = strcat(testname, sprintf('_gnn%d', i), '.mat');
		save(filename, 'packedGnn', 'stats', 'evalStats', 'time', 'graphs');
	end
end
