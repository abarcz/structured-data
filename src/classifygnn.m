
function outputs = classifygnn(gnn, graph, max_forward_steps=200)
% Classify graph nodes using gnn
%
% usage: outputs = classifygnn(gnn, graph, max_forward_steps=200)
%

	state = forward(gnn,graph, max_forward_steps);
	outputs = applynet(gnn.outputNet, state); %[graph.nodeLabels state])
end
