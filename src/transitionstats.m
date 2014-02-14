
function stats = transitionstats(backwardDeltas)
% Calculate dependencies between:
% - transitionDeltas - weight deltas calculated by backpropagation algorithm on transition network
% - transitionPenaltyDeltas - weight deltas calculated as contraction penalty derivatives
%
% usage: stats = transitionstats(backwardDeltas)
%
% stats:
% - percentage of sumaric deltas with sign correlated to deltas
% - percentage of sumaric deltas with sign correlated to penalty-based deltas
% - percentage of deltas with sign correlated to penalty-based deltas
% - max ratio : penaltyDelta / delta


	deltas = vecdeltas(backwardDeltas.transition);
	penaltyDeltas = vecdeltas(backwardDeltas.transitionPenalty);
	assert(size(deltas, 1) == size(penaltyDeltas, 1));
	nDeltas = size(deltas, 1);

	maxRatio = 0;
	for i = 1:nDeltas
		if deltas(i) == 0
			ratio = 0;
		else
			ratio = abs(penaltyDeltas(i) / deltas(i));
		end
		if ratio > maxRatio
			maxRatio = ratio;
		end
	end

	sumDeltas = deltas + penaltyDeltas;
	sumDeltasSign = sign(sumDeltas);
	deltasSign = sign(deltas);
	penaltySign = sign(penaltyDeltas);

	correlatedWithDeltas = sum(sumDeltasSign == deltasSign);
	correlatedWithPenalty = sum(sumDeltasSign == penaltySign);
	deltasCorrelated = sum(deltasSign == penaltySign);

	stats = [correlatedWithDeltas, correlatedWithPenalty, deltasCorrelated, 0] / nDeltas * 100;
	stats(4) = maxRatio;
end
