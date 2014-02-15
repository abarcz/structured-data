
function testparamsgnn2(trainGraph, testGraph, nIterations, testname, contractionConstants, stateSizes, state)
%
% usage: testparamsgnn2(trainGraph, testGraph, nIterations, testname, contractionConstants, stateSizes, state)
%

	assert(size(contractionConstants, 1) == 1);
	assert(size(stateSizes, 1) == 1);

	mainFilename = strcat(testname, '.mat');
	save(mainFilename, 'trainGraph', 'nIterations', 'contractionConstants', 'stateSizes');

	nContractionConstants = size(contractionConstants, 2);
	nStateSizes = size(stateSizes, 2);
	timesElapsed = zeros(nContractionConstants, nStateSizes);
	precisions = zeros(nContractionConstants, nStateSizes);
	accuracies = zeros(nContractionConstants, nStateSizes);
	recalls = zeros(nContractionConstants, nStateSizes);
	for i = 1:nContractionConstants
		contractionConstant = contractionConstants(i);
		gnn.contractionConstant = contractionConstant;
		for j = 1:nStateSizes
			stateSize = stateSizes(j);

			gnn = initgnn(trainGraph, stateSize, [5 5], 'tansig');
			filename = strcat(testname, '_', sprintf('%d', i), '_', sprintf('%d', j), '.mat');

			tic();
			[gnn2 trainStats] = traingnn(gnn, trainGraph, nIterations, 200, 200, state);
			evaluationTrain = evaluate(classifygnn(gnn2, trainGraph, state), trainGraph.expectedOutput);
			evaluationTest = evaluate(classifygnn(gnn2, testGraph, state), testGraph.expectedOutput);
			timeElapsed = toc();

			packedGnn = presavegnn(gnn);
			save(filename, 'packedGnn', 'trainStats', 'timeElapsed', 'evaluationTrain', 'evaluationTest', 'contractionConstant', 'stateSize');
			timesElapsed(i, j) = timeElapsed;
			precisions(i, j) = evaluationTest(1);
			accuracies(i, j) = evaluationTest(2);
			recalls(i, j) = evaluationTest(3);
		end
	end
	% resave test stats with times added
	save(mainFilename, 'trainGraph', 'nIterations', 'contractionConstants', 'stateSizes', 'timesElapsed', 'precisions', 'accuracies', 'recalls');
end
