#!/usr/bin/python

import argparse
import csv
import pygraphviz as pgv

"""
Draw graph to .png file
"""

def build_label(values):
	label = ",".join(format(float(x), ".0f") for x in values)
	return label

def loadgraph(name):
	graph = pgv.AGraph(directed=True)
	with open("%s_nodes.csv" % name, 'rb') as f:
		reader = csv.reader(f)
		count = 1
		for row in reader:
			graph.add_node(count)
			graph.get_node(count).attr['label'] = str(count) + ": " + build_label(row)
			count = count + 1
	with open("%s_edges.csv" % name, 'rb') as f:
		reader = csv.reader(f)
		for row in reader:
			graph.add_edge(row[0], row[1])
			graph.get_edge(row[0], row[1]).attr['label'] = build_label(row[2:])
	return graph

parser = argparse.ArgumentParser(description='Draw graph to <name>.png using input .csv files and graphviz')
parser.add_argument("name", help="graph name, i.e. <name> from <name>_nodes.csv")

args = parser.parse_args()

graph = loadgraph(args.name)
graph.layout()
graph.draw('%s.png' % args.name, prog='circo')
