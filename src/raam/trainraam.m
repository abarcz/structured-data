
function [fnn maxDiffs sumDiffs keys values] = trainraam(fnn, cell, keys, values, nIterations, sbllm=1)
% Train given fnn as RAAM encoder+decoder
%
% usage: [fnn maxDiffs sumDiffs keys values] = trainraam(fnn, cell, keys, values, nIterations, sbllm=1)
%
% cell - original tree
% keys + values - initial encodings of nodes

	sumDiffs = zeros(1, nIterations);
	maxDiffs = zeros(1, nIterations);
	for i = 1:nIterations
		fnn = trainiteration(fnn, cell, keys, values, sbllm);
		[keys values] = buildcurrdict(fnn, cell, keys, values);
		codesSum = cellsum(values);
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
