
function [gnns trainStats testStats initialTrainRmse] = bestgnn(graphs, nGnns, nInitialIterations, nIterations, nFolds, testname)
%
% usage: [gnns trainStats testStats initialTrainRmse] = bestgnn(graphs, nGnns, nInitialIterations, nIterations, nFolds, testname)
%

	% select half of the graphs as training set for initial training
	initialTrainGraphs = {};
	nInitialGraphs = ceil(size(graphs, 2) / 2);
	for i = 1:nInitialGraphs
		initialTrainGraphs{i} = graphs{i};
	end

	gnns = {};
	graphsMerged = mergegraphs(graphs);
	initialTrainGraphsMerged = mergegraphs(initialTrainGraphs);
	initialTrainRmse = zeros(1, nGnns);
	bestRmse = Inf;
	for i = 1:nGnns
		gnn = initgnn(graphsMerged.maxIndegree, [5 5], [5 graphsMerged.nodeOutputSize], 'tansig');
		[trainedGnn trainStats] = traingnn(gnn, initialTrainGraphsMerged, nInitialIterations);
		rmse = trainStats(nInitialIterations, 1);
		initialTrainRmse(i) = rmse;
		if rmse < bestRmse
			bestRmse = rmse;
			bestGnn = gnn;	% select untrained gnn for correct future crossvalidate results
		end

		packedGnn = presavegnn(gnn);
		filename = strcat(testname, sprintf('_gnn%d', i));
		save(filename, 'packedGnn', 'trainStats', 'nInitialIterations');
	end

	[gnns trainStats testStats] = crossvalidate(bestGnn, graphs, nIterations, nFolds);
	filename = strcat(testname, '_best.mat');
	packedGnns = {};
	for i = 1:nFolds
		packedGnns{i} = presavegnn(gnns{i});
	end
	packedBestGnn = presavegnn(bestGnn);
	save(filename, 'packedGnns', 'packedBestGnn', 'graphs', 'trainStats', 'testStats', 'nIterations', 'nFolds', 'initialTrainRmse');
end
