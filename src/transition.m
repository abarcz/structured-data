
function newState = transition(gnn, state, graph)
% Helper function for forward()
% Calculate global transition function

	newState = {};
	for nodeIndex = 1:graph.nNodes
		% build transitionNet input for single node
		sourceNodeIndexes = graph.sourceNodes{nodeIndex};
		nodeLabel = graph.nodes(nodeIndex);
		newNodeState = zeros(1, gnn.stateSize);
		for i = 1:size(sourceNodeIndexes, 2)
			sourceEdgeLabel = graph.edges(sourceNodeIndexes(i), nodeIndex);
			sourceNodeState = state{sourceNodeIndexes(i)};
			inputs = [nodeLabel, sourceEdgeLabel, sourceNodeState];
			stateContribution = applynet(gnn.transitionNet, inputs);
			newNodeState = newNodeState + stateContribution;
		end
		% if node has less than maxIndegree input nodes, their contribution is 0
		newState{nodeIndex} = newNodeState;
	end
end
