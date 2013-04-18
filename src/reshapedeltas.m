
function deltas = reshapedeltas(fnn, column)
% Inverse operation to vecdeltas(deltas)
% Given a single column of dF/dw weight deltas, builds struct
%
% usage: deltas = reshapedeltas(fnn, column)
%
% fnn : FNN for which the deltas were calculated with backpropagate()

	nWeights1 = fnn.nInputLines * fnn.nHiddenNeurons;
	nBias1 = fnn.nHiddenNeurons;
	nWeights2 = fnn.nOutputNeurons * fnn.nHiddenNeurons;
	nBias2 = fnn.nOutputNeurons;

	startX = 1;
	endX = nWeights1;
	deltaWeights1 = reshape(column(startX:endX), fnn.nHiddenNeurons, fnn.nInputLines);

	startX = endX + 1;
	endX = startX + nBias1 - 1;
	deltaBias1 = reshape(column(startX:endX), fnn.nHiddenNeurons, 1);

	startX = endX + 1;
	endX = startX + nWeights2 - 1;
	deltaWeights2 = reshape(column(startX:endX), fnn.nOutputNeurons, fnn.nHiddenNeurons);

	startX = endX + 1;
	deltaBias2 = reshape(column(startX:end), fnn.nOutputNeurons);

	deltas = struct(...
		'deltaWeights1', deltaWeights1,...
		'deltaBias1', deltaBias1,...
		'deltaWeights2', deltaWeights2,...
		'deltaBias2', deltaBias2,...
		'deltaInputs', zeros(1, fnn.nInputLines));
end
