
function testparams(nGnns, graph, nIterations, basename, contractionConstants, minDiffs)
	assert(size(contractionConstants, 1) == 1);
	assert(size(minDiffs, 1) == 1);

	for k = 1:nGnns
		testname = strcat(basename, sprintf('_gnn%d', k));
		gnn = initgnn(graph.maxIndegree, [5 5] [5 graph.nodeOutputSize], 'tansig');

		mainFilename = strcat(testname, '.mat');
		packedGnn = presavegnn(gnn);
		save(mainFilename, 'packedGnn', 'graph', 'nIterations', 'contractionConstants', 'minDiffs');

		nContractionConstants = size(contractionConstants, 2);
		nMinDiffs = size(minDiffs, 2);
		timesElapsed = zeros(nContractionConstants, nMinDiffs);
		precisions = zeros(nContractionConstants, nMinDiffs);
		accuracies = zeros(nContractionConstants, nMinDiffs);
		recalls = zeros(nContractionConstants, nMinDiffs);
		for i = 1:nContractionConstants
			contractionConstant = contractionConstants(i);
			gnn.contractionConstant = contractionConstant;
			for j = 1:nMinDiffs
				minStateDiff = minDiffs(j);
				minErrorAccDiff = minDiffs(j);

				gnn.minStateDiff = minDiffs(j);
				gnn.minErrorAccDiff = minDiffs(j);
				filename = strcat(testname, '_', sprintf('%d', i), '_', sprintf('%d', j), '.mat');

				tic();
				[gnn2 trainStats] = traingnn(gnn, graph, nIterations);
				evaluation = evaluate(classifygnn(gnn2, graph), graph.expectedOutput);
				timeElapsed = toc();

				save(filename, 'trainStats', 'timeElapsed', 'evaluation', 'contractionConstant', 'minStateDiff', 'minErrorAccDiff');
				timesElapsed(i, j) = timeElapsed;
				precisions(i, j) = evaluation(1);
				accuracies(i, j) = evaluation(2);
				recalls(i, j) = evaluation(3);
			end
		end
		% resave test stats with times added
		save(mainFilename, 'packedGnn', 'graph', 'nIterations', 'contractionConstants', 'minDiffs', 'timesElapsed', 'precisions', 'accuracies', 'recalls');
	end
end
