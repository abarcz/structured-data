#!/usr/bin/python

"""
Generate Si Crystal structure (can be modified to generate other crystal structures)
"""

import random
import sys
import argparse

# map of [x, y, z] coords of node neighbors, according to node orientation (True, False)
EDGE_COORDS = {True : [[-1, -1, -1], [1, 1, -1], [-1, 1, 1], [1, -1, 1]], False : [[-1, 1, -1], [1, -1, -1], [-1, -1, 1], [1, 1, 1]]}

class Node:
	def __init__(self, id, coords, orientation):
		self.id = id
		self.edges = []
		self.coords = coords
		self.orientation = orientation

	def has_edge(self, coords):
		for edge in self.edges:
			if edge.coords == coords:
				return True
		return False

class Edge:
	def __init__(self, target_node, coords):
		self.target_node = target_node
		self.coords = coords

class Map3d:
	def __init__(self):
		self.map3d = {}
		self.nodes = []

	def append(self, node):
		[x, y, z] = node.coords
		if not x in self.map3d:
			self.map3d[x] = {}
		if not y in self.map3d[x]:
			self.map3d[x][y] = {}
		if z in self.map3d[x][y]:
			raise Exception("z coord exists in map")
		self.map3d[x][y][z] = node
		self.nodes.append(node)

	def __contains__(self, coords):
		[x, y, z] = coords
		return (x in self.map3d) and (y in self.map3d[x]) and (z in self.map3d[x][y])

	def __getitem__(self, coords):
		[x, y, z] = coords
		return self.map3d[x][y][z]

	def __len__(self):
		return len(self.nodes)

	def expand_nodes(self, nodes_num):
		for i in range(0, nodes_num):
			self.expand_one()

	def expand_one(self):
		candidates = self.expansion_candidates()
		if len(candidates) == 0:
			raise Exception("no nodes to expand!")
		candidate = random.choice(candidates)
		self.expand(candidate, True)
		for node in self.nodes:
			self.expand(node, False)

	def expansion_candidates(self):
		all_candidates = [n for n in self.most_connected() if len(n.edges) < 4]
		if len(all_candidates) == 0:
			return []
		max_edges = len(all_candidates[0].edges)
		best_candidates = [n for n in all_candidates if len(n.edges) == max_edges]
		return best_candidates

	def most_connected(self):
		return sorted(self.nodes, key=lambda n : len(n.edges))

	def expand(self, node, create_nodes):
		new_orientation = not node.orientation
		for i in range(0, 4):
			edge_coords = EDGE_COORDS[node.orientation][i]
			new_coords = [x + y for x, y in zip(node.coords, edge_coords)]
			if new_coords in self:
				target_node = self[new_coords]
			else:
				if not create_nodes:
					continue
				new_id = len(self.nodes) + 1
				target_node = Node(new_id, new_coords, new_orientation)
				self.append(target_node)
			if not node.has_edge(edge_coords):
				reverse_edge_coords = [-i for i in edge_coords]
				edge = Edge(target_node, edge_coords)
				reverse_edge = Edge(node, reverse_edge_coords)
				node.edges.append(edge)
				target_node.edges.append(reverse_edge)

	def to_file(self, name, node_label, edge_label, coord_scale):
		nodes_filename = name + "_nodes.csv"
		edges_filename = name + "_edges.csv"
		output_filename = name + "_output.csv"
		with open(nodes_filename, 'w') as nodes_file:
			with open(edges_filename, 'w') as edges_file:
				for node in self.nodes:
					nodes_file.write("%s\n" % (node_label))
					for edge in node.edges:
						target_id = edge.target_node.id
						[x, y, z] = [i * coord_scale for i in edge.coords]
						edges_file.write("%d,%d,%f,%f,%f,%s\n" % (node.id, target_id, x, y, z, edge_label))
		with open(output_filename, 'w') as f:
			f.write("1\n")


parser = argparse.ArgumentParser(description='Creates a Si crystal structure graph.')
parser.add_argument("-n", "--nodes", type=int, help="number of nodes to be expanded", default=1)
parser.add_argument("-f", "--file", type=str, help="number of graphs to generate", default="test")

args = parser.parse_args()

map3d = Map3d()

start = Node(1, [0,0,0], True)
map3d.append(start)

map3d.expand_nodes(args.nodes)

node_label = "2,2,6,2,2,1.84,4.8,0"	# 1s2 2s2 2p6 3s2 3p2, 1.84, 4.8, 0 (number of electrons for e.g. V-)
edge_label = "2"	# number of electron bindings
coord_scale = 1.36	# calculated from 5.43

map3d.to_file(args.file, node_label, edge_label, coord_scale)
