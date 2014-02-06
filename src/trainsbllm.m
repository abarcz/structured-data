
function [trainedFnn mse q nSaturated] = trainsbllm(fnn, inputs, outputs, nIterations)
% Train FNN using SBLLM method
%
% usage: [trainedFnn mse q nSaturated] = trainsbllm(fnn, inputs, outputs, nIterations)
%
% inputs - each row is a single sample (normalized)
% outputs - each row contains output for a single sample (normalized)

	z = initz(fnn, inputs);
	[trainedFnn mse q nSaturated] = sbllm(fnn, inputs, outputs, nIterations, z);
end
