
function confusionMatrix = classifyfnn(fnn, samples)

	nSamples = size(samples, 1);

	labels = samples(:, 1);
	samples = samples(:, 2:end);

	nClasses = size(unique(labels), 1);
	refuseVal = fnn.refuseVal;

	outputs = applynet(fnn, samples);

	% octave calculates max from columns
	[values indexes] = max(outputs');
	indexes = indexes';
	values = values';

	% value given, when classifier is uncertain
	refuseVal = nClasses + 1;
	indexes(values <= 0) = refuseVal;

	confusionMatrix = zeros(nClasses, nClasses + 1);
	for i = 1:size(indexes, 1)
		expectedClass = labels(i, 1);
		predictedClass = indexes(i, 1);
		confusionMatrix(expectedClass, predictedClass) = ...
			confusionMatrix(expectedClass, predictedClass) + 1;
	end
end
