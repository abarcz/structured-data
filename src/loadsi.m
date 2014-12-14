
function graphs = loadsi()

	datasets = {'../data/si/n8', '../data/si/n8V22m', '../data/si/n8V2m', '../data/si/n8V20', '../data/si/n8V2p'};
	nDatasets = size(datasets, 2);
	nGraphs = 10;
	startIndex = 1;
	currGraph = 1;
	graphs = {};
	for i = 1:nDatasets
		currGraphs = loadset(datasets{i}, nGraphs, startIndex);
		for j = 1:nGraphs
			graphs{currGraph} = currGraphs{j};
			currGraph = currGraph + 1;
		end
	end
end
