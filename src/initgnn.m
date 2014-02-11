
function gnn = initgnn(graph, stateSize, nHiddenNeurons, outputFun='purelin', minStateDiff=0.00000001, minErrorAccDiff=0.00000001, contractionConstant=0.9)
% Create a Graph Neural Network
%
% usage: gnn = initgnn(graph, stateSize, nHiddenNeurons, outputFun='purelin', minStateDiff=0.00000001, minErrorAccDiff=0.00000001, contractionConstant=0.9)
%
% graph: used to determine node and edge label sizes, max indegree and output size
% stateSize : number of integers used for storing calculated state of a node, affects computational complexity by O(n^2)
% nHiddenNeurons : [nTransition, nOutput] number of hidden neurons for transition and output FNN, affects computational complexity by O(n)
% outputFun : type of gnn output activation function, can be 'tansig' or 'purelin'
% minStateDiff : min difference between two global states (representing all nodes) to treat them as different
% minErrorAccDiff : min difference between two de/dx accumulator variables to treat them as different
% contractionConstant : in (0, 1), constant used in the penalty, assuring that the transition is a contraction map
% nWeights : number of weights learned from data

	if (strcmp(outputFun, 'purelin') == 0) && (strcmp(outputFun, 'tansig') == 0)
		error(sprintf('Unknown activation function: %s', outputFun));
	end
	assert(size(nHiddenNeurons, 1) == 1);
	assert(size(nHiddenNeurons, 2) == 2);
	assert(minStateDiff > 0);
	assert(contractionConstant > 0);
	assert(contractionConstant < 1);

	nodeLabelSize = graph.nodeLabelSize;
	edgeLabelSize = graph.edgeLabelSize;
	maxIndegree = graph.maxIndegree;
	outputSize = graph.nodeOutputSize;
	% create nnet for calculating state
	nInputLines = nodeLabelSize + edgeLabelSize + stateSize;
	transitionNet = initfnn(nInputLines, nHiddenNeurons(1), stateSize, 'tansig');

	% create nnet for calculating output
	outputNet = initfnn(stateSize, nHiddenNeurons(2), outputSize, outputFun);

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
		'contractionConstant', contractionConstant,...
		'nWeights', outputNet.nWeights + transitionNet.nWeights);
end
