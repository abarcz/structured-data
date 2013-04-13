
function gnn = initgnn(maxIndegree, stateSize, nHiddenNeurons, nOutputNeurons, minStateDiff=0.001)
% Create a Graph Neural Network
%
% maxIndegree : max indegree of a node in graph
% stateSize : number of integers used for storing calculated state of a node, affects computational complexity by O(n^2)
% nHiddenNeurons : number of hidden neurons both for transition and output FNN, affects computational complexity by O(n)
% nOutputNeurons : number of output neurons for the output network
% minStateDiff : min difference between two state variables to treat the states as different

	labelSize = 1;
	singleNodeInputSize = stateSize + labelSize;
	% create nnet for calculating state
	nInputLines = labelSize + maxIndegree * singleNodeInputSize;
	transitionNet = initfnn(nInputLines, nHiddenNeurons, stateSize);
	transitionNet.inputWeights = makeinputweightsequal(transitionNet.inputWeights,...
		labelSize, maxIndegree, singleNodeInputSize);

	% create nnet for calculating output
	nInputLines = stateSize + labelSize;
	outputNet = initfnn(nInputLines, nHiddenNeurons, nOutputNeurons);

	gnn = struct(...
		'transitionNet', transitionNet,...
		'outputNet', outputNet,...
		'maxIndegree', maxIndegree,...
		'stateSize', stateSize,...
		'labelSize', labelSize,
		'minStateDiff', minStateDiff);
end

function inputWeights = makeinputweightsequal(inputWeights, labelSize, maxIndegree, singleNodeInputSize)
% Called on inputWeights of a neural network, assures that for each input node
% given hidden neuron has the same set of input weights

	bias = 1;
	assert(size(inputWeights, 1) == labelSize + (maxIndegree * singleNodeInputSize) + bias);
	nHiddenNeurons = size(inputWeights, 2);
	for j = 1:nHiddenNeurons
		startIndex = 1 + labelSize;
		endIndex = startIndex + singleNodeInputSize - 1;
		sourceWeights = inputWeights(startIndex:endIndex, j);
		for i = 1:(maxIndegree - 1)
			startIndex = endIndex + 1;
			endIndex = startIndex + singleNodeInputSize - 1;
			inputWeights(startIndex:endIndex, j) = sourceWeights;
		end
	end
end
