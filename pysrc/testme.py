import numpy as np

def testme():
	print "test"
	return 1

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
		

