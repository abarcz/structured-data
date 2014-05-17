
function res = cellindexof(cell1, cell2)
% Return index of cell2 in cell1 or 0

	res = 0;
	for i = 1:size(cell1, 2)
		if cellcompare(cell1{i}, cell2)
			res = i;
			break;
		end
	end
end
