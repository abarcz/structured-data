
function cell = cellappend(cell, item)
% Append item to the end of (1D) cellarray
%
% usage: cell = cellappend(cell, item)
%
	cell{max(size(cell)) + 1} = item;
end
