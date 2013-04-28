
function net = initfnn(nInputLines, nHiddenNeurons, nOutputNeurons, outputFun='purelin')
% Initialize weights of a three-layer FNN with logistic activation function.
% Each column of resulting matrices corresponds to a single neuron weights.
% Each neuron gets an extra weight for bias.
%
% usage: net = initfnn(nInputLines, nHiddenNeurons, nOutputNeurons, outputFun='purelin')
%
% nInputLines : number of input lines, script will add +1 for bias automatically

	if (strcmp(outputFun, 'purelin') == 0) && (strcmp(outputFun, 'tansig') == 0)
		error(sprintf('Unknown activation function: %s', outputFun));
	end

	weights1 = initializeweights(nInputLines, nHiddenNeurons);
	bias1 = initializeweights(1, nHiddenNeurons, nInputLines + 1);
	weights2 = initializeweights(nHiddenNeurons, nOutputNeurons);
	bias2 = initializeweights(1, nOutputNeurons, nHiddenNeurons + 1);

	net = struct(...
		'weights1', weights1, ...
		'bias1', bias1, ...
		'weights2', weights2, ...
		'bias2', bias2, ...
		'nInputLines', nInputLines, ...
		'nHiddenNeurons', nHiddenNeurons, ...
		'nOutputNeurons', nOutputNeurons, ...
		'activation1', @(x) tanh(x), ...
		'activationderivative1', @(x) repmat(1, size(x)) - (tanh(x) .^ 2), ...
		'activation2ndderivative1', @(x) 2 .* (tanh(x) .^ 3 - tanh(x)), ...
		'refuseVal', 0);

	if strcmp(outputFun, 'purelin') == 1
		net.activation2 = @(x) x;
		net.activationderivative2 = @(x) 1;
		net.activation2ndderivative2 = @(x) 0;
	else	% tansig
		net.activation2 = @(x) tanh(x);
		net.activationderivative2 = @(x) repmat(1, size(x)) - (tanh(x) .^ 2);
		net.activation2ndderivative2 = @(x) 2 .* (tanh(x) .^ 3 - tanh(x));
	end
end

function weights = initializeweights(nInputLines, nNeurons, factor=0)
	if factor == 0
		factor = nInputLines + 1;
	end
	% rand returns values uniformly distributed on (0, 1)
	weights = 2 .* (rand(nNeurons, nInputLines) - 0.5) ./ factor;
end
