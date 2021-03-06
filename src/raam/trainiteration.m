
function fnn = trainiteration(fnn, cell, keys, values, sbllm)
% Single iteration of RAAM training
%
% usage: fnn = trainiteration(fnn, cell, keys, values, sbllm)
%
% cell - original tree
% keys + values - current encodings of nodes

	% build encodings starting from leaves and going one level up in each iteration
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
	if sbllm
		[fnn mse q nSaturated] = trainsbllm(fnn, inputs, inputs, 1);
	else
		fnn = trainfnn(fnn, inputs, inputs, 1, 0.7);
	end
end
