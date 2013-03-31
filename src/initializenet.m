
function net = initializenet(nInputLines, nHiddenNeurons, nOutputNeurons)
% Initialize weights of a two-layer NN with logistic activation function.
% Each column of resulting matrices corresponds to a single neuron weights.
% Each neuron gets an extra weight for bias.
%
% [inputWeights intraWeights] = initializenet(nInputLines, nHiddenNeurons, nOutputNeurons)
% nInputLines : number of input lines, script will add +1 for bias automatically

	inputWeights = initializeweights(nInputLines, nHiddenNeurons);
	intraWeights = initializeweights(nHiddenNeurons, nOutputNeurons);

	net = struct(...
		"inputWeights", inputWeights, ...
		"intraWeights", intraWeights, ...
		"nInputLines", nInputLines, ...
		"nHiddenNeurons", nHiddenNeurons, ...
		"nOutputNeurons", nOutputNeurons, ...
		"activation", @(x) tanh(x), ...
		"activationderivative", @(fx) repmat(1, size(fx)) - (fx .^ 2), ...
		"refuseVal", 0);
end

function weights = initializeweights(nInputLines, nNeurons)
	bias = 1;
	nInputs = nInputLines + bias;
	% rand returns values uniformly distributed on (0, 1)
	weights = (rand(nInputs, nNeurons) - 0.5) .* (2 ./ nInputs);
end
