
function stable = stablestate(lastState, state)
% return true, if difference is insignificant
	MAX_DIFF = 0.001;
	nNodes = size(state, 2);
	stable = true;
	for i = 1:nNodes
		nodeState = state{i};
		for j = 1:size(nodeState, 2)
			if (abs(lastState{i}(j) - state{i}(j)) > MAX_DIFF)
				stable = false;
				break;
			end
		end
		if stable == false
			break;
		end
	end
end
	
