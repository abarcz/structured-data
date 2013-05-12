
function stats = evaluate(output, expected)
% Evaluates classifier outputs
%
% usage: stats = evaluate(output, expected)
%
% output, expected - column vectors
% stats - accuracy, precision, recall

	assert(unique(expected) == [-1; 1]);
	assert(size(output, 1) == size(expected, 1));
	assert(size(output, 2) == size(expected, 2));

	output = sign(output);

	truePos = sum(output(expected == 1) == 1);
	falsePos = sum(output(expected == -1) == 1);

	trueNeg = sum(output(expected == -1) == -1);
	falseNeg = sum(output(expected == 1) == -1);

	precision = truePos / (truePos + falsePos);
	recall = truePos / (truePos + falseNeg);
	accuracy = (truePos + trueNeg) / size(expected, 1);

	stats = [accuracy, precision, recall];
end
