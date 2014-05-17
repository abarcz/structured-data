
function [deltas hiddenErrors] = bpdecoding(fnn, cell, leafErrors, keys, values)
% backpropagate errors through the unfolded decoding network

	if iscell(cell)
		[deltas1 hiddenErrors1] = bpdecoding(fnn, cell{1}, leafErrors, keys, values);
		[deltas2 hiddenErrors2] = bpdecoding(fnn, cell{2}, leafErrors, keys, values);
		childrenDeltas = adddeltas(deltas1, deltas2);
		code = getdictvalue(keys, values, cell);
		[deltasNode hiddenErrors] = bpdecoder(fnn, code, [hiddenErrors1 hiddenErrors2]);
		deltas = adddeltas(deltasNode, childrenDeltas);
	else
		deltas = zerodeltas(fnn);
		index = cellindexof(keys, cell);
		hiddenErrors = leafErrors(index, :);
	end
end
