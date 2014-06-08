
function [maxDiff sumDiff diffs] = evalraam(fnn, cell)

	maxDiff = 0;
	sumDiff = 0
	diffs = [];
	for j = 1:size(cell, 2)
		code = raamencode(fnn, cell{j});
		decodedCell = raamdecode(fnn, code, cell{j});
		diff = maxcelldiff(cell{j}, decodedCell, 1);
		if diff > maxDiff
			maxDiff = diff;
		end
		[diff currDiffs] = sumcelldiff(cell{j}, decodedCell, 1);
		sumDiff = sumDiff + diff;
		diffs = [diffs, currDiffs];
	end
end
