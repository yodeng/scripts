#!/usr/bin/env python
#coding:utf-8
#
import sys,os.path
input_file,out_file,result_file,need_file,no_file = [],[],[],[],[]
with open(sys.argv[1],"r") as f:
	for line in f:
		line = line.rstrip()
		if ":" in line and line.startswith("/"):
			out = line.split(":")
			for i in out[0].split():
				if "results" in i:
					result_file.append(i)
				else:
					out_file.append(i)
			for i in out[1].split():
				if "results" in i:
					result_file.append(i)
				else:
					input_file.append(i)
		else:
			continue

for i in input_file:
	if i in out_file + result_file:
		continue
	else:
		need_file.append(i)

input_file = list(set(input_file))
out_file = list(set(out_file))
result_file = list(set(result_file))

for i in need_file:
	if os.path.exists(i):
		continue
	else:
		no_file.append(i)

if len(no_file):
	for i in no_file:
		print i + "\t Not Exists!"
else:
	print "All need files exists, OK!"
	
