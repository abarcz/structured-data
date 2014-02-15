#!/usr/bin/python

from os import listdir
from subprocess import Popen, PIPE
import re

"""
Print usage information about all Octave functions in the current dir
"""

reg = re.compile("^(?P<name>.*)\.m$")

usage = {}
files_num = {}
for filename in listdir('.'):
	if reg.match(filename):
		function_name = reg.search(filename).group('name')
		stdout, stderr = Popen("grep -l " + function_name + "\( *", shell=True, stdout=PIPE).communicate()
		filenames = stdout.rstrip('\n').split('\n')
		usage[function_name] = []
		for name in filenames:
			if name != filename:
				usage[function_name].append(name)
		files_num[function_name] = len(usage[function_name])

for key, value in sorted(files_num.iteritems(), key=lambda (k,v): (v,k)):
	print "* " + key + ": " + str(usage[key])
