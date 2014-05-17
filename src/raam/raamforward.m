
function [leafErrors keys values] = raamforward(fnn, cell, leafKeys, leafValues)
% perform forward phase on raam trees
%
% usage: [leafErrors keys values] = raamforward(fnn, cell, leafKeys, leafValues)
%

	keys = leafKeys;
	values = leafValues;

	% Phase 1 - encoding (up to root)
	for j = 1:size(cell, 2)
		root = cell{j};
		maxDepth = treedepth(root);
		for i = maxDepth:-1:1
			nodes = nodesatdepth(root, i);
			for j = 1:size(nodes, 2)
				node = nodes{j};
				if cellcontains(keys, node)
					continue;
				end
				assert(size(node, 2) == 2);
				inputs = forminput(keys, values, node);
				code = applycoder(fnn, inputs);	% encode the pair for a larger subtree
				keys = {keys{:}, node};
				values = {values{:}, code};
			end
		end
	end
	% Phase 3 - decode root representations down to leaves and sum up leaf errors
	leafErrors = zeros(size(leafKeys, 2), size(leafKeys{1}, 2));
	for j = 1:size(cell, 2)
		node = cell{j};
		code = getdictvalue(keys, values, node);
		decodedCell = raamdecode(fnn, code, node);
		maxDepth = treedepth(node);
		leaves = nodesatdepth(node, maxDepth);
		decodedLeaves = nodesatdepth(decodedCell, maxDepth);
		assert(size(leaves, 2) == size(decodedLeaves, 2));
		for i = 1:size(leaves, 2)
			leaf = leaves{i};
			decodedLeaf = decodedLeaves{i};
			for k = 1:2
				errors = 2 .* leaf{k} - decodedLeaf{k};
				index = cellindexof(keys, leaf{k});
				leafErrors(index, :) = leafErrors(index, :) + errors;
			end
		end
	end
end
