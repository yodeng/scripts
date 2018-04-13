#!/usr/bin/env python
#coding:utf-8
import sys,os,time

def getday(path):
    return time.strftime("%Y%m%d",time.localtime(os.path.getmtime(path)))
    
def getsize(path):
    fsize = os.path.getsize(path)
    fsize = fsize/float(1024*1024)
    return fsize

for a,b,c in os.walk(sys.argv[1]):
    for i in c:
        f = os.path.abspath(os.path.join(a,i))
        try:
            if int(getday(f)) >= 20180108 and getsize(f) > 500:
                print f,getday(f),str(getsize(f))+"MB"
        except:
            #print f + " symbolic not exist!"
            pass
