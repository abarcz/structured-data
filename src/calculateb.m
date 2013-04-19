
function b = calculateb(outputNet, graph, state, errorDerivative)
% Calculate b matrix = dew/do * dGw/dx
%
% G : global output function, G(node_states)=outputs
% errorDerivative : each row contains an error of a node
% state : each row contains a node state

	b = zeros(outputNet.nInputLines, graph.nNodes);
	for nodeIndex = 1:graph.nNodes
		errors = errorDerivative(nodeIndex, :);
		nodeState = state(nodeIndex, :);
		%inputs = [graph.nodeLabels(nodeIndex) nodeState];
		inputs = nodeState;
		deltas = backpropagate(outputNet, inputs, errors);
		b(:, nodeIndex) = deltas.deltaInputs(1, :); %1 + graph.nodeLabelSize:end)';
	end
	% stack output for each node on one another
	b = vec(b)';
end
