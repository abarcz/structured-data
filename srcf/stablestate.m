
function stable = stablestate(lastState, state, minStateDiff)
% return true, if difference between two states is insignificant
	diff = max(max(abs(lastState - state)));
	stable = (diff < minStateDiff);
end
