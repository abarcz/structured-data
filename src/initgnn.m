
function gnn = initgnn(maxNodeDegree, stateSize, nHiddenNeurons, nOutputNeurons)
% Create a Graph Neural Network

	edgeDirectionSize = 1;	% 1 for incoming edge, -1 for outgoing, 0 for bidirectional
	labelSize = 1;
	singleNodeInputSize = stateSize + edgeDirectionSize + labelSize;
	% create nnet for calculating state
	nInputLines = labelSize + maxNodeDegree * singleNodeInputSize;
	transitionNet = initfnn(nInputLines, nHiddenNeurons, stateSize);
	transitionNet.inputWeights = makeinputweightsequal(transitionNet.inputWeights,...
		labelSize, maxNodeDegree, singleNodeInputSize);

	% create nnet for calculating output
	nInputLines = stateSize + labelSize;
	outputNet = initfnn(nInputLines, nHiddenNeurons, nOutputNeurons);

	gnn = struct(...
		'transitionNet', transitionNet,...
		'outputNet', outputNet,...
		'maxNodeDegree', maxNodeDegree,...
		'stateSize', stateSize,...
		'labelSize', labelSize);
end

function inputWeights = makeinputweightsequal(inputWeights, labelSize, maxNodeDegree, singleNodeInputSize)
% Called on inputWeights of a neural network, assures that for each input node
% given hidden neuron has the same set of input weights

	bias = 1;
	assert(size(inputWeights, 1) == labelSize + (maxNodeDegree * singleNodeInputSize) + bias);
	nHiddenNeurons = size(inputWeights, 2);
	for j = 1:nHiddenNeurons
		startIndex = 1 + labelSize;
		endIndex = startIndex + singleNodeInputSize - 1;
		sourceWeights = inputWeights(startIndex:endIndex, j);
		for i = 1:(maxNodeDegree - 1)
			startIndex = endIndex + 1;
			endIndex = startIndex + singleNodeInputSize - 1;
			inputWeights(startIndex:endIndex, j) = sourceWeights;
		end
	end
end
