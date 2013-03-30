
function [pos neg] = readstringdata(datasetName)
% Read palindrome dataset - both .pos and .neg files.
% append label at first column
% Example:
% 	[pos neg] = readpalin("palin_10")

	posFilename = strcat(datasetName, '.pos');
	negFilename = strcat(datasetName, '.neg');

	pos = readstringfile(posFilename);
	neg = readstringfile(negFilename);

	[pos neg] = simnormalize(pos, neg);

	pos = [repmat(1, size(pos, 1), 1) pos];
	neg = [repmat(2, size(neg, 1), 1) neg];
end

function data = readstringfile(filename)
	strings = textread(filename, '%s');
	nSamples = size(strings, 1);
	sampleSize = size(strings{1}, 2);

	data = zeros(nSamples, sampleSize);
	for i = 1:nSamples
		data(i, :) = toascii(strings{i});
	end
end
