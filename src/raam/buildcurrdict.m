
function [newKeys newValues] = buildcurrdict(fnn, cell, keys, values)
% Builds a dictionary of codes - a code for each node of the binary tree
% Pollacks syntax encoding task.
%
% fnn - RAAM coder + decoder network
% cell - syntax tree
% keys + values - encodings used in previous RAAM training step

	% {'A', 'D', 'N', 'P', 'V'};
	newKeys = {[1,0,0,0,0, 0,0,0,0,0], [0,1,0,0,0, 0,0,0,0,0], [0,0,1,0,0, 0,0,0,0,0], [0,0,0,1,0, 0,0,0,0,0], [0,0,0,0,1, 0,0,0,0,0]};
	newValues = {[1,0,0,0,0, 0,0,0,0,0], [0,1,0,0,0, 0,0,0,0,0], [0,0,1,0,0, 0,0,0,0,0], [0,0,0,1,0, 0,0,0,0,0], [0,0,0,0,1, 0,0,0,0,0]};

	maxDepth = treedepth(cell);
	for i = maxDepth:-1:2
		nodes = nodesatdepth(cell, i);
		for j = 1:size(nodes, 2)
			node = nodes{j};
			if cellcontains(newKeys, node)
				continue;
			end
			assert(size(node, 2) == 2);
			value1 = getdictvalue(keys, values, node{1});
			value2 = getdictvalue(keys, values, node{2});
			inputs = [value1, value2];
			code = applycoder(fnn, inputs);
			newKeys = {newKeys{:}, node};
			newValues = {newValues{:}, code};
		end
	end
end
