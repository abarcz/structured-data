
function res = realatanh(x)
% Calculates atanh() for each element of x,
% first saturating all elements to [-1, 1],
% thus avoiding complex results.
%
% usage: res = realatanh(x)
%

	maxVal = 1 - 1e-10;	% max result value = 11.85950
	sat = max(min(x, maxVal), -maxVal);
	res = atanh(sat);
end
