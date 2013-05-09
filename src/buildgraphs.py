#!/usr/bin/python

import argparse
from random import randint, random, sample
from itertools import combinations
import networkx as nx
from copy import deepcopy
import csv

"""
Build dataset for subgraph matching.
"""

MIN_NODE_LABEL = 0
MAX_NODE_LABEL = 10
NON_SUBGRAPH = -1
SUBGRAPH = 1


class Graph():
	"""
	Simple graph representation
	"""
	def __init__(self, nodes, target_nodes):
		self.nodes = nodes
		self.target_nodes = target_nodes
		self.outputs = [NON_SUBGRAPH] * len(nodes)

	def __repr__(self):
		return str([self.nodes, self.edges()])
	
	def edges(self):
		edges = []
		for source_node in self.target_nodes:
			for target_node in self.target_nodes[source_node]:
				edges.append([source_node, target_node])
		return edges
	
	def to_networkx(self):
		g = nx.DiGraph()
		for i in range(len(self.nodes)):
			g.add_node(i, label=self.nodes[i])
		for edge in self.edges():
			g.add_edge(edge[0], edge[1])
		return g
	
	def nodes_num(self):
		return len(self.nodes)

	def insert(self, subgraph):
		"""
		Insert subgraph into graph, preserving nodes num
		"""
		new_nodes = subgraph.nodes
		new_nodes_num = subgraph.nodes_num()
		deleted_indexes = sample(range(self.nodes_num()), new_nodes_num)
		for i in range(len(new_nodes)):
			deleted_index = deleted_indexes[i]
			self.nodes[deleted_index] = new_nodes[i]
		new_edges = subgraph.edges()
		for i in range(len(new_edges)):
			edge = new_edges[i]
			old_source = edge[0]
			old_target = edge[1]
			new_source = deleted_indexes[old_source]
			new_target = deleted_indexes[old_target]
			self.target_nodes[new_source].add(new_target)
			self.target_nodes[new_target].add(new_source)

	def mark_occurences(self, subgraph):
		"""
		Mark all occurences of subgraph in the graph
		"""
		sub_node_labels = set(subgraph.nodes)
		# select only nodes having labels existing in subgraph
		node_labels = self._filter_nodes(sub_node_labels)
		sub_nodes_num  = len(subgraph.nodes)
		node_subsets_indexes = list(combinations(node_labels.keys(), sub_nodes_num))
		node_subsets = []
		for subset_indexes in node_subsets_indexes:
			node_subset = {}	# node_index -> node_label
			for index in subset_indexes:
				node_subset[index] = node_labels[index]
			node_subsets.append(node_subset)
		marked_indexes = []
		subgraph_nx = subgraph.to_networkx()
		for node_subset in node_subsets:
			if sorted(node_subset.values()) != sorted(subgraph.nodes):
				continue
			#print "----- check -------"
			#print node_subset.values()
			graph = nx.DiGraph()
			new_indexes = {}	# old index -> new index
			for i in range(len(node_subset.keys())):
				old_index = node_subset.keys()[i]
				new_indexes[old_index] = i
			#print "new: ", new_indexes
			for node_index in node_subset.keys():
				graph.add_node(new_indexes[node_index], label=node_subset[node_index])
			edges = []
			for node_index in node_subset.keys():
				target_indexes = self.target_nodes[node_index]
				#print "target: ", target_indexes
				source_index = new_indexes[node_index]
				for old_target_index in target_indexes:
					# remove edges that aren't contained in node subset
					if not old_target_index in set(node_subset.keys()):
						continue
					target_index = new_indexes[old_target_index]
					edges.append((source_index, target_index))
			# partial graph can contain edges not present in matched subgraph
			# we have to check all subsets of edges of valid size
			edge_subsets = list(combinations(edges, len(subgraph_nx.edges())))
			for edge_subset in edge_subsets:
				curr_graph = deepcopy(graph)
				for edge in edge_subset:
					curr_graph.add_edge(edge[0], edge[1])
				#print "nodes: ", curr_graph.nodes()
				#print "edges: ", curr_graph.edges()
				#print "nodes: ", subgraph_nx.nodes()
				#print "edges: ", subgraph_nx.edges()
				subgraph_match = nx.is_isomorphic(subgraph_nx, curr_graph,\
					node_match=lambda d1, d2 : d1["label"] == d2["label"])
				#print subgraph_match
				if subgraph_match:
					for node_index in node_subset:
						marked_indexes.append(node_index)
					break
		#print "marked:"
		#print marked_indexes
		if len(marked_indexes) == 0:
			#print self.nodes
			#print self.target_nodes
			#print subgraph.nodes
			#print subgraph.target_nodes
			raise Exception("No subgraph found in graph!")
		for index in marked_indexes:
			self.outputs[index] = SUBGRAPH

	def _filter_nodes(self, node_labels):
		filtered = {}	# node_index -> node_label
		for i in range(len(self.nodes)):
			node_label = self.nodes[i]
			if node_label in node_labels:
				filtered[i] = node_label
		return filtered
		

