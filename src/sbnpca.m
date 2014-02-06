
function [pc trainedFnn msei mseo] = sbnpca(data, nComponents, nHiddenNeurons, nIterations, nInputIt, check)
% Perform inverse NPCA using SBLLM
%
% usage: [pc trainedFnn msei mseo] = sbnpca(data, nComponents, nHiddenNeurons, nIterations, nInputIt, check)
%
% data - each row is a sample
%

	nSamples = size(data, 1);
	nInputs = size(data, 2);
	% an additional layer for calculating principal components values
	fnn0 = initfnn(nSamples, nComponents, nHiddenNeurons, 'tansig', 'purelin');
	fnn = initfnn(nSamples, nHiddenNeurons, nInputs);
	fnn.weights1 = fnn0.weights2 * fnn0.weights1;	% fnn0 serves as a single layer of fnn
	tfnn = initfnn(nComponents, nHiddenNeurons, nInputs);	% the result fnn

	t = eye(nSamples);	% inputs for fnn0
	z = initz(fnn, t);
	x = initz(fnn0, t);

	msei = zeros(nIterations, 1);
	mseo = zeros(nIterations, 1);
	for i = 1:nIterations
		[fnn mse q nSaturated z] = sbllm(fnn, t, data, 1, z);
		[fnn0 mse0 q0 nSaturated0 x] = sbllm(fnn0, t, z', nInputIt, x, false);

		tfnn.weights1 = fnn0.weights2;
		tfnn.bias1 = fnn0.bias2;
		tfnn.weights2 = fnn.weights2;
		tfnn.bias2 = fnn.bias2;
		outputs = applynet(tfnn, fnn0.weights1');
		msei(i) = sum(sum((check - fnn0.weights1) .^ 2));
		mseo(i) = sum(sum((data - outputs) .^ 2));
	end
	trainedFnn = tfnn;
	pc = fnn0.weights1';
end
