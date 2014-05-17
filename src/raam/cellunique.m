
function unique = cellunique(cell)
% Return unique elements of cell

	unique = {};
	for i = 1:size(cell, 2)
		if !cellcontains(unique, cell{i})
			unique = {unique{:}, cell{i}};
		end
	end
end
