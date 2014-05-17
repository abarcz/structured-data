
function deltas = bpencoding(fnn, cell, hiddenErrors, keys, values)
% backpropagate errors through the unfolded encoding network

	if iscell(cell)
		inputs = forminput(keys, values, cell);
		deltasNode = bpencoder(fnn, inputs, hiddenErrors);
		inputErrors = deltasNode.deltaInputs;
		inputErrors1 = inputErrors(1:(fnn.nInputLines / 2));
		inputErrors2 = inputErrors((fnn.nInputLines / 2 + 1):fnn.nInputLines);
		deltas1 = bpencoding(fnn, cell{1}, inputErrors1, keys, values);
		deltas2 = bpencoding(fnn, cell{2}, inputErrors2, keys, values);
		childrenDeltas = adddeltas(deltas1, deltas2);
		deltas = adddeltas(deltasNode, childrenDeltas);
	else
		deltas = zerodeltas(fnn);
	end
end
