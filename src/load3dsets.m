
function [trainGraph testGraph] = load3dsets(trainFraction, nGraphs)
% Loads ../data/3dsets sets

	indexes = randperm(nGraphs);
	nTrain = floor(nGraphs * trainFraction);
	nTest = nGraphs - nTrain;
	setNames = {'base', 'base2', 'plain', 'plaindel'};	% baseadd
	nSets = max(size(setNames));

	trainGraphs = {};
	testGraphs = {};
	for i = 1:nSets
		graphs = loadset(sprintf('../data/3dsets/%s', setNames{i}), nGraphs);
		trainGraphs{i} = mergegraphs(graphs(indexes(1:nTrain)));
		testGraphs{i} = mergegraphs(graphs(indexes(nTrain + 1:nGraphs)));
	end
	testGraph = mergegraphs(testGraphs);
	trainGraph = mergegraphs(trainGraphs);
end
