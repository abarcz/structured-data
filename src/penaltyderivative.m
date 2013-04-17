
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
					R{targetIndex, sourceIndex} = full(B(startY:endY, startX:endX));
				end
			end
		end
	end
end
