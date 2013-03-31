
function confusionMatrix = classify(net, samples)

	nSamples = size(samples, 1);

	labels = samples(:, 1);
	samples = samples(:, 2:end);

	nClasses = size(unique(labels), 1);
	samples = addbias(samples);

	v = net.inputWeights;
	w = net.intraWeights;
	activation = net.activation;
	refuseVal = net.refuseVal;

	% hidden layer feed
	netv = samples * v;
	zv = addbias(activation(netv));

	% visible layer feed
	netw = zv * w;
	zw = activation(netw);

	% transpose, cause octave calculates max from columns
	[values indexes] = max(zw');
	indexes = indexes';
	values = values';

	% value given, when classifier is uncertain
	refuseVal = nClasses + 1;
	for i = 1:size(indexes, 1)
		if values(i, 1) <= 0
			indexes(i, 1) = refuseVal;
		end
	end

	confusionMatrix = zeros(nClasses, nClasses + 1);
	for i = 1:size(indexes, 1)
		expectedClass = labels(i, 1);
		predictedClass = indexes(i, 1);
		confusionMatrix(expectedClass, predictedClass) = ...
			confusionMatrix(expectedClass, predictedClass) + 1;
	end
end
