
function res = treedepth(cell)
% Calculate depth of tree represented as cellarray
%
% usage: res = treedepth(cell)
%

	if isempty(cell)
		res = 0;
		return;
	end
	maxDepth = 1;
	for i = 1:size(cell, 2)
		if !iscell(cell{i})
			continue;
		end
		childDepth = treedepth(cell{i}) + 1;
		if childDepth > maxDepth
			maxDepth = childDepth;
		end
	end
	res = maxDepth;
end
