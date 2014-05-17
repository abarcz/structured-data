
function [fnn maxDiffs sumDiffs keys values] = trainunfolded(fnn, cell, nIterations, learningConstant)
% Train given fnn as RAAM encoder+decoder using unfolded network
%
% usage: [fnn maxDiffs sumDiffs keys values] = trainunfolded(fnn, cell, nIterations, learningConstant)
%
% cell - original tree
% keys + values - initial encodings of nodes

	% encodings of {'A', 'D', 'N', 'P', 'V'};
	leafKeys = {[1,0,0,0,0, 0,0,0,0,0], [0,1,0,0,0, 0,0,0,0,0], [0,0,1,0,0, 0,0,0,0,0], [0,0,0,1,0, 0,0,0,0,0], [0,0,0,0,1, 0,0,0,0,0]};
	leafValues = {[1,0,0,0,0, 0,0,0,0,0], [0,1,0,0,0, 0,0,0,0,0], [0,0,1,0,0, 0,0,0,0,0], [0,0,0,1,0, 0,0,0,0,0], [0,0,0,0,1, 0,0,0,0,0]};

	sumDiffs = zeros(1, nIterations);
	maxDiffs = zeros(1, nIterations);
	for i = 1:nIterations
		[leafErrors keys values] = raamforward(fnn, cell, leafKeys, leafValues);
		fnn = raambackward(fnn, cell, leafErrors, keys, values, learningConstant);
		maxDiff = 0;
		sumDiff = 0;
		for j = 1:size(cell, 2)
			code = raamencode(fnn, cell{j});
			decodedCell = raamdecode(fnn, code, cell{j});
			diff = maxcelldiff(cell{j}, decodedCell);
			if diff > maxDiff
				maxDiff = diff;
			end
			sumDiff = sumDiff + sumcelldiff(cell{j}, decodedCell);
		end
		maxDiffs(i) = maxDiff;
		sumDiffs(i) = sumDiff;
	end
end
