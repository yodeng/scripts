#!/usr/bin/env python
#coding:utf-8
#### 合并htseq-ocunt的单独文件为一个文件
### USAGE: python scripts.py htseq-ocunt-file... out_file
import sys,os
if len(sys.argv) == 1:
    print "USAGE: python scripts.py htseq-ocunt-file... out_file"
    sys.exit(0)
from collections import OrderedDict
a = OrderedDict()
for f in sys.argv[1:-1]:
    with open(f) as fi:
        for line in fi:
            a.setdefault(line.split()[0],[]).append(line.split()[1])
in_file = map(lambda x:os.path.splitext(os.path.basename(x))[0],sys.argv[1:-1])
with open(sys.argv[-1],"w") as fo:
    fo.write("gene_id\t" + "\t".join(in_file) + "\n")
    for k,v in a.items():
        fo.write(k + "\t" + "\t".join(v) + "\n")
