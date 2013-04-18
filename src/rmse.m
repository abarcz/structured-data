
function err = rmse(expected, actual)
% Calculate Root Mean Squared Error
%
% usage: err = rmse(expected, actual)
%
% expected, actual : each row represents a node output

	assert(size(expected) == size(actual));
	err = sqrt(sum(sum((expected - actual) .^ 2)));
end
