
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
	sourceInfluences = sourceInfluences .* (sourceInfluences > 0.06); % gnn.contractionConstant);
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
					sigma1 =fnn.activationderivative1(net1);
					sigma2 =fnn.activationderivative2(net2);

					stateWeights1 = fnn.weights1(:, 3:end);

					diag(sigma2) * Rnu * stateWeights1' * diag(sigma1);
				end
			end
		end
	end
	disp(R);
end
