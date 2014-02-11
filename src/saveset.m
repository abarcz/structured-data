
function saveset(basename, graphs)
% Save all graphs from a cellarray to .csv files
% as basename<number>
%
% usage: saveset(basename, graphs)
%

	nGraphs = max(size(graphs));
	for i = 1:nGraphs
		graphName = sprintf('%s_%d', basename, i);
		savegraph(graphName, graphs{i});
	end
end
