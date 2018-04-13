#!/usr/bin/env python
import sys,os
def listdir(path):
    for a,b,c in os.walk(path):
        for i in c:
            yield os.path.abspath(os.path.join(a,i))

filenext = listdir(sys.argv[1])
with open("uninvalid_linkfile.txt","w") as fo:
    for f in filenext:
        if os.path.islink(f) and not os.path.exists(os.path.realpath(f)):
            fo.write("rm -fr %s\n"%f)
        
