import numpy as np
import scipy.linalg as linalg
from sklearn.metrics import mean_squared_error
import matplotlib.pyplot as plt

def plot_net(net, inputs, expected, index=0):
	plt.figure(1)
	plt.subplot(211)
	plt.plot(inputs, expected[:,index], '.')
	plt.subplot(212)
	plt.plot(inputs, net.apply(inputs)[:, index], '.')
	plt.show()

def testme():
	print "test"
	return 1

def rmse(expected, outputs):
	return np.sqrt(mean_squared_error(expected, outputs))

def init_weights(nInputLines, nNeurons, factor=1):
	if factor is None:
		factor = nInputLines
	# random.rand returns values distributed uniformly on [0, 1)
	weights = np.matrix((np.random.rand(nNeurons, nInputLines) - 0.5) / factor)
	return weights

def mul_elementwise(a, b):
	if a.shape != b.shape:
		raise Exception("Cannot multiply element-wise shapes: %s with %s" % (a.shape, b.shape))
	shape = a.shape
	c = np.matrix(np.array(a) * np.array(b))
	c.reshape(shape)
	return c

class Layer():
	KNOWN_FUNCTIONS = ['purelin', 'tansig']

	def __init__(self, nInputLines, nNeurons, activationFun):
		if not activationFun in self.KNOWN_FUNCTIONS:
			raise Exception('Unknown activation function: ' + str(activationFun))
		self.nNeurons = nNeurons
		self.nInputLines = nInputLines
		self.weights = init_weights(nNeurons, nInputLines)
		self.bias = init_weights(nNeurons, 1)
		self.activationFunName = activationFun
		if activationFun == 'purelin':
			self.activationFun = lambda x: x
			self.activationFun1d = lambda x: np.ones(x.shape)
			self.activationFun2d = lambda x: np.zeros(x.shape)
		elif activationFun == 'tansig':
			self.activationFun = np.tanh
			self.activationFun1d = lambda x: np.ones(x.shape) - np.power(np.tanh(x), 2)
			self.activationFun2d = lambda x: 2 * (np.power(np.tanh(x), 3) - np.tanh(x))
		else:
			raise Exception("Unknown activation function (shouldn't get there): " + str(activationFun))

	def __str__(self):
		string = "Neural network layer with activation function: " + str(self.activationFunName)
		string = string + "\nweights:\n"
		string = string + str(self.weights)
		string = string + "\nbias:\n"
		string = string + str(self.bias)
		return string

	def apply(self, inputs):
		if not type(inputs) is np.matrix:
			raise Exception('Layer.apply() used on sth different than numpy.matrix: ' + str(type(inputs)))
		net = self._calc_net(inputs)
		output = self.activationFun(net)
		#print "output"
 		#print output
		return output

	def _calc_net(self, inputs):
		#print "inputs"
		#print inputs
		#print str(inputs.shape)
		#print "weights"
		#print str(self.weights.shape)
		dot = inputs * self.weights
		#print "dot"
		#print dot
		#print dot.shape
		#print self.bias.shape
		bias = np.tile(self.bias, (dot.shape[0], 1))
		#print bias
		net = dot + bias
		#print "net"
		#print net
		return net

	def calc_deltas(self, inputs, errors):
		net = self._calc_net(inputs)
		#print "inputs.shape"
		#print inputs.shape
		#print "net.shape"
		#print net.shape
		#print "errors.shape"
		#print errors.shape
		biasDeltas = mul_elementwise(errors, self.activationFun1d(net))
		#print "biasdeltas.shape"
		#print biasDeltas.shape
		weightDeltas = (biasDeltas.transpose() * inputs).transpose()
		#print "weightDeltas.shape"
		#print weightDeltas.shape
		#print "self.weights.trranspose.shape"
		#print self.weights.transpose().shape
		inputErrors = biasDeltas * self.weights.transpose()
		#print "inputErrors shape"
		#print inputErrors.shape
		return LayerDeltas(weightDeltas, biasDeltas, inputErrors)

	def update_weights(self, deltas, learningConstant):
		self.weights = self.weights + (deltas.weightDeltas * learningConstant)
		self.bias = self.bias + (deltas.biasDeltas * learningConstant)


