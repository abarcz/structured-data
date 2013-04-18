
function newState = transition(fnn, state, graph)
% Helper function for forward()
% Calculate global transition function

	newState = zeros(size(state));
	for nodeIndex = 1:graph.nNodes
		% build transitionNet input for single node
		sourceNodeIndexes = graph.sourceNodes{nodeIndex};
		nodeLabel = graph.nodeLabels(nodeIndex, :);
		newNodeState = zeros(1, fnn.nOutputNeurons);
		for i = 1:size(sourceNodeIndexes, 2)
			sourceEdgeLabel = graph.edgeLabels{sourceNodeIndexes(i), nodeIndex};
			sourceNodeState = state(sourceNodeIndexes(i), :);
			inputs = [nodeLabel, sourceEdgeLabel, sourceNodeState];
			stateContribution = applynet(fnn, inputs);
			newNodeState = newNodeState + stateContribution;
		end
		% if node has less than maxIndegree input nodes, their contribution is 0
		newState(nodeIndex, :) = newNodeState;
	end
end
