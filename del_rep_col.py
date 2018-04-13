#!/usr/bin/env pypy
#coding:utf-8
### 去除某一列又重复的所有行
# python scripts.py filename column_number
import os,sys

rep_col = os.popen('cut -f' + sys.argv[2] + " " + sys.argv[1] + ' |sort |uniq -d').read().split()
with open(sys.argv[1],"r") as f,open(sys.argv[1]+".norep","w") as fo:
	for line in f:
		col = line.rstrip("\n").split("\t")[int(sys.argv[2])-1]
		if not col or col in rep_col:
			continue
		else:
			fo.write(line)