#!/usr/bin/env python
#coding:utf-8
#
import sys,os.path
input_file,out_file,result_file,need_file,no_file = set(),set(),set(),set(),set()
with open(sys.argv[1],"r") as f:
	for line in f:
		line = line.rstrip()
		if ":" in line and line.startswith("/"):
			line = line.replace("\\","")
			out = line.split(":")
			for i in out[0].split():
				if "results" in i:
					result_file.add(i)
				else:
					out_file.add(i)
			for i in out[1].split():
				if "results" in i:
					result_file.add(i)
				else:
					input_file.add(i)
		else:
			continue

need_file = input_file.difference(out_file,result_file)

for i in need_file:
	if os.path.exists(i):
		continue
	else:
		no_file.add(i)

if len(no_file):
	for i in no_file:
		print i + "\t Not Exists!"
else:
	print "All need files exists, OK!"
	
