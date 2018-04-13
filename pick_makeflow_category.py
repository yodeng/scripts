#!/usr/bin/env python
#coding:utf-8
## 将所有的makeflow按程序单位分开，根据关键字提取各单位
import sys,re
if len(sys.argv) == 1:
    print "USAGE:python script.py Makeflow STRING1 STRING2 STRING3 ... [-or|-and] > pick_output 2> no_pick_out"
    sys.exit(1)
from collections import OrderedDict
flow_d = OrderedDict()
f = open(sys.argv[1],"r").read()
flow_tuple = zip(re.findall("CATEGORY=.+?\n",f),re.split("CATEGORY=.+?\n",f)[1:])
if sys.argv[-1] == "-or":
    for c in flow_tuple:   
        if any([k in c[0]+c[1] for k in sys.argv[2:-1]]):
                sys.stdout.write(c[0] + c[1])
        else:
                sys.stderr.write(c[0] + c[1])
elif sys.argv[-1] == "-and":
    for c in flow_tuple:
        if all( [k in c[0]+c[1] for k in sys.argv[2:-1]]):
            sys.stdout.write(c[0] + c[1])
        else:
            sys.stderr.write(c[0] + c[1])

else:
    if len(sys.argv) == 3:
        for c in flow_tuple:
            if sys.argv[2] in c[0]+c[1]:
                sys.stdout.write(c[0] + c[1])
            else:
                sys.stderr.write(c[0] + c[1])
    else:
        print "USAGE:python script.py Makeflow STRING1 STRING2 STRING3 ... [-or|-and] > pick_output 2> no_pick_out"
        sys.exit(1)

