
function res = transformdjia(samples)
% Transform Dow Jones index values for following days (day = row)
% to the form : row = day-5, day-4, day-3, day-2, day-1, current_day
% Resulting matrix has (nSamples - 5) rows.

	nSamples = size(samples, 1);
	assert(size(samples, 2) == 1);

	res = zeros(nSamples - 5, 6);
	for i = 6:nSamples
		for j = 0:5
			res(i - 5, 6 - j) = samples(i - j);
		end
	end
end
