
function delta_zx = bp2(fnn, inputs, errors)
% Perform backpropagation

	% hidden layer feed
	netv = addbias(inputs) * fnn.inputWeights;
	zv = fnn.activation(netv);

	% visible layer feed
	netw = addbias(zv) * fnn.intraWeights;
	zw = fnn.activation(netw);

	% calculate delta_zw (for all visible neurons at once)
	outputErrors = errors;
	delta_zw = outputErrors .* fnn.activationderivative(zw);
	
	% calculate delta_zv (for all hidden neurons at once)
	% each row of intraWeights corresponds to single hidden neuron
	% each element of hiddenErrors corresponds to single hidden neuron (last element = bias)
	hiddenErrors = sum(fnn.intraWeights .* repmat(delta_zw, fnn.nHiddenNeurons + 1, 1), 2)';
	delta_zv = hiddenErrors(1, 1:end-1) .* fnn.activationderivative(zv);

	% calculate delta_zx (for all input neurons at once)
	inputErrors = sum(fnn.inputWeights .* repmat(delta_zv, fnn.nInputLines + 1, 1), 2)';
	delta_zx = inputErrors(1, 1:end-1);
end
