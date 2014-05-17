
function [fnn maxDiffs sumDiffs keys values] = trainraam2(fnn, cell, keys, values, nIterations)

	sumDiffs = zeros(1, nIterations);
	maxDiffs = zeros(1, nIterations);
	for i = 1:nIterations
		fnn = trainraam(fnn, cell, keys, values);
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
