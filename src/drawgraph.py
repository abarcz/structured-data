#!/usr/bin/python

import argparse
import csv
import pygraphviz as pgv
import os

"""
Draw graph to .png file
"""

def build_label(values, decimals_num=0):
	label = ",".join(format(float(x), ".%df" % decimals_num) for x in values)
	return label

def loadgraph(name, add_node_ids, directed, mark, edge_labels, decimals_num):
	graph = pgv.AGraph(directed=directed)
	with open("%s_nodes.csv" % name, 'rb') as f:
		reader = csv.reader(f)
		count = 1
		for row in reader:
			graph.add_node(count)
			node_label = build_label(row, decimals_num)
			if add_node_ids:
				node_label = str(count) + ": " + node_label
			graph.get_node(count).attr['label'] = node_label
			count = count + 1
	outputs_filename = "%s_output.csv" % name
	if os.path.isfile(outputs_filename):
		with open(outputs_filename, 'rb') as f:
			reader = csv.reader(f)
			count = 1
			for row in reader:
				if row[0] == mark:
					graph.get_node(count).attr["fillcolor"] = "black"
					graph.get_node(count).attr["fontcolor"] = "white"
					graph.get_node(count).attr["style"] = "filled"
				count = count + 1
	with open("%s_edges.csv" % name, 'rb') as f:
		reader = csv.reader(f)
		edges = set()
		for row in reader:
			if not directed and (row[1], row[0]) in edges:
				continue
			edges.add((row[0], row[1]))
			graph.add_edge(row[0], row[1])
			if edge_labels:
				graph.get_edge(row[0], row[1]).attr['label'] = build_label(row[2:], decimals_num)
	return graph

parser = argparse.ArgumentParser(description='Draw graph to <name>.png using input .csv files and graphviz')
parser.add_argument("name", help="graph name, i.e. <name> from <name>_nodes.csv")
parser.add_argument("-i", "--node_ids", help="add to each node its id (position in nodes file)", default=False, action="store_true")
parser.add_argument("-u", "--undirected", help="should we draw the graph as directed", default=False, action="store_true")
parser.add_argument("-e", "--edge_labels", help="should we draw edge labels", default=False, action="store_true")
parser.add_argument("-m", "--mark", help="use to mark differently nodes with given output[0]", type=str)
parser.add_argument("-d", "--decimals", help="number of digits after decimal point to be included in labels", default=0, type=int)

args = parser.parse_args()

graph = loadgraph(args.name, args.node_ids, not args.undirected, args.mark, args.edge_labels, args.decimals)
graph.layout()
graph.draw('%s.png' % args.name, prog='circo')
