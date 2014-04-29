
function nodes = nodesatdepth(tree, depth)
% Returns list of nodes found at given depth
%
%usage:
%
	if !iscell(tree) || depth == 0
		nodes = {};
	elseif depth == 1
		nodes = {tree};
	else
		nodes = {};
		for i = 1:size(tree, 2)
			childNodes = nodesatdepth(tree{i}, depth - 1);
			if !isempty(childNodes)
				nodes = {nodes{:}, childNodes{:}};
			end
		end
	end
end
