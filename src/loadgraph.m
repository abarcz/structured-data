
function graph = loadgraph(graphName)
% Loads a graph from two files:
% - graphName_nodes.csv
% - graphName_edges.csv
%
% The nodes file is supposed to contain a comma-separated list of node labels
%
% The edges file is supposed to contain a comma-separated matrix
% of edge labels. Label a(i,j) is the label of edge from v_i to v_j.
% Zero label means no edge.
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

	nodes = csvread(nodesFilename);
	edges = csvread(edgesFilename);

	nNodes = size(nodes, 2);
	assert(size(nodes, 1) == 1);
	assert(size(edges, 1) == nNodes);
	assert(size(edges, 2) == nNodes);

	sourceNodes = {};
	for targetIndex = 1:nNodes
		sourceNodes{targetIndex} = [];
		for sourceIndex = 1:nNodes
			if edges(sourceIndex, targetIndex) != NO_EDGE
				sourceNodes{targetIndex} = [sourceNodes{targetIndex} sourceIndex];
			end
		end
	end
	maxIndegree = max(sum(edges));

	graph = struct(...
		'nodes', nodes,...
		'edges', edges,...
		'nNodes', nNodes,...
		'maxIndegree', maxIndegree,...
		'sourceNodes', {sourceNodes});
end
