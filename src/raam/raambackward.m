
function fnn = raambackward(fnn, cell, leafErrors, keys, values, learningConstant)
% perform backpropagation on raam trees

	% Phase 1 backpropagate through the decoding networks
	deltas = zerodeltas(fnn);
	rootErrors = zeros(size(cell, 2), fnn.nHiddenNeurons);
	for j = 1:size(cell, 2)
		node = cell{j};
		[currDeltas hiddenErrors] = bpdecoding(fnn, node, leafErrors, keys, values);
		rootErrors(j, :) = hiddenErrors;
		deltas = adddeltas(deltas, currDeltas);
	end
	% Phase 2 backpropagate through the encoding networks
	for j = 1:size(cell, 2)
		node = cell{j};
		currDeltas = bpencoding(fnn, node, rootErrors(j, :), keys, values);
		deltas = adddeltas(deltas, currDeltas);
	end
	fnn = updateweights(fnn, deltas, learningConstant);
end
