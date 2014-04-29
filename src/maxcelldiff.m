
function maxDiff = maxcelldiff(cell1, cell2)
% Calculate max absolute difference between two corresponding elements of two trees of identical structure

	if !iscell(cell1)
		if iscell(cell2)
			error('compared two cells of different structure')
		end
		maxDiff = abs(max(cell1 - cell2));
	else
		maxDiff = 0;
		for i = 1:size(cell1, 2)
			diff = maxcelldiff(cell1{i}, cell2{i});
			if diff > maxDiff
				maxDiff = diff;
			end
		end
	end
end
