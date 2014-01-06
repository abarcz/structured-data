
function res = reallogit(x)
% Calculates logit() for each element of x,
% first saturating all elements to [0, 1],
% thus avoiding infinite results.
%
% usage: res = reallogit(x)
%

	maxVal = 1 - 1e-10;
	sat = max(min(x, maxVal), 0 + 1e-10);
	res = logit(sat);
end
