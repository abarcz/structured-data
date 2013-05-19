#!/bin/bash

for VAR in {1..9}
do
	xfig -exportLanguage svg $1$VAR.fig
done
