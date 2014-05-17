
function [keys values] = buildinitdict(cell)
% Builds an initial dictionary of codes - a code for each node of the binary tree
% Pollacks syntax encoding task.
%
% cell - syntax tree

	% encodings of {'A', 'D', 'N', 'P', 'V'};
	keys = {[1,0,0,0,0, 0,0,0,0,0], [0,1,0,0,0, 0,0,0,0,0], [0,0,1,0,0, 0,0,0,0,0], [0,0,0,1,0, 0,0,0,0,0], [0,0,0,0,1, 0,0,0,0,0]};
	values = {[1,0,0,0,0, 0,0,0,0,0], [0,1,0,0,0, 0,0,0,0,0], [0,0,1,0,0, 0,0,0,0,0], [0,0,0,1,0, 0,0,0,0,0], [0,0,0,0,1, 0,0,0,0,0]};

	maxDepth = treedepth(cell);
	for i = maxDepth:-1:2
		nodes = nodesatdepth(cell, i);
		for j = 1:size(nodes, 2)
			node = nodes{j};
			if cellcontains(keys, node)
				continue;
			end
			code = rand(1, 10);
			keys = {keys{:}, node};
			values = {values{:}, code};
		end
	end
end
