
function siplotstats(filename)

	datasets = {'../data/si/n8', '../data/si/n8V22m', '../data/si/n8V2m', '../data/si/n8V20', '../data/si/n8V2p'};
	nDatasets = size(datasets, 2);
	nGraphs = 10;
	nOutputs = 2;
	data = load(filename);
	nRows = nDatasets;
	nCols = 2;
	count = 1;

	figure(1)
	for i = 1:nDatasets
		dataset = datasets{i};
		shift = nGraphs * (i - 1);
		expected = data.expected((shift + 1):(shift + nGraphs), :);
		results = data.results((shift + 1):(shift + nGraphs), :);
		subplot(nRows, nCols, count), hist(expected)
		count = count + 1;
		subplot(nRows, nCols, count), hist(results)
		count = count + 1;
	end
end
