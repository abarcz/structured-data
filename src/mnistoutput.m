
function out = mnistoutput(labels, falsev=0, truev=1)
% Transform single-digit output into expected output

	nSamples = size(labels, 1);
	out = repmat(falsev, nSamples, 10);
	for i = 1:nSamples
		index = labels(i) + 1;
		out(i, index) = truev;
	end
end
