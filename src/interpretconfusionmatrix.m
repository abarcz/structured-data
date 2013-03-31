
function results = interpretconfusionmatrix(confusionMatrix)
% Interpret confusion matrix of a classifier.
% Last column should contain reject decisions.
% return : [correct errors reject]

	total = sum(sum(confusionMatrix));
	correct = trace(confusionMatrix) / total;
	errors = (total - trace(confusionMatrix) - sum(confusionMatrix(:, end))) / total;
	reject = sum(confusionMatrix(:, end)) / total;
	results = [correct errors reject];
end
