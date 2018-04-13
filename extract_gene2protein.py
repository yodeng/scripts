#!/usr/bin/env python
#coding:utf-8
import re,sys
r = re.compile('gene_id "(.+?)";.*?protein_id "(.+?)";')
txt = {}
with open(sys.argv[1],"r") as gtf:
	for line in gtf:
		if r.search(line):
			txt.setdefault(r.search(line).group(1),set()).add(r.search(line).group(2))
with open(sys.argv[2],"w") as fo:
	for gene,pro in txt.items():
		pro = ",".join(list(pro)) if len(pro) >1 else pro.pop()
		fo.write(gene + "\t" + pro + "\n")

			
