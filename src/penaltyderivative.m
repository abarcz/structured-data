
function penaltyDerivative = penaltyderivative(gnn, graph, state, A)
% Calculate penalty derivative contribution to de/do
% - e = RMSE + contraction_map_penalty (network error)
% - o - network outputs for all states
%
% usage: penaltyDerivative = penaltyderivative(gnn, graph, state, A)
%

	% sum up influence of each source node on all the other nodes
	% each s-long block is influence of single source node xu on all s outputs
	sourceInfluences = sum(A, 1);
	full(sourceInfluences)
	sourceInfluences = sourceInfluences .* (sourceInfluences > 0.1); % gnn.contractionConstant);
	full(sourceInfluences)
	if sum(sourceInfluences) == 0
		penaltyDerivative = 0;
		return
	else
		B = sign(A) .* repmat(sourceInfluences, size(A, 1), 1);
		R = {};
		for sourceIndex = 1:graph.nNodes
			startX = blockstart(sourceIndex, gnn.stateSize);
			endX = blockend(sourceIndex, gnn.stateSize);
			sourceNodeInfluences = sourceInfluences(1, startX:endX);
			if (sum(sourceNodeInfluences, 2) != 0)
				% calculate R[n,u] for u = sourceIndex
				for targetIndex = 1:graph.nNodes
					if !ismember(sourceIndex, graph.sourceNodes{targetIndex})
						continue;
					end
					startY = blockstart(targetIndex, gnn.stateSize);
					endY = blockend(targetIndex, gnn.stateSize);
					Rnu =  full(B(startY:endY, startX:endX));
					R{targetIndex, sourceIndex} = Rnu;

					% calculate f2'(net2) and f1'(net1)
					nodeLabel = graph.nodeLabels(targetIndex, :);
					sourceEdgeLabel = graph.edgeLabels{sourceIndex, targetIndex};
					sourceNodeState = state(sourceIndex, :);
					inputs = [nodeLabel, sourceEdgeLabel, sourceNodeState];
					fnn = gnn.transitionNet;

					% fnn feed
					net1 = fnn.weights1 * inputs' + fnn.bias1;
					hiddenOutputs = fnn.activation1(net1);
					net2 = fnn.weights2 * hiddenOutputs + fnn.bias2;
					sigma1 = fnn.activationderivative1(net1);
					sigma2 = fnn.activationderivative2(net2);

					% select only weights corresponding to xu at inputs
					stateWeights1 = fnn.weights1(:, graph.stateWeightsStart:end);

					% da = da1 + da2 + da3 + da4
					deltaSignal1 = vec(Rnu * stateWeights1' * diag(sigma1) * fnn.weights2')' * vecdiagmatrix(gnn.stateSize);
					fnn2nd = fnn;
					fnn2nd.activation1 = fnn.activationderivative1;
					fnn2nd.activation2 = fnn.activationderivative2;
					fnn2nd.activationderivative1 = fnn.activation2ndderivative1;
					fnn2nd.activationderivative2 = fnn.activation2ndderivative2;
					deltas1 = backpropagate(fnn2nd, inputs, deltaSignal1);
					da1 = [vec(deltas1.deltaWeights1); vec(deltas1.deltaBias1);...
						vec(deltas1.deltaWeights2); vec(deltas1.deltaBias2)]';

					da2left = vec(diag(sigma2) * Rnu * stateWeights1' * diag(sigma1))';
					nWeights2 = fnn.nOutputNeurons * fnn.nHiddenNeurons;
					nBias2 = fnn.nOutputNeurons;
					nWeights1 = fnn.nInputLines * fnn.nHiddenNeurons;
					nBias1 = fnn.nHiddenNeurons;
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
						startX = 1 + (h - 1) * fnn.nInputLines + labelsSize;
						endX = startX + stateSize - 1;
						startY = 1 + (h - 1) * stateSize;
						endY = startY + stateSize - 1;
						stateWeights1Dw(startY:endY, startX:endX) = eye(stateSize);
					end
					da4 = da4left * stateWeights1Dw;

					da = da1 + da2 + da3 + da4;
					size(da)
				end
			end
		end
	end
	disp(R);
end
