
function stable = stablestate(lastState, state, minStateDiff)
% Helper function for forward()
% return true, if difference between two states is insignificant

	diff = sum(sum(abs(lastState - state)));
	if (diff >= minStateDiff)
		stable = false;
	else
		stable = true;
	end
end
