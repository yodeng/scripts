#!/usr/bin/env python
#coding:utf-8
# copy_tree.py 
import sys,os

def getsubdir(path):
    for a,b,c in os.walk(path):
        for i in b:
            yield os.path.join(a,i)
            
def main():
    if not os.path.isdir(sys.argv[1]):
        print "%s is not a dir or not exists" % sys.argv[1]
        sys.exit(1)
    for p in getsubdir(sys.argv[1]):
        if not p:
            print "No subdir in %s"%sys.argv[1]
            sys.exit(1)
        d = os.path.join(sys.argv[2],p[p.find("/")+1:])
        if not os.path.exists(d): os.makedirs(d)
        
if __name__ == "__main__":
    main()
        