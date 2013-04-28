
function graph = loadgraph(graphName)
% Loads a graph from two (three if present) files:
% - graphName_nodes.csv
% - graphName_edges.csv
% (- graphName_output.csv)
%
% usage: graph = loadgraph(graphName)
%
% The nodes file should contain a comma-separated matrix NxP,
% each row (one row per node) contains single node label:
% a1, a2, ..., aP
% Row number in nodes file determines row id for edges.
%
% The edges file should contain a comma-separated matrix MxR,
% each row (one row per directed edge) contains two node ids and edge label:
% src_node_id, target_node_id, b1, b2, ..., bR
% (edge: src->target, node_id is the row number of node label in nodes file: 1..N)
% If edges don't have any labels, they will be assigned a 0 label.
% If an edge is bidirectional, it should have two separate entries.
%
% The output file should contain a matrix of desired outputs NxQ,
% each row (one row per node) contains desired output for given node:
% o1, o2, ..., oQ
% Output in i'th row corresponds to node label in i'th row of nodes file.
%
% Resulting graph contains:
% - nodes : a matrix of node labels, as read from .csv file
% - edges : a matrix of edge labels, as read from .csv file
% - nNodes : number of nodes in graph
% - maxIndegree : max indegree of a node in graph (number of edges pointing to a node)
% - sourceNodes : for each node n a vector of node ids connected to n by edge

	minLabelSize = 1;
	minOutputSize = 1;
	nodeIdSize = 1;

	nodesFilename = strcat(graphName, '_nodes.csv');
	edgesFilename = strcat(graphName, '_edges.csv');
	expectedOutputFilename = strcat(graphName, '_output.csv');

	nodeLabels = csvread(nodesFilename);
	edgeLabels = csvread(edgesFilename);
	if exist(expectedOutputFilename, 'file') == 2
		expectedOutput = csvread(expectedOutputFilename);
		assert(size(expectedOutput, 1) == size(nodeLabels, 1));
		assert(size(expectedOutput, 2) >= minOutputSize);
	else
		expectedOutput = [];
	end

	assert(size(nodeLabels, 2) >= minLabelSize);
	assert(size(edgeLabels, 2) >= nodeIdSize * 2);
	% add zero edge labels if necessary
	if size(edgeLabels, 2) < nodeIdSize * 2 + minLabelSize
		edgeLabels = [edgeLabels zeros(size(edgeLabels, 1), 1)];
	end
	% check if all node labels in edges are correct
	nNodes = size(nodeLabels, 1);
	assert(isempty(setdiff(unique(edgeLabels(:, 1:2)), [1:nNodes])));

	maxIndegree = 0;
	for i = 1:nNodes
		indegree = sum(edgeLabels(:, 2) == i);
		if indegree > maxIndegree
			maxIndegree = indegree;
		end
	end

	nodeLabelSize = size(nodeLabels, 2);
	edgeLabelSize = size(edgeLabels(:, 3:end), 2);
	nodeOutputSize = size(expectedOutput, 2);
	graph = struct(...
		'nodeLabels', nodeLabels,...
		'expectedOutput', expectedOutput,...
		'edgeLabels', edgeLabels,...
		'nodeLabelSize', nodeLabelSize,...
		'edgeLabelSize', edgeLabelSize,...
		'nNodes', nNodes,...
		'maxIndegree', maxIndegree,...
		'nodeOutputSize', nodeOutputSize);
end
