
function testparams2(nRounds, trainGraph, testGraph, nIterations, basename, contractionConstants, stateSizes, state)
%
% usage: testparams2(nRounds, trainGraph, testGraph, nIterations, basename, contractionConstants, stateSizes, state)
%

	assert(size(contractionConstants, 1) == 1);
	assert(size(stateSizes, 1) == 1);

	for k = 1:nRounds
		testname = strcat(basename, sprintf('_round%d', k));
		testparamsgnn2(trainGraph, testGraph, nIterations, testname, contractionConstants, stateSizes, state);
	end
end
