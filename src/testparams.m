
function testparams(gnn, graph, nIterations, testname, contractionConstants, minDiffs)
	assert(size(contractionConstants, 1) == 1);
	assert(size(minDiffs, 1) == 1);

	mainFilename = strcat(testname, '.mat');
	save(mainFilename, 'gnn', 'graph', 'nIterations', 'contractionConstants', 'minDiffs');

	nContractionConstants = size(contractionConstants, 2);
	nMinDiffs = size(minDiffs, 2);
	timesElapsed = zeros(nContractionConstants, nMinDiffs);
	precisions = zeros(nContractionConstants, nMinDiffs);
	accuracies = zeros(nContractionConstants, nMinDiffs);
	recalls = zeros(nContractionConstants, nMinDiffs);
	for i = 1:nContractionConstants
		gnn.contractionConstant = contractionConstants(i);
		for j = 1:nMinDiffs
			gnn.minStateDiff = minDiffs(j);
			gnn.minErrorAccDiff = minDiffs(j);
			filename = strcat(testname, '_', sprintf('%d', i), '_', sprintf('%d', j), '.mat');

			tic();
			[gnn2 trainStats] = traingnn(gnn, graph, nIterations);
			evaluation = evaluate(classifygnn(gnn2, graph), graph.expectedOutput);
			timeElapsed = toc();

			save(filename, 'trainStats', 'gnn', 'timeElapsed', 'evaluation');
			timesElapsed(i, j) = timeElapsed;
			precisions(i, j) = evaluation(1);
			accuracies(i, j) = evaluation(2);
			recalls(i, j) = evaluation(3);
		end
	end
	% resave test stats with times added
	save(mainFilename, 'gnn', 'graph', 'nIterations', 'contractionConstants', 'minDiffs', 'timesElapsed', 'precisions', 'accuracies', 'recalls');
end
