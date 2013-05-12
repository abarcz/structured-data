
function fnn = postloadfnn(fnn)
% Restore function handlers in fnn loaded from file
% (walkaround of a bug in octave)
%
% usage: fnn = postloadfnn(fnn)
%
	
	fnn.activation1 = @(x) tanh(x);
	fnn.activationderivative1 = @(x) repmat(1, size(x)) - (tanh(x) .^ 2);
	fnn.activation2ndderivative1 = @(x) 2 .* (tanh(x) .^ 3 - tanh(x));

	if strcmp(fnn.outputFun, 'purelin') == 1
		fnn.activation2 = @(x) x;
		fnn.activationderivative2 = @(x) 1;
		fnn.activation2ndderivative2 = @(x) 0;
	else	% tansig
		fnn.activation2 = @(x) tanh(x);
		fnn.activationderivative2 = @(x) repmat(1, size(x)) - (tanh(x) .^ 2);
		fnn.activation2ndderivative2 = @(x) 2 .* (tanh(x) .^ 3 - tanh(x));
	end
end
