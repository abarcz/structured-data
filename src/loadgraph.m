
function graph = loadgraph(graphName)
% Loads a graph from two (three if present) files:
% - graphName_nodes.csv
% - graphName_edges.csv
% (- graphName_output.csv)
%
% usage: graph = loadgraph(graphName)
%
% The nodes file is supposed to contain a comma-separated list of node labels.
%
% The edges file is supposed to contain a comma-separated matrix
% of edge labels. Label a(i,j) is the label of edge from v_i to v_j.
% Zero label means no edge.
%
% The output file is supposed to contain a matrix of desired outputs:
% i'th column of the matrix is the desired output for i'th node.
% Number of columns must match the number of columns in nodes file.
%
% Resulting graph contains:
% - nodes : a vector of node labels, as read from .csv file
% - edges : a matrix of edge labels, as read from .csv file
% - nNodes : number of nodes in graph
% - maxIndegree : max indegree of a node in graph (number of edges pointing to a node)
% - sourceNodes : for each node n a vector of nodes connected to n by edge

	NO_EDGE = 0;

	nodesFilename = strcat(graphName, '_nodes.csv');
	edgesFilename = strcat(graphName, '_edges.csv');
	expectedOutputFilename = strcat(graphName, '_output.csv');

	nodeLabels = csvread(nodesFilename);
	edgeLabels = csvread(edgesFilename);
	if exist(expectedOutputFilename, 'file') == 2
		expectedOutput = csvread(expectedOutputFilename);
		assert(size(expectedOutput, 2) == size(nodeLabels, 2));
	else
		expectedOutput = [];
	end
	nodeOutputSize = size(expectedOutput, 1);

	nNodes = size(nodeLabels, 2);
	assert(size(nodeLabels, 1) == 1);
	assert(size(edgeLabels, 1) == nNodes);
	assert(size(edgeLabels, 2) == nNodes);

	sourceNodes = {};
	for targetIndex = 1:nNodes
		sourceNodes{targetIndex} = [];
		for sourceIndex = 1:nNodes
			if edgeLabels(sourceIndex, targetIndex) != NO_EDGE
				sourceNodes{targetIndex} = [sourceNodes{targetIndex} sourceIndex];
			end
		end
	end
	maxIndegree = max(sum(edgeLabels));

	graph = struct(...
		'nodeLabels', nodeLabels,...
		'expectedOutput', expectedOutput,...
		'edgeLabels', edgeLabels,...
		'nNodes', nNodes,...
		'maxIndegree', maxIndegree,...
		'nodeOutputSize', nodeOutputSize,...
		'sourceNodes', {sourceNodes});
end
