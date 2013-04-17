
function outputs = applynet(fnn, inputs)
% Apply given FNN to (non-biased) inputs

	% hidden layer feed
	netv = inputs * fnn.weights1 + fnn.bias1;
	zv = fnn.activation(netv);

	% visible layer feed
	netw = zv * fnn.weights2 + fnn.bias2;
	outputs = fnn.activation(netw);
end
