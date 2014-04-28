
function net = initfnn(nInputLines, nHiddenNeurons, nOutputNeurons, outputFun='purelin', hiddenFun='tansig')
% Initialize weights of a three-layer FNN with logistic activation function.
% Each column of resulting matrices corresponds to a single neuron weights.
% Each neuron gets an extra weight for bias.
% Changing hiddenFun to 'logsig' isn't currently supported by GNN.
%
% usage: net = initfnn(nInputLines, nHiddenNeurons, nOutputNeurons, outputFun='purelin', hiddenFun='tansig')
%
% nInputLines : number of input lines, script will add +1 for bias automatically
% nWeights : number of weights learned from data

	if (strcmp(outputFun, 'logsig') == 0) && (strcmp(outputFun, 'tansig') == 0) && (strcmp(outputFun, 'purelin') == 0)
		error(sprintf('Unknown output activation function: %s', outputFun));
	end
	if (strcmp(hiddenFun, 'logsig') == 0) && (strcmp(hiddenFun, 'tansig') == 0) && (strcmp(hiddenFun, 'purelin') == 0)
		error(sprintf('Unknown hidden activation function: %s', hiddenFun));
	end

	weights1 = initializeweights(nInputLines, nHiddenNeurons);
	bias1 = initializeweights(1, nHiddenNeurons, nInputLines);
	weights2 = initializeweights(nHiddenNeurons, nOutputNeurons);
	bias2 = initializeweights(1, nOutputNeurons, nHiddenNeurons);

	nWeights = size([vec(weights1); vec(bias1); vec(weights2); vec(bias2)], 1);

	net = struct(...
		'weights1', weights1, ...
		'bias1', bias1, ...
		'weights2', weights2, ...
		'bias2', bias2, ...
		'nInputLines', nInputLines, ...
		'nHiddenNeurons', nHiddenNeurons, ...
		'nOutputNeurons', nOutputNeurons, ...
		'nWeights', nWeights, ...
		'outputFun', outputFun, ...
		'hiddenFun', hiddenFun);

	net = postloadfnn(net);
end

function weights = initializeweights(nInputLines, nNeurons, factor=0)
	if factor == 0
		factor = nInputLines;
	end
	factor = 1;
	% rand returns values uniformly distributed on (0, 1)
	weights = (rand(nNeurons, nInputLines) - 0.5) ./ factor;
end
