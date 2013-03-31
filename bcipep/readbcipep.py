#!/usr/bin/python

"""
Read bcipep database, generate .pos and .neg files
Data has been generated from the non-redundant set.

Original data can be downloaded from:
http://www.imtech.res.in/raghava/bcipep/data.html
http://www.imtech.res.in/raghava/bcipep/download/redundant_bcipep.tar.gz
"""

import re
import argparse

def get_entries(filename):
	with open(filename) as f:
		contents = f.read()
	entries = contents.split('\\')
	reg_seq = re.compile("Sequence", re.MULTILINE)
	filtered_entries = []
	for entry in entries:
		if reg_seq.search(entry):
			filtered_entries.append(entry)
	return filtered_entries

def select_immunogenic(entries, immunogenic=True):
	if immunogenic:
		select_string = "(High|Yes)"
	else:
		select_string = "(No)"
	reg_imm = re.compile("Immunogenicity\s+" + select_string, re.MULTILINE)
	filtered_entries = []
	for entry in entries:
		if reg_imm.search(entry):
			filtered_entries.append(entry)
	print ("Selected %d '" + select_string + "' entries") % len(filtered_entries)
	return filtered_entries

def get_unique_sequences(entries):
	reg_seq = re.compile("^Sequence\s+(?P<seq>[A-Z]+)$", re.MULTILINE)
	sequences = []
	for entry in entries:
		res = reg_seq.search(entry)
		if res != None:
			seq = res.group("seq")
			sequences.append(seq)
	sequences = list(set(sequences))
	print "Got %d unique sequences" % len(sequences)
	return sequences

def get_maxlen_sequences(sequences, maxlen):
	filtered_sequences = []
	for seq in sequences:
		if len(seq) <= maxlen:
			filtered_sequences.append(seq)
	print "Got %d unique sequences of length <= %d" % \
		(len(filtered_sequences), maxlen)
	return filtered_sequences

parser = argparse.ArgumentParser(description='Create bcipep.pos and bcipep.neg, containing unique samples from bcipep file')
parser.add_argument("filename", help="file to be read")
parser.add_argument("-l", "--maxlen", help="max sequence length", type=int)

args = parser.parse_args()
entries = get_entries(args.filename)

print "Read %d entries" % len(entries)
pos_entries = select_immunogenic(entries, True)
pos_sequences = get_unique_sequences(pos_entries)
if args.maxlen:
	pos_sequences = get_maxlen_sequences(pos_sequences, args.maxlen)

neg_entries = select_immunogenic(entries, False)
neg_sequences = get_unique_sequences(neg_entries)
if args.maxlen:
	neg_sequences = get_maxlen_sequences(neg_sequences, args.maxlen)

with open("bcipep.pos", "w") as f:
	for seq in pos_sequences:
		f.write(seq + '\n')
with open("bcipep.neg", "w") as f:
	for seq in neg_sequences:
		f.write(seq + '\n')
