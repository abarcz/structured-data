
function [trainGraphs testGraphs] = loadcrystals(trainFraction, nGraphs)
% Loads ../data/crystalgen sets

	indexes = randperm(nGraphs);
	nTrain = floor(nGraphs * trainFraction);
	nTest = nGraphs - nTrain;
	setNames = {'tetrap', 'tetrai'};
	nSets = max(size(setNames));

	trainGraphs = {};
	testGraphs = {};
	lastTrainIndex = 0;
	lastTestIndex = 0;
	for i = 1:nSets
		graphs = loadset(sprintf('../data/crystalgen/%s', setNames{i}), nGraphs);
		newTrain = graphs(indexes(1:nTrain));
		for j = 1:nTrain
			trainGraphs{lastTrainIndex + j} = newTrain{j};
		end
		lastTrainIndex = lastTrainIndex + nTrain;
		newTest = graphs(indexes(nTrain + 1:nGraphs));
		for j = 1:nTest
			testGraphs{lastTestIndex + j} = newTest{j};
		end
		lastTestIndex = lastTestIndex + nTest;
	end

	% mix classes together
	newTrainIndexes = randperm(nTrain * nSets);
	trainGraphs = trainGraphs(newTrainIndexes);
	newTestIndexes = randperm(nTest * nSets);
	testGraphs = testGraphs(newTestIndexes);
end
