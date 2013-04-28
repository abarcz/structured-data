
function deltas = transitiondeltas(transitionNet, graph, state, errors)
% Calculate matrix: deltaAccumulator * dFw/dw
%
% usage: deltas = transitiondeltas(transitionNet, graph, state, errors)
%
% F : global transition function, F(node_labels, edge_labels, node_states)=node_states
% state : each row contains a node state
% errors : each row contains an error of a node (e.g. 2(d - y))

	deltas = zerodeltas(transitionNet);
	for nodeIndex = 1:graph.nNodes
		% build transitionNet input for single node
		sourceNodeIndexes = graph.sourceNodes{nodeIndex};
		nodeLabel = graph.nodeLabels(nodeIndex, :);
		nodeErrors = errors(nodeIndex, :);
		for i = 1:size(sourceNodeIndexes, 2)
			sourceEdgeLabel = graph.edgeLabelsCell{sourceNodeIndexes(i), nodeIndex};
			sourceNodeState = state(sourceNodeIndexes(i), :);
			inputs = [nodeLabel, sourceEdgeLabel, sourceNodeState];
			singleEdgeDeltas = backpropagate(transitionNet, inputs, nodeErrors);
			deltas.deltaWeights1 = deltas.deltaWeights1 + singleEdgeDeltas.deltaWeights1;
			deltas.deltaWeights2 = deltas.deltaWeights2 + singleEdgeDeltas.deltaWeights2;
			deltas.deltaBias1 = deltas.deltaBias1 + singleEdgeDeltas.deltaBias1;
			deltas.deltaBias2 = deltas.deltaBias2 + singleEdgeDeltas.deltaBias2;
		end
	end
end
