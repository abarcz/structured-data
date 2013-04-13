
function stable = stablestate(lastState, state, minStateDiff)
% Helper function for forward()
% return true, if difference between two states is insignificant

	nNodes = size(state, 2);
	stable = true;
	for i = 1:nNodes
		nodeState = state{i};
		for j = 1:size(nodeState, 2)
			if (abs(lastState{i}(j) - state{i}(j)) >= minStateDiff)
				stable = false;
				break;
			end
		end
		if stable == false
			break;
		end
	end
end
	
