
function inputStruct = buildinputs(graph, stateSize)
% Builds a matrix of inputs from graph. State remains zeroed.
% Before using this function run addgraphinfo()
%
% Each row is a single sample for the transitionNetwork.
% Each row consists of:
% l_i  - label of node i
% l_ji - label of edge j->i
% s_j  - state of node j
%
% Rows are grouped by l_i (target node)
% for easy summing up of s_i at the bext time step.

	sampleSize = graph.nodeLabelSize + graph.edgeLabelSize + stateSize;
	nSamples = size(graph.edgeLabels, 1);
	inputMatrix = zeros(nSamples, sampleSize);
	nodeState = zeros(1, stateSize);
	stateFirstRow = zeros(1, graph.nNodes);	% first row corresponding to target node in inputMatrix
	stateLastRow = zeros(1, graph.nNodes);	% last row corresponding to target node in inputMatrix
	dstRows = {};	% nodeIndex -> rows at which node state should be inserted
	% 'preallocate' dstRows
	for sourceIndex = 1:graph.nNodes
		dstRows{sourceIndex} = [];
	end
	rowIndex = 1;
	lastValidNodeIndex = 0;
	for nodeIndex = 1:graph.nNodes
		sourceNodeIndexes = graph.sourceNodes{nodeIndex};
		% if there are no edges to node, it has no entries in inputMatrix
		% and its firstRow remains zero
		if size(sourceNodeIndexes, 2) != 0
			nodeLabel = graph.nodeLabels(nodeIndex, :);
			stateFirstRow(nodeIndex) = rowIndex;
			if (lastValidNodeIndex != 0)
				stateLastRow(lastValidNodeIndex) = rowIndex - 1;
			end
			nSourceNodes = size(sourceNodeIndexes, 2);
			for i = 1:nSourceNodes
				sourceNodeIndex = sourceNodeIndexes(i);
				sourceEdgeLabel = graph.edgeLabelsCell{sourceNodeIndex, nodeIndex};
				sample = [nodeLabel, sourceEdgeLabel, nodeState];
				inputMatrix(rowIndex, :) = sample;
				dstRows{sourceNodeIndex} = [dstRows{sourceNodeIndex} rowIndex];
				rowIndex = rowIndex + 1;
			end
			lastValidNodeIndex = nodeIndex;
		end
	end
	if (lastValidNodeIndex != 0)
		stateLastRow(lastValidNodeIndex) = rowIndex - 1;
	end
	inputStruct = struct('inputMatrix', inputMatrix);
	inputStruct.stateFirstIndex = graph.nodeLabelSize + graph.edgeLabelSize + 1;
	inputStruct.nNodes = graph.nNodes;
	inputStruct.stateSize = stateSize;
	inputStruct.dstRows = dstRows;
	inputStruct.stateFirstRow = stateFirstRow;
	inputStruct.stateLastRow = stateLastRow;
end
