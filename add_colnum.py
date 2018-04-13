#!/usr/bin/env python
#coding:utf-8
import sys
d = {}
with open(sys.argv[1]) as fi:
    header = fi.next().strip().split("\t")[1:]
    for line in fi:
        l = line.strip().split("\t")
        d[l[0]] = l[1:]
for filename in sys.argv[2:]:
    with open(filename) as f1,open(filename+".txt","w") as f2:
        head = f1.next().strip()
        f2.write(head + "\t" + "\t".join(header) + "\n")
        for line in f1:
            k = line.split("\t")[0]
            if d.has_key(k):
                f2.write(line.strip("\n") + "\t" + "\t".join(d[k]) + "\n")
            else:
                f2.write(line.strip("\n") + "\t" + "\t".join(["-"]*len(header)) + "\n")
