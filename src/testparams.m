
function testparams(nGnns, graph, nIterations, basename, contractionConstants, minDiffs, state)
%
% usage: testparams(nGnns, graph, nIterations, basename, contractionConstants, minDiffs, state)
%

	assert(size(contractionConstants, 1) == 1);
	assert(size(minDiffs, 1) == 1);

	for k = 1:nGnns
		testname = strcat(basename, sprintf('_gnn%d', k));
		gnn = initgnn(graph.maxIndegree, [5 5], [5 graph.nodeOutputSize], 'tansig');
		testparamsgnn(gnn, graph, nIterations, testname, contractionConstants, minDiffs, state)
	end
end
