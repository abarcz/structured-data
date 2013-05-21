
function [gnns trainStats testStats initialTrainRmse] = bestgnn(graphs, nGnns, nInitialIterations, nIterations, nFolds, testname, state)
%
% usage: [gnns trainStats testStats initialTrainRmse] = bestgnn(graphs, nGnns, nInitialIterations, nIterations, nFolds, testname, state)
%
	gnns = {};
	graphsMerged = mergegraphs(graphs);
	initialTrainRmse = zeros(1, nGnns);
	bestRmse = Inf;
	for i = 1:nGnns
		tic();
		gnn = initgnn(graphsMerged.maxIndegree, [5 5], [5 graphsMerged.nodeOutputSize], 'tansig');
		[trainedGnn trainStats] = traingnn(gnn, graphsMerged, nInitialIterations, 200, 200, state);
		rmse = trainStats(nInitialIterations, 1);
		initialTrainRmse(i) = rmse;
		if rmse < bestRmse
			bestRmse = rmse;
			bestGnn = gnn;	% select untrained gnn for correct future crossvalidate results
		end

		packedGnn = presavegnn(gnn);
		time = toc();
		filename = strcat(testname, sprintf('_gnn%d', i), '.mat');
		save(filename, 'packedGnn', 'trainStats', 'nInitialIterations', 'time');
	end

	if nIterations != 0
		tic();
		[gnns trainStats testStats] = crossvalidate(bestGnn, graphs, nIterations, nFolds);
		time = toc();
		filename = strcat(testname, '_best.mat');
		packedGnns = {};
		for i = 1:nFolds
			packedGnns{i} = presavegnn(gnns{i});
		end
		packedBestGnn = presavegnn(bestGnn);
		save(filename, 'packedGnns', 'packedBestGnn', 'graphs', 'trainStats', 'testStats', 'nIterations', 'nFolds', 'initialTrainRmse', 'time');
	else
		mainFilename = strcat(testname, '_main.mat');
		save(mainFilename, 'graphs', 'initialTrainRmse');
	end
end
