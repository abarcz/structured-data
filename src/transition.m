
function newState = transition(gnn, state, graph)
% Calculate global transition function

	nInputLines = gnn.transitionNet.nInputLines;
	stateSize = gnn.stateSize;
	v = gnn.transitionNet.inputWeights;
	w = gnn.transitionNet.intraWeights;
	activation = gnn.transitionNet.activation;

	newState = {};
	for nodeIndex = 1:graph.nNodes
		% build transitionNet input for single node
		sourceNodeIndexes = graph.sourceNodes{nodeIndex};
		inputLines = zeros(1, nInputLines);
		nodeLabel = graph.nodes(nodeIndex);
		inputLines(1) = nodeLabel;
		lastInputIndex = 1;
		for i = 1:size(sourceNodeIndexes, 2)
			sourceNodeIndex = sourceNodeIndexes(i);
			sourceEdgeLabel = graph.edges(sourceNodeIndex, nodeIndex);
			sourceNodeState = state{sourceNodeIndex};
			inputLines(lastInputIndex + 1) = sourceEdgeLabel;
			startIndex = lastInputIndex + 2;
			endIndex = startIndex + stateSize - 1;
			inputLines(startIndex:endIndex) = sourceNodeState;
			lastInputIndex = endIndex;
		end
		assert(endIndex <= nInputLines);
		% all remaining elements are zeroed - NIL nodes representation

		% hidden layer feed
		netv = addbias(inputLines) * v;
		zv = addbias(activation(netv));

		% visible layer feed
		netw = zv * w;
		newNodeState = activation(netw);
		newState{nodeIndex} = newNodeState;
	end
end
