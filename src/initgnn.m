
function gnn = initgnn(maxIndegree, stateSize, nHiddenNeurons, nOutputNeurons, minStateDiff=0.00001, minErrorAccDiff=0.00001, contractionConstant=0.1)
% Create a Graph Neural Network
%
% usage: gnn = initgnn(maxIndegree, stateSize, nHiddenNeurons, nOutputNeurons, minStateDiff=0.00001, minErrorAccDiff=0.00001, contractionConstant=0.1)
%
% maxIndegree : max indegree of a node in graph
% stateSize : number of integers used for storing calculated state of a node, affects computational complexity by O(n^2)
% nHiddenNeurons : number of hidden neurons both for transition and output FNN, affects computational complexity by O(n)
% nOutputNeurons : number of output neurons for the output network
% minStateDiff : min difference between two global states (representing all nodes) to treat them as different
% minErrorAccDiff : min difference between two de/dx accumulator variables to treat them as different
% contractionConstant : in (0, 1), constant used in the penalty, assuring that the transition is a contraction map

	assert(minStateDiff > 0);
	assert(contractionConstant > 0);
	assert(contractionConstant < 1);

	nodeLabelSize = 1;
	edgeLabelSize = 1;
	% create nnet for calculating state
	nInputLines = nodeLabelSize + edgeLabelSize + stateSize;
	transitionNet = initfnn(nInputLines, nHiddenNeurons, stateSize);

	% create nnet for calculating output
	nInputLines = stateSize;
	outputNet = initfnn(nInputLines, nHiddenNeurons, nOutputNeurons);

	% divide by additional factor, because inputs = fw = maxIn * hw
	outputNet.weights1 = outputNet.weights1 ./ maxIndegree;

	gnn = struct(...
		'transitionNet', transitionNet,...
		'outputNet', outputNet,...
		'maxIndegree', maxIndegree,...
		'stateSize', stateSize,...
		'nodeLabelSize', nodeLabelSize,...
		'edgeLabelSize', edgeLabelSize,...
		'minStateDiff', minStateDiff,...
		'minErrorAccDiff', minErrorAccDiff,...
		'contractionConstant', contractionConstant);
end
