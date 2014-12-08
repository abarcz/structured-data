
function simakestats(gnn, filename)
% Create file containing results of approximation on all si datasets,
% using provided trained gnn. Stores results in filename

	datasets = {'../data/si/n8', '../data/si/n8V22m', '../data/si/n8V2m', '../data/si/n8V20', '../data/si/n8V2p'};
	nDatasets = size(datasets, 2);
	nGraphs = 10;
	nOutputs = 2;
	expected = zeros(nGraphs * nDatasets, nOutputs);
	results = zeros(nGraphs * nDatasets, nOutputs);
	for i = 1:5
		dataset = datasets{i};
		graph = mergegraphs(loadset(dataset, nGraphs));
		shift = nGraphs * (i - 1);
		expected((shift + 1):(shift + nGraphs), :) = graph.expectedOutput(graph.graphOutputIndexes, :);
		results((shift + 1):(shift + nGraphs), :) = applygnn(gnn, graph);
	end
	gnn = presavegnn(gnn);
	save(filename, 'datasets', 'expected', 'results', 'gnn');
end
