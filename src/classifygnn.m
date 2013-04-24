
function outputs = classifygnn(gnn, graph)
% Classify graph nodes using gnn
%
% usage: outputs = classifygnn(gnn, graph)
%

	state = forward(gnn,graph);
	outputs = applynet(gnn.outputNet, state); %[graph.nodeLabels state])
end
