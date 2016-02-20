from utils import *
import numpy as np

class Layer():
	KNOWN_FUNCTIONS = ['purelin', 'tansig']

	def __init__(self, nInputLines, nNeurons, activationFun):
		if not activationFun in self.KNOWN_FUNCTIONS:
			raise Exception('Unknown activation function: ' + str(activationFun))
		self.nNeurons = nNeurons
		self.nInputLines = nInputLines
		self.weights = self.__init_weights(nNeurons, nInputLines)
		self.bias = self.__init_weights(nNeurons, 1)
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

	def __init_weights(self, nInputLines, nNeurons, factor=1):
		if factor is None:
			factor = nInputLines
		# random.rand returns values distributed uniformly on [0, 1)
		weights = np.matrix((np.random.rand(nNeurons, nInputLines) - 0.5) / factor)
		return weights

	def apply(self, inputs):
		if not type(inputs) is np.matrix:
			raise Exception('Layer.apply() used on sth different than numpy.matrix: ' + str(type(inputs)))
		net = self.__calc_net(inputs)
		output = self.activationFun(net)
		#print "output"
 		#print output
		return output

	def __calc_net(self, inputs):
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
		net = self.__calc_net(inputs)
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
			if (weightDeltas is None) != (biasDeltas is None):	# xor
				raise Exception("LayerDeltas cannot be partially initialized")
		self.weightDeltas = weightDeltas
		self.biasDeltas = biasDeltas
		self.inputErrors = inputErrors

	def __add__(self, other):
		# null element + other = other
		if self.weightDeltas is None:
			return other
		return LayerDeltas(self.weightDeltas + other.weightDeltas, self.biasDeltas + other.biasDeltas, self.inputErrors + other.inputErrors)
