
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
	sourceInfluences = sourceInfluences .* (sourceInfluences > 0.03); % gnn.contractionConstant);
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
			sourceNodeInfluences = sourceInfluences(1, startX:endX)
			if (sum(sourceNodeInfluences, 2) != 0)
				% calculate R[n,u] for u = sourceIndex
				for targetIndex = 1:graph.nNodes
					startY = blockstart(targetIndex, gnn.stateSize);
					endY = blockend(targetIndex, gnn.stateSize);
					Rnu =  full(B(startY:endY, startX:endX))
					R{targetIndex, sourceIndex} = Rnu

					% calculate f2'(net2) and f1'(net1)
					nodeLabel = graph.nodeLabels(targetIndex);
					sourceEdgeLabel = graph.edgeLabels(sourceIndex, targetIndex);
					sourceNodeState = state(sourceIndex, :);
					inputs = [nodeLabel, sourceEdgeLabel, sourceNodeState];
					fnn = gnn.transitionNet;
					% hidden layer feed
					netv = inputs * fnn.weights1 + fnn.bias1;
					zv = fnn.activation(netv);
					sigma1 =fnn.activationderivative(zv);

					% visible layer feed
					netw = zv * fnn.weights2 + fnn.bias2;
					zw = fnn.activation(netw);
					sigma2 =fnn.activationderivative(zw);

					stateWeights1 = fnn.weights1(3:end, :);

					diag(sigma1)
					stateWeights1
					stateWeights1 * diag(sigma1)
					diag(sigma2) * Rnu * stateWeights1 * diag(sigma1)
				end
			end
		end
	end
end
