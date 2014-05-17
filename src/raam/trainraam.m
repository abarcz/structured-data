
function fnn = trainraam(fnn, cell, keys, values)

	maxDepth = treedepth(cell);
	inputs = [];
	for i = maxDepth:-1:2
		nodes = nodesatdepth(cell, i);
		for j = 1:size(nodes, 2)
			node = nodes{j};
			input = forminput(keys, values, node);
			inputs = [inputs; input];
		end
	end
	[fnn mse q nSaturated] = trainsbllm(fnn, inputs, inputs, 1);
end
