import numpy as np
from sklearn.metrics import mean_squared_error
import matplotlib.pyplot as plt
			

def plot_net(net, inputs, expected, index=0):
	plt.figure(1)
	plt.subplot(211)
	plt.plot(inputs, expected[:,index], '.')
	plt.subplot(212)
	plt.plot(inputs, net.apply(inputs)[:, index], '.')
	plt.show()

def rmse(expected, outputs):
	return np.sqrt(mean_squared_error(expected, outputs))

def mul_elementwise(a, b):
	if a.shape != b.shape:
		raise Exception("Cannot multiply element-wise shapes: %s with %s" % (a.shape, b.shape))
	shape = a.shape
	c = np.matrix(np.array(a) * np.array(b))
	c.reshape(shape)
	return c

def make_classification_results(labels):
	if labels.shape[1] != 1:
		raise Exception("Cannot classify if labels are wider than 1-element")
	unique = np.unique(labels)
	nValues = unique.size
	if set(unique) != set(range(nValues)):
		raise Exception("Can deal only with labels starting from zero and incremented by one, e.g. [0,1,2]")
	nSamples = labels.shape[0]
	results = np.matrix(np.zeros((nSamples, nValues)))
	for i in range(nSamples):
		label = int(labels[i, 0])
		results[i, label] = 1
	return results
