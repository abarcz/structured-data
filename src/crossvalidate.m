
function [gnns trainEval testEval trainStats] = crossvalidate(gnn, graphs, nIterations, nFolds=10, classification=true, testname=0)
% Perform n-fold crossvalidation on cell of graphs
%
% usage: [gnns trainEval testEval trainStats] = crossvalidate(gnn, graphs, nIterations, nFolds=10, classification=true, testname=0)
%
% stats are result of evaluate() function:
% - (accuracy, precision, recall) for classification task
% - error values for approximation task
%

	nGraphs = size(graphs, 2);
	assert(nGraphs > 1);
	assert(nGraphs / nFolds == floor(nGraphs / nFolds));

	trainFraction = 1 - 1 / nFolds;
	nTrainGraphs = floor(nGraphs * trainFraction);
	nTestGraphs = nGraphs - nTrainGraphs;
	assert(nTrainGraphs > 0);
	assert(nTestGraphs > 0);

	if testname != 0
		filename = strcat(testname, '_main.mat');
		packedInitialGnn = presavegnn(gnn);
		save(filename, 'graphs', 'packedInitialGnn', 'nIterations', 'nFolds', 'nGraphs');
	end

	if classification
		testEval = zeros(nFolds, 3);
		trainEval = zeros(nFolds, 3);
	else
		assert(graphs{1}.nodeOrientedTask == false);	% for nodeOrientedTask not implemented
		testEval = zeros(nFolds, nTestGraphs);
		trainEval = zeros(nFolds, nTrainGraphs);
	end
	gnns = {};
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
		[trainedGnn trainStats] = traingnn(gnn, trainGraph, nIterations);
		gnns{i} = trainedGnn;

		trainOutputs = applygnn(trainedGnn, trainGraph);
		if classification
			trainEval(i, :) = evaluate(trainOutputs, getexpectedoutput(trainGraph));
		else
			trainEval(i, :) = getexpectedoutput(trainGraph)' - trainOutputs';
		end

		testGraph = mergegraphs(testGraphs);
		testOutputs = applygnn(trainedGnn, testGraph);
		if classification
			testEval(i, :) = evaluate(testOutputs, getexpectedoutput(testGraph));
		else
			testEval(i, :) = getexpectedoutput(testGraph)' - testOutputs';
		end
		timeElapsed = toc();

		if testname != 0
			filename = strcat(testname, sprintf('_fold%d.mat', i));
			currTrainEval = trainEval(i, :);
			currTestEval = testEval(i, :);
			packedTrainedGnn = presavegnn(trainedGnn);
			save(filename, 'packedTrainedGnn', 'trainStats', 'timeElapsed', 'currTrainEval', 'currTestEval', 'nIterations');
		end
	end
end
