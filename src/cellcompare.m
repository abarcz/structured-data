
function equal = cellcompare(cell1, cell2)
% Return 1 if cellarrays are same (only for 1D cellarrays containing only row matrices or numbers or recursively cellarrays)

	if iscell(cell1)
		if iscell(cell2)
			if size(cell1, 1) != 1 || size(cell2, 1) != 1
				error('Cannot compare 2D cells')
			elseif size(cell1, 2) != size(cell2, 2)
				equal = 0;
			else
				equal = 1;
				for i = 1:size(cell1, 2)
					if cellcompare(cell1{i}, cell2{i}) == 0
						equal = 0;
						break;
					end
				end
			end
		else
			equal = 1;
		end
	else
		if iscell(cell2)
			equal = 0;
		else
			equal = (sum(sum(cell1 == cell2)) == size(cell1 == cell2, 2));
		end
	end
end
