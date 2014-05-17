
function res = cellsum(cell)

	res = 0;
	for i = 1:size(cell, 2)
		res = res + sum(sum(cell{i}));
	end
end
