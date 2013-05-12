
function fnn = presavefnn(fnn)
% Remove function handlers, so that fnn can be saved to file
% (walkaround of a bug in octave)
%
% usage: fnn = presavefnn(fnn)
%

	fnn.activation2 = [];
	fnn.activationderivative2 = [];
	fnn.activation2ndderivative2 = [];
	fnn.activation1 = [];
	fnn.activationderivative1 = [];
	fnn.activation2ndderivative1 = [];
end
