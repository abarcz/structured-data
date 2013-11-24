
function A = calculatea(transitionNet, graph, state)
% Calculate the A(x) = dF/dx block matrix (NxN blocks, each sxs) (F = transition function)
%
% usage: A = calculatea(transitionNet, graph, state)
%
% Each block A[n,u] = dxn/dxu:
% - describes the effect of node xu on node xn, if an edge xu->xn exists
% - is null (zeroed) if there is no edge
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
			sourceEdgeLabel = graph.edgeLabelsCell{sourceNodeIndexes(i), nodeIndex};
			sourceNodeState = state(sourceNodeIndexes(i), :);
			inputs = [nodeLabel, sourceEdgeLabel, sourceNodeState];
			deltaZx = zeros(stateSize, stateSize);

			% perform backpropagation - step 1
			% fnn feed
			fnn = transitionNet;
			net1 = fnn.weights1 * inputs' + fnn.bias1;
			hiddenOutputs = fnn.activation1(net1);
			net2 = fnn.weights2 * hiddenOutputs + fnn.bias2;
			bpv1 = fnn.activationderivative1(net1);
			bpv2 = fnn.activationderivative2(net2);

			for j = 1:stateSize
				errors = zeros(1, stateSize);
				errors(j) = 1;

				% perform backpropagation - step 2
				% calculate delta2 (for all visible neurons at once)
				delta2 = errors' .* bpv2;
				% calculate delta1 (for all hidden neurons at once)
				hiddenErrors = fnn.weights2' * delta2;
				delta1 = hiddenErrors .* bpv1;
				% calculate delta0 (for all input neurons at once)
				inputErrors = fnn.weights1' * delta1;
				inputDeltas = inputErrors';

				% select only weights corresponding to x_iu
				stateWeightsStart = 1 + graph.nodeLabelSize + graph.edgeLabelSize;
				stateInputDeltas = inputDeltas(1, stateWeightsStart:end);
				deltaZx(:, j) = stateInputDeltas';
			end
			startX = blockstart(nodeIndex, stateSize);
			endX = blockend(nodeIndex, stateSize);
			startY = blockstart(sourceNodeIndexes(i), stateSize);
			endY = blockend(sourceNodeIndexes(i), stateSize);
			A(startX:endX, startY:endY) = deltaZx;
		end
	end
end
