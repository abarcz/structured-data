#!/usr/bin/python

"""
Reads xml file (preferably preprocessed with grep),
containing entries of form <sequence length=".." .... >TEXT</sequence>,
where TEXT is an aminoacid sequence.

Original XML can be dowloaded from:
http://www.ebi.ac.uk/uniprot/download-center
ftp://ftp.ebi.ac.uk/pub/databases/uniprot/knowledgebase/uniprot_sprot.xml.gz
"""

import re
import argparse
import random

def read_uniprot_sequences(filename, maxlen):
	with open(filename) as f:
		lines = f.readlines()
	reg_seq = re.compile('<sequence [^>]*>(?P<seq>[A-Z]+)</sequence>')
	sequences = []
	for line in lines:
		res = reg_seq.search(line)
		if res != None:
			sequence = res.group('seq')
			if len(sequence) < maxlen:
				sequences.append(sequence)
	return list(set(sequences))

def select_sequences(sequences, existing_sequences, maxnum):
	selected = []
	while len(selected) < maxnum:
		index = random.randint(0, len(sequences) - 1)
		seq = sequences[index]
		if not seq in selected:
			if not seq in existing_sequences:
				selected.append(seq)
	return selected
	
def read_existing_sequences(filename):
	with open(filename) as f:
		lines = f.readlines()
	sequences = []
	for line in lines:
		sequences.append(line.rstrip('\n'))
	return sequences


parser = argparse.ArgumentParser(description='creates file uniprot.neg containing unique samples not already in POSFILE')
parser.add_argument("filename", help="file to be read")
parser.add_argument("-l", "--maxlen", help="max sequence length", type=int, required=True)
parser.add_argument("-n", "--maxnum", help="max number of sequences", type=int, required=True)
parser.add_argument("-P", "--posfile", help="file with existing positive samples", type=str, required=True)

args = parser.parse_args()

existing_sequences = read_existing_sequences(args.posfile)
print "Read %d existing sequences from '%s'" % (len(existing_sequences), args.posfile)

sequences = read_uniprot_sequences(args.filename, args.maxlen)
print "Read %d unique sequences from '%s' with max length %d" % (len(sequences), args.filename, args.maxlen)

selected = random.sample(sequences, args.maxnum)
print "Selected %d sequences not appearing in '%s' and wrote them to 'uniprot.neg'" % (len(selected), args.posfile)

with open("uniprot.neg", "w") as f:
	for sequence in selected:
		f.write(sequence + '\n')
