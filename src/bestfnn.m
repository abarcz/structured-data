
function [trainEval testEval fnn] = bestfnn(graphs, nFolds, nFnns, testname=0)
% Returns results of best fnn crossvalidation (best mean result on training) out of 10 random ones
%
% usage: [trainEval testEval fnn] = bestfnn(graphs, nFolds, nFnns, testname=0)
%

	graph = mergegraphs(graphs);
	[normalized means stds] = normalize(graph.nodeLabels);
	samples = normalized';
	pr = [min(samples) max(samples)];

	bestResult = -Inf;
	trainEval = [];
	testEval = [];
	fnn = [];
	for i = 1:nFnns
		currFnn = newff(pr, [20 1], {'tansig', 'purelin'});
		[currTrainEval currTestEval] = crossvalidatefnn(currFnn, graphs, nFolds);
		result = mean(mean(currTrainEval));
		if result > bestResult
			bestResult = result;
			trainEval = currTrainEval;
			testEval = currTestEval;
			fnn = currFnn;
		end
	end
	if testname != 0
		filename = strcat(testname, '.mat');
		save(filename, 'trainEval', 'testEval', 'fnn', 'nFolds', 'graphs');
	end
end
