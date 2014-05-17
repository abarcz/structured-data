
function code = raamencode(fnn, cell)
% encode single tree

	% {'A', 'D', 'N', 'P', 'V'};
	keys = {[1,0,0,0,0, 0,0,0,0,0], [0,1,0,0,0, 0,0,0,0,0], [0,0,1,0,0, 0,0,0,0,0], [0,0,0,1,0, 0,0,0,0,0], [0,0,0,0,1, 0,0,0,0,0]};
	values = {[1,0,0,0,0, 0,0,0,0,0], [0,1,0,0,0, 0,0,0,0,0], [0,0,1,0,0, 0,0,0,0,0], [0,0,0,1,0, 0,0,0,0,0], [0,0,0,0,1, 0,0,0,0,0]};

	maxDepth = treedepth(cell);
	for i = maxDepth:-1:1
		nodes = nodesatdepth(cell, i);
		for j = 1:size(nodes, 2)
			node = nodes{j};
			assert(size(node, 2) == 2);
			if cellcontains(keys, node)
				continue;
			end
			value1 = getdictvalue(keys, values, node{1});
			value2 = getdictvalue(keys, values, node{2});
			inputs = [value1, value2];
			code = applycoder(fnn, inputs);
			keys = {keys{:}, node};
			values = {values{:}, code};
		end
	end
end
