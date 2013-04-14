
function outputs = applynet(fnn, inputs)
% Apply given FNN to (non-biased) inputs

	inputs = addbias(inputs);

	% hidden layer feed
	netv = inputs * fnn.inputWeights;
	zv = addbias(fnn.activation(netv));

	% visible layer feed
	netw = zv * fnn.intraWeights;
	outputs = fnn.activation(netw);
end
