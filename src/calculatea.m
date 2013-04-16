
function A = calculatea(gnn, graph, state)
% Calculate the dF/dx(x) matrix, where F is the transition function
%
% usage: A = calculatea(gnn, graph, state)
%
% Each box of box matrix A[n,u] contains:
% - d(hw)/d(inputs) [transition.nInputs x stateSize] if edge u->n exists
% - empty cell otherwise

	stateSize = gnn.stateSize;
	A = {};
	for nodeIndex = 1:graph.nNodes
		% build transitionNet input for single node
		sourceNodeIndexes = graph.sourceNodes{nodeIndex};
		nodeLabel = graph.nodeLabels(nodeIndex);
		for i = 1:size(sourceNodeIndexes, 2)
			sourceEdgeLabel = graph.edgeLabels(sourceNodeIndexes(i), nodeIndex);
			sourceNodeState = state(sourceNodeIndexes(i), :);
			inputs = [nodeLabel, sourceEdgeLabel, sourceNodeState];
			delta_zx = zeros(gnn.transitionNet.nInputLines, stateSize);
			for j = 1:stateSize
				errors = zeros(1, stateSize);
				errors(j) = 1;
				delta_zx(:, j) = bp2(gnn.transitionNet, inputs, errors)';
			end
			A{nodeIndex, sourceNodeIndexes(i)} = delta_zx;
		end
	end
end
