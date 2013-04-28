
function [gnns trainStats testStats] = crossvalidate(gnn, graphs, nIterations, nFolds=10)
% Perform n-fold crossvalidation on cell of graphs
%
% usage: [gnns trainStats testStats] = crossvalidate(gnn, graphs, nIterations, nFolds=10)
%
% stats are result of evaluate() function (accuracy, precision, recall)
%

	nGraphs = size(graphs, 2);
	assert(nGraphs > 1);
	assert(nGraphs / nFolds == floor(nGraphs / nFolds));

	trainFraction = 1 - 1 / nFolds;
	nTrainGraphs = floor(nGraphs * trainFraction);
	nTestGraphs = nGraphs - nTrainGraphs;
	assert(nTrainGraphs > 0);
	assert(nTestGraphs > 0);

	testStats = zeros(nFolds, 3);
	trainStats = zeros(nFolds, 3);
	gnns = {};
	for i = 1:nFolds
		testStartX = 1 + (i - 1) * nTestGraphs;
		testEndX = testStartX + nTestGraphs - 1;
		trainGraphs = {};
		testGraphs = {};
		for j = 1:(testStartX - 1)
			trainGraphs{size(trainGraphs, 2) + 1} = graphs{j};
		end
		for j = testStartX:testEndX
			testGraphs{size(testGraphs, 2) + 1} = graphs{j};
		end
		for j = (testEndX + 1):size(graphs, 2)
			trainGraphs{size(trainGraphs, 2) + 1} = graphs{j};
		end
		trainGraph = mergegraphs(trainGraphs);
		trainedGnn = traingnn(gnn, trainGraph, nIterations);
		gnns{1, size(gnns, 2) + 1} = trainedGnn;

		trainOutputs = classifygnn(trainedGnn, trainGraph);
		trainStats(i, :) = evaluate(trainOutputs, trainGraph.expectedOutput);

		testGraph = mergegraphs(testGraphs);
		testOutputs = classifygnn(trainedGnn, testGraph);
		testStats(i, :) = evaluate(testOutputs, testGraph.expectedOutput);
	end
end
