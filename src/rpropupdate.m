
function rpropStruct = rpropupdate(rpropStruct, errorDerivatives, deltaMin, deltaMax)
% Helper function for rprop(), operates on sigle matrix of weights
%
% usage: rpropStruct = rpropupdate(rpropStruct, errorDerivatives, deltaMin, deltaMax)
%
% rpropStruct.weightUpdates - deltas that should be added to fnn weights

	
	assert(size(rpropStruct.errors, 1) == size(errorDerivatives, 1));
	assert(size(rpropStruct.errors, 2) == size(errorDerivatives, 2));
	increase = 1.2;
	decrease = 0.5;
	errorDirectionChange = rpropStruct.errors .* errorDerivatives;

	for i = 1:size(rpropStruct.deltas, 1)
		for j = 1:size(rpropStruct.deltas, 2)
			if errorDirectionChange(i, j) > 0
				% increase weight update
				rpropStruct.deltas(i, j) = min(rpropStruct.deltas(i, j) * increase, deltaMax);
				rpropStruct.weightUpdates(i, j) = sign(errorDerivatives(i, j)) * rpropStruct.deltas(i, j);
				rpropStruct.errors(i, j) = errorDerivatives(i, j);
			else if errorDirectionChange(i, j) < 0
				rpropStruct.deltas(i, j) = max(rpropStruct.deltas(i, j) * decrease, deltaMin);
				% revert last weight update
				rpropStruct.weightUpdates(i, j) = - rpropStruct.weightUpdates(i, j);
				% avoid double punishment in next step
				rpropStruct.errors(i, j) = 0;
			else
				rpropStruct.weightUpdates(i, j) = sign(errorDerivatives(i, j)) * rpropStruct.deltas(i, j);
				rpropStruct.errors(i, j) = errorDerivatives(i, j);
			end
		end
	end
end
