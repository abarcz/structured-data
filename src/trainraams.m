
function [fnns mds sds] = trainraams(cell, keys, values, nIterations, nRaams)

	fnns = {};
	mds = zeros(nRaams, nIterations);
	sds = zeros(nRaams, nIterations);
	for i = 1:nRaams
		fnn = initfnn(20, 10, 20);
		[fnn maxDiffs sumDiffs keys values] = trainraam2(fnn, cell, keys, values, nIterations);
		fnns{i} = fnn;
		mds(i, :) = maxDiffs;
		sds(i, :) = sumDiffs;
	end
end
