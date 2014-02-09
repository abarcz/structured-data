
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
	fnn = initfnn(nComponents, nHiddenNeurons, nInputs);
	fnn.weights1 = fnn0.weights2;

	t = eye(nSamples);	% inputs for fnn0
	x = initz(fnn0, t);
	z = initz(fnn, x');

	msei = zeros(nIterations, 1);
	mseo = zeros(nIterations, 1);
	for i = 1:nIterations
		[fnn mse q nSaturated z] = sbllm(fnn, x', data, 10, z);
		[fnn0 mse0 q0 nSaturated0 x] = sbllm(fnn0, t, z', 10, x, false);

		outputs = applynet(fnn, fnn0.weights1');
		%msei(i) = sum(sum((check - fnn0.weights1) .^ 2));
		mseo(i) = sum(sum((data - outputs) .^ 2));
	end
	trainedFnn = fnn;
	pc = fnn0.weights1';
end