class LayerDeltas():
	def __init__(self, weightDeltas=None, biasDeltas=None, inputErrors=None):
		# LayerDeltas can be either null or fully initialized
		if inputErrors is None:
			if (weightDeltas is None) or (biasDeltas is None):
				raise Exception("LayerDeltas cannot be partially initialized")
		self.weightDeltas = weightDeltas
		self.biasDeltas = biasDeltas
		self.inputErrors = inputErrors

	def __add__(self, other):
		# null element + other = other
		if self.weightDeltas is None:
			return other
		return LayerDeltas(self.weightDeltas + other.weightDeltas, self.biasDeltas + other.biasDeltas, self.inputErrors + other.inputErrors)
			

class Net():

	def __init__(self, nInputLines, nHiddenNeurons, nOutputNeurons, hiddenFun='tansig', outputFun='purelin'):
		self.hiddenLayer = Layer(nInputLines, nHiddenNeurons, hiddenFun)
		self.outputLayer = Layer(nHiddenNeurons, nOutputNeurons, outputFun)

	def __str__(self):
		string = "Neural network with layers:\n\nhidden:\n"
		string = string + str(self.hiddenLayer)
		string = string + "\n\noutput:\n"
		string = string + str(self.outputLayer)
		return string

	def apply(self, inputs):
		hiddenOutputs = self.hiddenLayer.apply(inputs)
		outputs = self.outputLayer.apply(hiddenOutputs)
		return outputs

	def train(self, inputs, expected, nEpochs, learningConstant):
		nSamples = inputs.shape[0]
		print "nSamples"
		print nSamples
		for i in range(nEpochs):
			outputs = self.apply(inputs)
