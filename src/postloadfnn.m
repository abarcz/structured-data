
function fnn = postloadfnn(fnn)
% Restore function handlers in fnn loaded from file
% (walkaround of a bug in octave)
%
% usage: fnn = postloadfnn(fnn)
%
	
	if strcmp(fnn.hiddenFun, 'logsig') == 1
		fnn.activation1 = @(x) logsig(x);
		fnn.activationderivative1 = @(x) logsig(x) .* (1 - logsig(x));
		fnn.activation2ndderivative1 = @(x) error('second derivative of logsig not implemented');
	elseif strcmp(fnn.hiddenFun, 'tansig') == 1
		fnn.activation1 = @(x) tanh(x);
		fnn.activationderivative1 = @(x) repmat(1, size(x)) - (tanh(x) .^ 2);
		fnn.activation2ndderivative1 = @(x) 2 .* (tanh(x) .^ 3 - tanh(x));
	else	% purelin
		fnn.activation1 = @(x) x;
		fnn.activationderivative1 = @(x) 1;
		fnn.activation2ndderivative1 = @(x) 0;
	end

	if strcmp(fnn.outputFun, 'logsig') == 1
		fnn.activation2 = @(x) logsig(x);
		fnn.activationderivative2 = @(x) logsig(x) .* (1 - logsig(x));
		fnn.activation2ndderivative2 = @(x) error('second derivative of logsig not implemented');
	elseif strcmp(fnn.outputFun, 'tansig') == 1
		fnn.activation2 = @(x) tanh(x);
		fnn.activationderivative2 = @(x) repmat(1, size(x)) - (tanh(x) .^ 2);
		fnn.activation2ndderivative2 = @(x) 2 .* (tanh(x) .^ 3 - tanh(x));
	else	% purelin
		fnn.activation2 = @(x) x;
		fnn.activationderivative2 = @(x) 1;
		fnn.activation2ndderivative2 = @(x) 0;
	end
end
