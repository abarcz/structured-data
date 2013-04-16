
function gnn = initgnn(maxIndegree, stateSize, nHiddenNeurons, nOutputNeurons, minStateDiff=0.001)
% Create a Graph Neural Network
%
% usage : gnn = initgnn(maxIndegree, stateSize, nHiddenNeurons, nOutputNeurons, minStateDiff=0.001)
%
% maxIndegree : max indegree of a node in graph
% stateSize : number of integers used for storing calculated state of a node, affects computational complexity by O(n^2)
% nHiddenNeurons : number of hidden neurons both for transition and output FNN, affects computational complexity by O(n)
% nOutputNeurons : number of output neurons for the output network
% minStateDiff : min difference between two state variables to treat the states as different

	nodeLabelSize = 1;
	edgeLabelSize = 1;
	% create nnet for calculating state
	nInputLines = nodeLabelSize + edgeLabelSize + stateSize;
	transitionNet = initfnn(nInputLines, nHiddenNeurons, stateSize);

	% create nnet for calculating output
	nInputLines = nodeLabelSize + stateSize;
	outputNet = initfnn(nInputLines, nHiddenNeurons, nOutputNeurons);

	gnn = struct(...
		'transitionNet', transitionNet,...
		'outputNet', outputNet,...
		'maxIndegree', maxIndegree,...
		'stateSize', stateSize,...
		'nodeLabelSize', nodeLabelSize,...
		'edgeLabelSize', edgeLabelSize,...
		'minStateDiff', minStateDiff);
end