#			print "outputs"
#			print outputs
			errors = expected - outputs
			print errors.sum()
			deltas1Acc = LayerDeltas()
			deltas2Acc = LayerDeltas()
			for j in range(nSamples):
				input = inputs[j, :]
				error = errors[j, :]
				#print input
				#print error
				(deltas1, deltas2) = self.backpropagate(input, error)
				deltas1Acc = deltas1Acc + deltas1
				deltas2Acc = deltas2Acc + deltas2
			self.hiddenLayer.update_weights(deltas1Acc, learningConstant)
			self.outputLayer.update_weights(deltas2Acc, learningConstant)

	def backpropagate(self, inputs, errors):
		#print inputs
		#print "inputs to calcdelta2"
		hiddenOutputs = self.hiddenLayer.apply(inputs)
		#print hiddenOutputs
		#print "errors to calcdelta2"
		#print errors
		deltas2 = self.outputLayer.calc_deltas(hiddenOutputs, errors)
		#print "inputs to calcdelta1"
		#print inputs
		#print "errors to calcdelta1"
		#print deltas2.inputErrors
		deltas1 = self.hiddenLayer.calc_deltas(inputs, deltas2.inputErrors)
		return (deltas1, deltas2)

	def params_per_output(self):
		nParamsPerOutput = (self.hiddenLayer.nInputLines + 2) * self.hiddenLayer.nNeurons + 1
		return nParamsPerOutput

	"""
	k = which output neuron to we build the jacobian for
	"""
	def build_jacobian(self, inputs, k):
		if self.hiddenLayer.activationFunName != 'tansig' or self.outputLayer.activationFunName != 'purelin':
			raise Exception("Cannot build jacobian for different arch than {tansig->purelin}")
		hiddenOutputs = self.hiddenLayer.apply(inputs)
		hiddenOutputsSquare = np.power(hiddenOutputs, 2)
		nParamsPerOutput = self.params_per_output()
		nSamples = inputs.shape[0]
		jacobian = np.matrix(np.zeros((nSamples, nParamsPerOutput)))
		for s in range(nSamples):
			paramId = 0
			# input weights
			for i in range(self.hiddenLayer.nInputLines):
				for j in range(self.hiddenLayer.nNeurons):
					value = self.outputLayer.weights[j, k] * (1 - hiddenOutputsSquare[s, j]) * inputs[s, i]
					jacobian[s, paramId] = jacobian[s, paramId] + value
					paramId = paramId + 1
			# input biases
			for j in range(self.hiddenLayer.nNeurons):
				value = self.outputLayer.weights[j, k] * (1 - hiddenOutputsSquare[s, j])
				jacobian[s, paramId] = jacobian[s, paramId] + value
				paramId = paramId + 1
			# output weights
			for j in range(self.hiddenLayer.nNeurons):
				value = hiddenOutputsSquare[s, j]
				jacobian[s, paramId] = jacobian[s, paramId] + value
				paramId = paramId + 1
			# output biases
			value = 1
			jacobian[s, paramId] = jacobian[s, paramId] + value
			assert(paramId == nParamsPerOutput - 1)
		return jacobian

	def lm_get_deltas_k(self, inputs, errors, k):
		errors = errors[:, k]
		jacobian = self.build_jacobian(inputs, k)
		nParamsPerOutput = self.params_per_output()
		diag = np.sqrt(0.1) * np.matrix(np.eye(nParamsPerOutput))	# default lambda = 0.1, sqrt to be ready for LU decomposition
		A = np.concatenate((-jacobian, diag))
		b = np.concatenate((-errors, np.matrix(np.zeros((nParamsPerOutput, 1)))))
		AT = np.transpose(A)
		ATA = AT * A
		PL, U = linalg.lu(ATA, True)	# transpose L to PL if necessary
		PL = np.matrix(PL)	# these are arrays, which may affect further calculations
		U = np.matrix(U)
		z = linalg.solve(PL, AT * b)	# L * z = AT * b
		delta = linalg.solve(U, z)	# U * delta = z
		return delta

	def lm_update_weights_k(self, deltas, k):
		paramId = 0
		# input weights
		for i in range(self.hiddenLayer.nInputLines):
			for j in range(self.hiddenLayer.nNeurons):
				self.hiddenLayer.weights[i, j] = self.hiddenLayer.weights[i, j] + deltas[paramId]
				paramId = paramId + 1
		# input biases
		for j in range(self.hiddenLayer.nNeurons):
			self.hiddenLayer.bias[0, j] = self.hiddenLayer.bias[0, j] + deltas[paramId]
			paramId = paramId + 1
		# output weights
		for j in range(self.hiddenLayer.nNeurons):
			self.outputLayer.weights[j, k] = self.outputLayer.weights[j, k] + deltas[paramId]
			paramId = paramId + 1
		# output biases
		self.outputLayer.bias[0, k] = self.outputLayer.bias[0, k] + deltas[paramId]
		assert(paramId == self.params_per_output() - 1)

	def lm_single_step(self, inputs, expected):
		outputs = self.apply(inputs)
		errors = expected - outputs
		deltas = []
		for k in range(self.outputLayer.nNeurons):
			deltas_k = self.lm_get_deltas_k(inputs, errors, k)
			deltas.append(deltas_k)
		for k in range(self.outputLayer.nNeurons):
			self.lm_update_weights_k(deltas[k], k)
		return rmse(expected, outputs)

	def check_dimensions(self, inputs, expected):
		if inputs.shape[1] != self.hiddenLayer.nInputLines:
			raise Exception('Incorrect number of input lines: %d, expected: %d' % (inputs.shape[1], self.hiddenLayer.nInputLines))
		if expected.shape[1] != self.outputLayer.nNeurons:
			raise Exception('Incorrect number of outputs: %d, expected: %d' % (expected.shape[1], self.outputLayer.nNeurons))

	def lm_train(self, inputs, expected, nEpochs):
		self.check_dimensions(inputs, expected)
		rmse = np.zeros(nEpochs)
		for i in range(nEpochs):
			rmse[i] = self.lm_single_step(inputs, expected)
		return rmse
