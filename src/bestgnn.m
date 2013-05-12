
function [gnns trainStats testStats initialTrainRmse] = bestgnn(graphs, nGnns, nInitialIterations, nIterations, nFolds)
%
% usage: [gnns trainStats testStats initialTrainRmse] = bestgnn(graphs, nGnns, nInitialIterations, nIterations, nFolds)
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
	end

	%[gnns trainStats testStats] = crossvalidate(bestGnn, graphs, nIterations, nFolds);
end
