
function deltas = outputdeltas(outputNet, graph, state, errors)
% Calculate matrix: dew/do * dGw/dw
%
% usage: deltas = outputdeltas(outputNet, graph, state, errors)
%
% G : global output function, G(nodeStates)=outputs
% state : each row contains a node state
% errors : each row contains an error of a node (e.g. 2(d - y))

	deltas = zerodeltas(outputNet);
	for nodeIndex = 1:graph.nNodes
		nodeErrors = errors(nodeIndex, :);
		nodeState = state(nodeIndex, :);
		inputs = nodeState;
		singleNodeDeltas = backpropagate(outputNet, inputs, nodeErrors);
		deltas = adddeltas(deltas, singleNodeDeltas);
	end
end
