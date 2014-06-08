
function [sumDiff diffs] = sumcelldiff(cell1, cell2, saturate=0)
% Calculate sum absolute difference between two corresponding elements of two trees of identical structure

	if !iscell(cell1)
		if iscell(cell2)
			error('compared two cells of different structure')
		end
		if saturate
			cell1 = max(0, min(1, cell1));
			cell2 = max(0, min(1, cell2));
		end
		diffs = abs(cell1 - cell2);
		sumDiff = sum(diffs);
	else
		sumDiff = 0;
		diffs = [];
		for i = 1:size(cell1, 2)
			[diff currDiffs] = sumcelldiff(cell1{i}, cell2{i}, saturate);
			sumDiff = sumDiff + diff;
			diffs = [diffs, currDiffs];
		end
	end
end
