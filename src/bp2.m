
function delta_zx = bp2(fnn, inputs, errors)
% Perform backpropagation

	% hidden layer feed
	netv = inputs * fnn.weights1 + fnn.bias1;
	zv = fnn.activation(netv);

	% visible layer feed
	netw = zv * fnn.weights2 + fnn.bias2;
	zw = fnn.activation(netw);

	% calculate delta_zw (for all visible neurons at once)
	outputErrors = errors;
	delta_zw = outputErrors .* fnn.activationderivative(zw);
	
	% calculate delta_zv (for all hidden neurons at once)
	% each row of weights2 corresponds to single hidden neuron
	% each element of hiddenErrors corresponds to single hidden neuron
	hiddenErrors = sum(fnn.weights2 .* repmat(delta_zw, fnn.nHiddenNeurons, 1), 2)';
	delta_zv = hiddenErrors(1, 1:end) .* fnn.activationderivative(zv);

	% calculate delta_zx (for all input neurons at once)
	inputErrors = sum(fnn.weights1 .* repmat(delta_zv, fnn.nInputLines, 1), 2)';
	delta_zx = inputErrors(1, 1:end);
end
