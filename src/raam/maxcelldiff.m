
function maxDiff = maxcelldiff(cell1, cell2, saturate=0)
% Calculate max absolute difference between two corresponding elements of two trees of identical structure

	if !iscell(cell1)
		if iscell(cell2)
			error('compared two cells of different structure')
		end
		if saturate
			cell1 = max(0, min(1, cell1));
			cell2 = max(0, min(1, cell2));
		end
		maxDiff = max(abs(cell1 - cell2));
	else
		maxDiff = 0;
		for i = 1:size(cell1, 2)
			diff = maxcelldiff(cell1{i}, cell2{i}, saturate);
			if diff > maxDiff
				maxDiff = diff;
			end
		end
	end
end
