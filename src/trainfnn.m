
function fnn = trainfnn(fnn, inputs, expected, nEpochs, learningConstant)
% trains two-layer neural network
%
% usage: fnn = trainfnn(fnn, inputs, expected, nEpochs, learningConstant)
%
% each 'samples' row = [class sample]

	nSamples = size(inputs, 1);
	for i = 1:nEpochs
		outputs = applynet(fnn, inputs);
		errors = expected - outputs;
		for j = 1:nSamples
			input = inputs(j, :);
			err = errors(j, :);
			deltas = backpropagate(fnn, input, err);
			fnn = updateweights(fnn, deltas, learningConstant);
		end
	end
end
