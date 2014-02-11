function [tvec tlab tstv tstl] = readmnistall()
	fnames = { '../data/mnist/train-images.idx3-ubyte'; '../data/mnist/train-labels.idx1-ubyte';  '../data/mnist/t10k-images.idx3-ubyte'; '../data/mnist/t10k-labels.idx1-ubyte' };
	[tlab tvec] = readmnist(fnames(1,1), fnames(2,1));
	[tstl tstv] = readmnist(fnames(3,1), fnames(4,1));
end
