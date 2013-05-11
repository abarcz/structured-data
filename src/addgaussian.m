
function data = addgaussian(data, standardDeviation)
% Add Gaussian noise with given standard devation to data
%
% usage: data = addgaussian(data, standardDeviation)
%

	data = data + (randn(size(data)) .* standardDeviation);
end
