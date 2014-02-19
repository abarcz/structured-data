
function [penaltyDerivative penaltyAdded] = penaltyderivative(gnn, graph, state, A)
% Calculate penalty derivative contribution to de/dw, where:
% - e = RMSE + contractionMapPenalty (network error)
%
% usage: [penaltyDerivative penaltyAdded] = penaltyderivative(gnn, graph, state, A)
%

	% note on matrix A:
	% each s^2 block denotes influence of single source node xu on all s outputs of xn
	% each block matrix row n denotes influences on target node xn by all source nodes
	% each block matrix column u denotes influences of source node xu on target nodes
	% (edge from xu to xn)

	% sum up influence of each source node on all the other nodes
	% each s-long block is influence of single source node xu on all s outputs
	sourceInfluences = sum(abs(A), 1);
	%full(mean(mean(sourceInfluences)))
	%full(max(max(sourceInfluences)))
	sourceInfluences = (sourceInfluences - repmat(gnn.contractionConstant, size(sourceInfluences))) .*...
		(sourceInfluences > gnn.contractionConstant);
	%full(mean(mean(sourceInfluences)))
	%full(max(max(sourceInfluences)))

	fnn = gnn.transitionNet;
	nWeights1 = fnn.nInputLines * fnn.nHiddenNeurons;
	nBias1 = fnn.nHiddenNeurons;
	nWeights2 = fnn.nOutputNeurons * fnn.nHiddenNeurons;
	nBias2 = fnn.nOutputNeurons;
	penaltyDerivative = zeros(1, nWeights1 + nBias1 + nWeights2 + nBias2);
	if sum(sourceInfluences) == 0
		penaltyAdded = false;
	else
		penaltyAdded = true;
		% matrix B contains influences from A, filtered:
		% only influences coming from a too influential source are retained
		B = sign(A) .* repmat(sourceInfluences, size(A, 1), 1);
		for sourceIndex = 1:graph.nNodes
			startX = blockstart(sourceIndex, gnn.stateSize);
			endX = blockend(sourceIndex, gnn.stateSize);
			sourceNodeInfluences = sourceInfluences(1, startX:endX);
			if (sum(sourceNodeInfluences, 2) != 0)
				% calculate impactDerivative[n, u] for u = sourceIndex
				targetIndexes = graph.targetNodes{sourceIndex};
				nTargetNodes = size(targetIndexes, 2);
				for i = 1:nTargetNodes
					targetIndex = targetIndexes(i);
					startY = blockstart(targetIndex, gnn.stateSize);
					endY = blockend(targetIndex, gnn.stateSize);
					Rnu =  full(B(startY:endY, startX:endX));

					% calculate f2'(net2) and f1'(net1)
					nodeLabel = graph.nodeLabels(targetIndex, :);
					sourceEdgeLabel = graph.edgeLabelsCell{sourceIndex, targetIndex};
					sourceNodeState = state(sourceIndex, :);
					inputs = [nodeLabel, sourceEdgeLabel, sourceNodeState];

					% fnn feed
					net1 = fnn.weights1 * inputs' + fnn.bias1;
					hiddenOutputs = fnn.activation1(net1);
					net2 = fnn.weights2 * hiddenOutputs + fnn.bias2;
					sigma1 = fnn.activationderivative1(net1);
					sigma2 = fnn.activationderivative2(net2);

					% select only weights corresponding to xu at inputs
					stateWeightsStart = 1 + graph.nodeLabelSize + graph.edgeLabelSize;
					stateWeights1 = fnn.weights1(:, stateWeightsStart:end);


					% vec(Rnu)' * dvec(Anu)/dw = da1 + da2 + da3 + da4
					deltaSignal1 = vec(Rnu * stateWeights1' * diag(sigma1) * fnn.weights2')' * vecdiagmatrix(gnn.stateSize);
					fnn2nd = fnn;
					fnn2nd.activation1 = fnn.activationderivative1;
					fnn2nd.activation2 = fnn.activationderivative2;
					fnn2nd.activationderivative1 = fnn.activation2ndderivative1;
					fnn2nd.activationderivative2 = fnn.activation2ndderivative2;
					deltas1 = backpropagate(fnn2nd, inputs, deltaSignal1);
					da1 = vecdeltas(deltas1)';

					da2left = vec(diag(sigma2) * Rnu * stateWeights1' * diag(sigma1))';
					weights2dw = [zeros(nWeights2, nWeights1 + nBias1) eye(nWeights2) zeros(nWeights2, nBias2)];
					da2 = da2left * weights2dw;

					deltaSignal3 = vec(fnn.weights2' * diag(sigma2) * Rnu * stateWeights1')' * vecdiagmatrix(fnn.nHiddenNeurons);
					% 1-layer fnn backpropagate with f(net) = transition.f'(net)
					net1 = fnn.weights1 * inputs' + fnn.bias1;
					delta1 = deltaSignal3' .* fnn.activation2ndderivative1(net1);
					deltaWeights1 = delta1 * inputs;
					deltaBias1 = delta1;
					da3 = [vec(deltaWeights1); vec(deltaBias1); zeros(nWeights2 + nBias2, 1)]';

					da4left = vec(diag(sigma1) * fnn.weights2' * diag(sigma2) * Rnu)';
					stateSize = fnn.nOutputNeurons;
					nStateWeights = stateSize * fnn.nHiddenNeurons;
					labelsSize = graph.nodeLabelSize + graph.edgeLabelSize;
					stateWeights1Dw = zeros(nStateWeights, nWeights1 + nBias1 + nWeights2 + nBias2);
					% mark with ones weights corresponding to xu
					for h = 1:fnn.nHiddenNeurons
						startIndexX = 1 + (h - 1) * fnn.nInputLines + labelsSize;
						endIndexX = startIndexX + stateSize - 1;
						startIndexY = 1 + (h - 1) * stateSize;
						endIndexY = startIndexY + stateSize - 1;
						stateWeights1Dw(startIndexY:endIndexY, startIndexX:endIndexX) = eye(stateSize);
					end
					da4 = da4left * stateWeights1Dw;

					impactDerivative = da1 + da2 + da3 + da4;
					penaltyDerivative = penaltyDerivative + impactDerivative;
				end
			end
		end
		penaltyDerivative = penaltyDerivative * 2;
	end
end
