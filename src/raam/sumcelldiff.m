
function sumDiff = sumcelldiff(cell1, cell2)
% Calculate sum absolute difference between two corresponding elements of two trees of identical structure

	if !iscell(cell1)
		if iscell(cell2)
			error('compared two cells of different structure')
		end
		sumDiff = sum(abs(cell1 - cell2));
	else
		sumDiff = 0;
		for i = 1:size(cell1, 2)
			sumDiff = sumDiff + sumcelldiff(cell1{i}, cell2{i});
		end
	end
end
