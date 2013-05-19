
function combined = combinestats(dataCell, columnIndexes)
% From each data matrix in dataCell, get columns listed in columnIndexes vector (row)
% return: [data1index2; data1index2; ....; dataNindexM]
%
% usage: combined = combinestats(dataCell, columnIndexes)
%

	assert(size(columnIndexes, 1) == 1);
	nCols = size(columnIndexes, 2);
	nCells = max(size(dataCell));
	assert(nCells > 0);
	nRows = size(dataCell{1}, 1);
	combined = zeros(nRows, nCols * nCells);
	for i = 1:nCells
		data = dataCell{i};
		for j = 1:nCols
			columnIndex = columnIndexes(j);
			combined(:, (i - 1) * nCols + j) = data(:, columnIndex);
		end
	end
end
