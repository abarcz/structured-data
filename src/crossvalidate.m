
function [gnns trainErrors testErrors] = crossvalidate(gnn, graphs, nIterations, nFolds=10)
% Perform n-fold crossvalidation on cell of graphs
%
% usage: [gnns trainErrors testErrors] = crossvalidate(gnn, graphs, nIterations, nFolds=10)
%

	nGraphs = size(graphs, 2);
	assert(nGraphs > 1);

	trainFraction = 1 - 1 / nFolds;
	nTrainGraphs = floor(nGraphs * trainFraction);
	nTestGraphs = nGraphs - nTrainGraphs;
	assert(nTrainGraphs > 0);
	assert(nTestGraphs > 0);

	testErrors = zeros(nFolds, 1);
	trainErrors = zeros(nFolds, nIterations);
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
		[trainedGnn gnnErrors] = traingnn(gnn, trainGraph, nIterations);
		trainErrors(i, :) = gnnErrors';
		gnns{1, size(gnns, 2) + 1} = trainedGnn;

		testGraph = mergegraphs(testGraphs);
		outputs = classifygnn(trainedGnn, testGraph);
		err = rmse(testGraph.expectedOutput, outputs);
		testErrors(i) = err;
	end
end
