
function [trainEval testEval] = crossvalidatefnn(fnn, graphs, nFolds=10)
% Perform n-fold crossvalidation on cell of graphs
%
% usage: [trainEval testEval] = crossvalidatefnn(fnn, graphs, nFolds=10)
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

	testEval = zeros(nFolds, 3);
	trainEval = zeros(nFolds, 3);
	for i = 1:nFolds
		tic();
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
		[normalized means stds] = normalize(trainGraph.nodeLabels);
		trainSamples = normalized';
		trainLabels = trainGraph.expectedOutput';

		trainedFnn = train(fnn, trainSamples, trainLabels);
		trainOutputs = sim(trainedFnn, trainSamples);
		trainEval(i, :) = evaluate(trainOutputs', trainLabels');

		testGraph = mergegraphs(testGraphs);
		normalized = normalize(testGraph.nodeLabels, means, stds);
		testSamples = normalized';
		testLabels = testGraph.expectedOutput';

		testOutputs = sim(trainedFnn, testSamples);
		testEval(i, :) = evaluate(testOutputs', testLabels');
		timeElapsed = toc();
	end
end
