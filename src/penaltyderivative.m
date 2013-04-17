
function penaltyDerivative = penaltyderivative(gnn, graph, state, A)
% Calculate penalty derivative contribution to de/do
% - e = RMSE + contraction_map_penalty (network error)
% - o - network outputs for all states

	% sum up influence of each source node on all the other nodes
	% each s-long block is influence of source node xu on all s outputs
	sourceInfluences = sum(A, 1);
	sourceInfluences = sourceInfluences .* (sourceInfluences > 0.3) % gnn.contractionConstant);
	if sum(sourceInfluences) == 0
		penaltyDerivative = 0;
		return
	else
		B = sign(A) .* repmat(sourceInfluences, size(A, 1), 1);
		full(B)
	end
end
