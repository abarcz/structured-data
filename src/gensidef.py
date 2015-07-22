#!/usr/bin/python

"""
Using the Si primitive cell, generate a dataset containing a given type of defect on a single position in the cell
"""

from copy import deepcopy
import argparse

"""
Illustration of atom enumeration in diamond crystal structure.
* there are 1..18 atoms in the primitive cell
* crystal is presented as the bottom and top slice (seen from above)
* each slice consists of three levels:
. denotes the most bottom atom in the slice
- denotes the medium level atom in the slice
^ denotes the top level atom in the slice
* 10,11,9,8 connect the two parts together
* 15,16,17,18 aren't connected to any atom in the cell and therefore can be ommited

bottom slice:

4.    10^    16.
  \  /
   6-
  /  \ 
11^    5.    9^
         \  /
          7-
		 /  \
18.    8^    2.


top slice:

17^   10.    3^
        \   /
         13-
		/   \
11.    1^    9.
  \  /
   12-
  /  \
14^    8.   15^

"""

# old_conn was numerated layer-by-layer but had to be renumerated to make sure that the not-connected atoms are enumerated as the last ones
# atoms in connections are enumerated from 1!
#old_conn   = [(4,6), (6,5), (5,7), (7,2), (11,6), (6,10), (8,7), (7,9), (11,12), (12,8), (10,13), (13,9), (14,12), (12,18), (18,13), (13,16)]
connections = [(4,6), (6,5), (5,7), (7,2), (11,6), (6,10), (8,7), (7,9), (11,12), (12,8), (10,13), (13,9), (14,12), (12, 1), (1, 13), (13, 3)]

n_atoms = 14	# numbers 1..14

# 0:    atomic radius (Kittel p. 119 - tetraedric atomic radius)
# 1..5: electron shells description (Wikipedia)
# 6:    energy gap (various sources)
# 7..9: lattice constants (http://periodictable.com/Elements/014/data.html)
element_properties = {
'Si' : [1.17, 2, 8,  4,  0, 0, 1.12,  543.09, 543.09,  543.09],
'P'  : [1.10, 2, 8,  5,  0, 0, 2.10, 1145.00, 550.30, 1126.10],
'As' : [1.18, 2, 8, 18,  5, 0, 1.20,  375.98, 375.98, 1054.75],
'Sb' : [1.36, 2, 8, 18, 18, 5,    0,  430.70, 430.70, 1127.30]
}

# ionization energy = additional energy level
# every impurity adds only one level
ionization_energy_in_si = {
'Si' : 0,
'P'  : 0.044,
'As' : 0.049,
'Sb' : 0.039
}


def write_file(array, filename):
	with open(filename, 'w') as f:
		for row in array:
			row_size = len(row)
			for i in range(0, row_size):
				f.write(str(row[i]))
				if i < (row_size - 1):
					f.write(',')
			f.write('\n')


"""
Generate a set of crystals, each one containing the impurity on one of the positions 1..14
"""
def generate_crystals(impurity, directory):
	assert(impurity in element_properties.keys())
	# prepare base Si cell
	original_node_labels = []
	output = []
	for i in range(0, n_atoms):
		original_node_labels.append(element_properties['Si'])
		output.append([ionization_energy_in_si[impurity]])	# each element in array for write_file to work
	
	path = directory.rstrip("/") + "/" + "Si_" + impurity + "_"

	if impurity == 'Si':
		filename = path
		write_file(original_node_labels, filename + "nodes.csv")
		write_file(connections, filename + "edges.csv")
		write_file(output, filename + "output.csv")
		return

	# generate all possible impure cells
	for i in range(0, n_atoms):
		filename = path + str(i) + "_"
		node_labels = deepcopy(original_node_labels)
		node_labels[i] = element_properties[impurity]
		write_file(node_labels, filename + "nodes.csv")
		write_file(connections, filename + "edges.csv")
		write_file(output, filename + "output.csv")


parser = argparse.ArgumentParser(description='Creates a Si dataset with given impurity.')
parser.add_argument("-d", "--dir", type=str, help="output directory", default=None)
parser.add_argument("-i", "--impurity", type=str, help="impurity to use: As, Sb, P", default=None)
parser.add_argument("-a", "--all", help="generate all (including no impurity single crystal)", action="store_true")

args = parser.parse_args()

if args.all:
	for impurity in element_properties.keys():
		generate_crystals(impurity, args.dir)
else:
	generate_crystals(args.impurity, args.dir)
