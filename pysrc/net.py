import scipy.linalg as linalg
from layer import *
from utils import *

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

	def evaluate(self, inputs, expected):
		outputs = self.apply(inputs)
		return rmse(expected, outputs)

	def train(self, inputs, expected, nEpochs, learningConstant):
		nSamples = inputs.shape[0]
		print "nSamples: %d" % nSamples
		for i in range(nEpochs):
			outputs = self.apply(inputs)
#			print "outputs"
#			print outputs
			errors = expected - outputs
			print "rmse: %f" % rmse(expected, outputs)
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
	k = which output neuron do we build the jacobian for
	"""
	def build_jacobian(self, inputs, k):
		if self.hiddenLayer.activationFunName != 'tansig' or not self.outputLayer.activationFunName in set(['purelin', 'tansig']):
			raise Exception("Cannot build jacobian for different arch than {tansig->purelin}")
		hiddenOutputs = self.hiddenLayer.apply(inputs)
		hiddenOutputsSquare = np.power(hiddenOutputs, 2)

		isTansigOutput = self.outputLayer.activationFunName == 'tansig'
		if isTansigOutput:
			outputs = self.outputLayer.apply(hiddenOutputs)
			outputsSquare = np.power(outputs, 2)

		nParamsPerOutput = self.params_per_output()
		nSamples = inputs.shape[0]
		jacobian = np.matrix(np.zeros((nSamples, nParamsPerOutput)))
		for s in range(nSamples):
			paramId = 0
			# input weights
			for i in range(self.hiddenLayer.nInputLines):
				for j in range(self.hiddenLayer.nNeurons):
					value = self.outputLayer.weights[j, k] * (1 - hiddenOutputsSquare[s, j]) * inputs[s, i]
					if isTansigOutput:
						value = value * (1 - outputsSquare[j, k])
					jacobian[s, paramId] = jacobian[s, paramId] + value
					paramId = paramId + 1
			# input biases
			for j in range(self.hiddenLayer.nNeurons):
				value = self.outputLayer.weights[j, k] * (1 - hiddenOutputsSquare[s, j])
				if isTansigOutput:
					value = value * (1 - outputsSquare[j, k])
				jacobian[s, paramId] = jacobian[s, paramId] + value
				paramId = paramId + 1
			# output weights
			for j in range(self.hiddenLayer.nNeurons):
				value = hiddenOutputs[s, j]
				if isTansigOutput:
					value = value * (1 - outputsSquare[j, k])
				jacobian[s, paramId] = jacobian[s, paramId] + value
				paramId = paramId + 1
			# output biases
			value = 1
			if isTansigOutput:
				value = value * (1 - outputsSquare[j, k])
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
