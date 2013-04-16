#!/usr/bin/python

import argparse
import os
import re
import sys
from os.path import join, getsize

"""
For each .m file in given directory (and subdirs),
replace 'usage' line in header comment by appropriate usage line
"""

def printerr(string):
	sys.stderr.write("ERROR: " + string + '\n')

def printwarn(string):
	print "WARNING: " + string

def check_recursive(top_dir):
	reg_mfile = re.compile("^.*\.m$")
	for root, dirs, files in os.walk(top_dir):
		for filename in files:
			if reg_mfile.match(filename):
				check_comments(join(root, filename))

def check_comments(filepath):
	reg_empty_line = re.compile("^\s*$")
	reg_comment = re.compile("^%.*$")
	reg_function = re.compile("^function\s+(?P<declaration>.*)\s*$")
	reg_usage = re.compile("^%\s*usage\s*:.*$")
	with open(filepath) as f:
		lines = f.readlines()
	function = None
	for index in range(len(lines)):
		line = lines[index]
		line = line.strip('\n')
		if function == None:
			if reg_empty_line.match(line):
				continue
			res = reg_function.match(line)
			if res == None:
				printerr("File '%s' contains a non-function line as first line:\n%s" % (filepath, line))
				return
			else:
				function = res.group('declaration')
		else:
			res = reg_usage.match(line)
			if res == None:
				if reg_comment.match(line):
					continue
				else:
					printwarn("File '%s' doesn't contain usage line" % filepath)
					return
			else:
				lines[index] = "% usage: " + function + '\n'
				print "+ corrected usage in '%s'" % filepath
				contents = "".join(lines)
				with open(filepath, 'w') as f:
					f.write(contents)
				return
	if function == None:
		printerr("No function declaration in '%s'" % filepath)
		return

parser = argparse.ArgumentParser(description='checks help comments in .m files and assure correct usage information is present')
parser.add_argument("src_dir", help="directory to scan for .m files (recursively)")

args = parser.parse_args()

check_recursive(args.src_dir)
