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
		self.special = False

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
		while 1:
			candidates, max_score = self.addition_candidates()
			if max_score <= 1:
				break
			self.append(candidates[0])
			for node in self.nodes:
				self.expand(node, False)

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
		return sorted(self.nodes, key=lambda n : len(n.edges), reverse=True)

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

	def add_nodes(self, nodes_num):
		for i in range(0, nodes_num):
			self.add_one()
		while 1:
			candidates, max_score = self.addition_candidates()
			if max_score <= 1:
				break
			self.append(candidates[0])
			for node in self.nodes:
				self.expand(node, False)

	def add_one(self):
		candidates, max_score = self.addition_candidates()
		if len(candidates) == 0:
			raise Exception("no nodes to expand!")
		candidate = random.choice(candidates)
		self.append(candidate)
		for node in self.nodes:
			self.expand(node, False)

	def addition_candidates(self):
		best_candidates = []
		max_score = 0
		for node in self.nodes:
			for new_node in self.possible_neighbors(node):
				score = self.existing_neighbors_count(new_node)
				if score > max_score:
					max_score = score
					best_candidates = [new_node]
				elif score == max_score:
					best_candidates.append(new_node)
		return best_candidates, max_score

	def possible_neighbors(self, node):
		new_orientation = not node.orientation
		neighbors = []
		for i in range(0, 4):
			edge_coords = EDGE_COORDS[node.orientation][i]
			new_coords = [x + y for x, y in zip(node.coords, edge_coords)]
			if not new_coords in self:
				new_id = len(self.nodes) + 1
				target_node = Node(new_id, new_coords, new_orientation)
				neighbors.append(target_node)
		return neighbors

	def existing_neighbors_count(self, node):
		new_orientation = not node.orientation
		count = 0
		for i in range(0, 4):
			edge_coords = EDGE_COORDS[node.orientation][i]
			new_coords = [x + y for x, y in zip(node.coords, edge_coords)]
			if new_coords in self:
				count = count + 1
		return count

	def to_file(self, name, node_label, edge_label, coord_scale, output, vnode_label=None, vedge_label=None):
		nodes_filename = name + "_nodes.csv"
		edges_filename = name + "_edges.csv"
		output_filename = name + "_output.csv"
		with open(nodes_filename, 'w') as nodes_file:
			with open(edges_filename, 'w') as edges_file:
				for node in self.nodes:
					curr_node_label = node_label
					if node.special:
						curr_node_label = vnode_label
					nodes_file.write("%s\n" % (curr_node_label))
					for edge in node.edges:
						target_id = edge.target_node.id
						[x, y, z] = [i * coord_scale for i in edge.coords]
						curr_edge_label = edge_label
						if node.special or edge.target_node.special:
							curr_edge_label = vedge_label
						edges_file.write("%d,%d,%f,%f,%f,%s\n" % (node.id, target_id, x, y, z, curr_edge_label))
		with open(output_filename, 'w') as f:
			f.write("%s\n" % output)

	def add_vacancy(self, vacancy):
		candidates = [node for node in self.nodes if len(node.edges) == 4]
		if len(candidates) == 0:
			raise Exception("No candidate for vacancy")
		print "choosing candidate for vacancy..."
		while 1:
			candidate1 = random.choice(candidates)
			candidate2 = random.choice(candidate1.edges).target_node
			if len(candidate2.edges) == 4:
				break
		candidate1.special = vacancy
		candidate2.special = vacancy
		print "done"


parser = argparse.ArgumentParser(description='Creates a Si crystal structure graph.')
parser.add_argument("-n", "--nodes", type=int, help="number of nodes to be expanded", default=1)
parser.add_argument("-f", "--file", type=str, help="number of graphs to generate", default="test")
parser.add_argument("-a", "--add", help="use add method", action="store_true")
parser.add_argument("-v", "--vacancy", type=str, help="type of vacancy to insert", default=None)

args = parser.parse_args()

map3d = Map3d()

start = Node(1, [0,0,0], True)
map3d.append(start)

if args.add:
	map3d.expand_one()
	map3d.add_nodes(args.nodes)
else:
	map3d.expand_nodes(args.nodes)

print "created %d nodes" % (len(map3d.nodes))

node_label    = "2,2,6,2,2,1.84,4.8,0"	# 1s2 2s2 2p6 3s2 3p2, 1.84, 4.8, 0 (number of electrons for e.g. V-)
edge_label    = "2"	# number of electron bindings
coord_scale   = 1.36	# calculated from 5.43

# special node labels
labels = {}
labels["V2+"] = "0,0,0,0,0,0   ,0, -1"	# V2 +
labels["V20"] = "0,0,0,0,0,0   ,0,  0"	# V2 0
labels["V2-"] = "0,0,0,0,0,0   ,0,  1"	# V2 -
labels["V22-"]= "0,0,0,0,0,0   ,0,  2"	# V2 2-
for key, label in labels.items():
	assert(len(label.split(",")) == len(node_label.split(",")))
if args.vacancy:
	assert(args.vacancy in labels.keys())
	map3d.add_vacancy(args.vacancy)

output         = "-1" #"0,0"	# Ec - level and Ev + level
outputs = {}
outputs["V2+"] = "-1" #"0,0"
outputs["V20"] = "1" # "0,0.25"
outputs["V2-"] = "1" # "-0.42,0"
outputs["V22-"]= "1" #"-0.23,0"
for key, label in outputs.items():
	assert(len(label.split(",")) == len(output.split(",")))
	assert(key in labels.keys())

edge_vacancy_label = "0"
assert(len(edge_vacancy_label.split(",")) == len(edge_label.split(",")))

if args.vacancy:
	map3d.to_file(args.file, node_label, edge_label, coord_scale, outputs[args.vacancy], labels[args.vacancy], edge_vacancy_label)
else:
	map3d.to_file(args.file, node_label, edge_label, coord_scale, output)
