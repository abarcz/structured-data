#!/bin/bash

n=8
g="_"
v=""

for i in 1 2 3 4 5 6 7 8 9 10
do
	echo $i
	./gensi.py -f "../data/si/n$n$v$g$i" -n $n
done
