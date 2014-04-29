
function res = cellcontains(cell1, cell2)
% Return 1 if cell1 contains cell2

	if !iscell(cell1) || !iscell(cell2)
		error('cellcontains used on non-cells')
	end
	res = 0;
	for i = 1:size(cell1, 2)
		if cellcompare(cell1{i}, cell2)
			res = 1;
			break;
		end
	end
end
