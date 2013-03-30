
function [trainSet testSet] = readmnistsets()
% read and normalize MNIST datasets

	fnames = { 'train-images.idx3-ubyte'; 'train-labels.idx1-ubyte';  't10k-images.idx3-ubyte'; 't10k-labels.idx1-ubyte' };

	[trainLabels trainSamples] = readmnist(fnames(1,1), fnames(2,1));
	[testLabels testSamples] = readmnist(fnames(3,1), fnames(4,1));

	trainLabels = trainLabels .+ 1;
	testLabels = testLabels .+ 1;

	[trainSamplesNorm testSamplesNorm] = simnormalize(trainSamples, testSamples);

	trainSet = [trainLabels trainSamplesNorm];
	testSet = [testLabels testSamplesNorm];
end