def is_connected(nodes, target_nodes):
	node_indexes = range(len(nodes))
	nonvisited_nodes = set(node_indexes[1:])
	working_set = [node_indexes[0]]
	while len(working_set) > 0:
		node = working_set.pop()
		node_target_nodes = target_nodes[node]
		for target_node in node_target_nodes:
			if target_node in nonvisited_nodes:
				nonvisited_nodes.remove(target_node)
				working_set.append(target_node)
	return len(nonvisited_nodes) == 0

def build_graph(nodes_num, edge_probability, subgraph=None):
	nodes = []
	target_nodes = {}
	for i in range(nodes_num):
		nodes.append(randint(MIN_NODE_LABEL, MAX_NODE_LABEL))
		target_nodes[i] = set()
	for i in range(nodes_num):
		for j in range(i + 1, nodes_num):
			if random() < edge_probability:
				# insert bidirectional edge
				target_nodes[i].add(j)
				target_nodes[j].add(i)
	# insert randomly target_nodes until graph is connected
	while not is_connected(nodes, target_nodes):
		edge = sample(range(nodes_num), 2)
		target_nodes[edge[0]].add(edge[1])
		target_nodes[edge[1]].add(edge[0])
	graph = Graph(nodes, target_nodes)
	if subgraph != None:
		graph.insert(subgraph)
		graph.mark_occurences(subgraph)
	return graph


def save_graph(graph_name, graph):
	nodes_filename = "%s_nodes.csv" % graph_name
	outputs_filename = "%s_output.csv" % graph_name
	edges_filename = "%s_edges.csv" % graph_name
	with open(nodes_filename, "wb") as f:
		writer = csv.writer(f, delimiter=',')
		for node in graph.nodes:
			writer.writerow([node])
	with open(outputs_filename, "wb") as f:
		writer = csv.writer(f, delimiter=',')
		for output in graph.outputs:
			writer.writerow([output])
	with open(edges_filename, "wb") as f:
		writer = csv.writer(f, delimiter=',')
		for edge in graph.edges():
			writer.writerow([edge[0] + 1 , edge[1] + 1])
				
#n1 = [9, 9, 2, 1, 4, 7]
#tn1 = {0: set([1, 2, 4, 5]), 1: set([0, 2]), 2: set([0, 1, 5]), 3: set([4]), 4: set([0, 3]), 5: set([0, 2])}
#n2 = [9, 2, 7]
#tn2 = {0: set([2]), 1: set([2]), 2: set([0, 1])}

#n1 = [5, 4, 6, 10, 5, 7, 8, 0, 9, 5, 1, 7, 10, 7]
#tn1 = {0: set([1, 3, 9, 7]), 1: set([0, 9, 3, 7]), 2: set([9, 3]), 3: set([0, 1, 2, 4, 5, 7, 9]), 4: set([3, 6]), 5: set([10, 3]), 6: set([8, 10, 4]), 7: set([0, 1, 3, 8, 9, 11, 12]), 8: set([9, 11, 12, 6, 7]), 9: set([0, 1, 2, 3, 7, 8, 10, 12]), 10: set([9, 5, 6, 13]), 11: set([8, 7]), 12: set([8, 9, 7]), 13: set([10])}
#n2 = [4, 10, 5, 0, 5]
#tn2 = {0: set([1, 2, 3, 4]), 1: set([0, 2, 3]), 2: set([0, 1, 3, 4]), 3: set([0, 1, 2, 4]), 4: set([0, 2, 3])}

#graph = Graph(n1, tn1)
#subgraph = Graph(n2, tn2)
#graph.mark_occurences(subgraph)
#exit(0)

parser = argparse.ArgumentParser(description='Build dataset for subgraph matching.')
parser.add_argument("-n", "--nodes_num", type=int, help="number of nodes in the graphs", default=14)
parser.add_argument("-s", "--snodes_num", type=int, help="number of nodes in the subgraph", default=5)
parser.add_argument("-g", "--graphs_num", type=int, help="number of graphs to generate", default=1)
parser.add_argument("-d", "--delta", type=float, help="probability that two nodes will be connected", default=0.2)

args = parser.parse_args()

basename = "g%ds%s" % (args.nodes_num, args.snodes_num)

subgraph = build_graph(args.snodes_num, 0.8)
save_graph("%s_sub" % basename, subgraph)

for i in range(1, args.graphs_num + 1):
	graph = build_graph(args.nodes_num, args.delta, subgraph)
	save_graph("%s_%d" % (basename, i), graph)
