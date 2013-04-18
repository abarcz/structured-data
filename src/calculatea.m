
function A = calculatea(transitionNet, graph, state)
% Calculate the A(x) = dF/dx block matrix (NxN blocks, each sxs) (F = transition function)
%
% usage: A = calculatea(transitionNet, graph, state)
%
% Each block A[n,u] = dxn/dxu:
% - describes the effect of node xu on node xn, if an edge xu->xn exists
% - is null if there is no edge
%
% Each element of block A[n, u] : a[i, j]:
% - describes the effect of ith element of state xu on jth element of state xn

	stateSize = transitionNet.nOutputNeurons;
	aSize = graph.nNodes * stateSize;
	A = sparse(aSize, aSize);	% zeroed
	for nodeIndex = 1:graph.nNodes
		% build transitionNet input for single node
		sourceNodeIndexes = graph.sourceNodes{nodeIndex};
		nodeLabel = graph.nodeLabels(nodeIndex, :);
		for i = 1:size(sourceNodeIndexes, 2)
			sourceEdgeLabel = graph.edgeLabels{sourceNodeIndexes(i), nodeIndex};
			sourceNodeState = state(sourceNodeIndexes(i), :);
			inputs = [nodeLabel, sourceEdgeLabel, sourceNodeState];
			delta_zx = zeros(stateSize, stateSize);
			for j = 1:stateSize
				errors = zeros(1, stateSize);
				errors(j) = 1;
				input_deltas = bp2(transitionNet, inputs, errors);
				% select only weights corresponding to x_iu
				stateWeightsStart = 1 + graph.nodeLabelSize + graph.edgeLabelSize;
				state_input_deltas = input_deltas(1, stateWeightsStart:end);
				delta_zx(:, j) = state_input_deltas';
			end
			startX = blockstart(nodeIndex, stateSize);
			endX = blockend(nodeIndex, stateSize);
			startY = blockstart(sourceNodeIndexes(i), stateSize);
			endY = blockend(sourceNodeIndexes(i), stateSize);
			A(startX:endX, startY:endY) = delta_zx;
		end
	end
end
