#!/usr/bin/env python
#coding:utf-8
### 返回给定路径的大小
import os,sys

def listdir3(path):
    f = []
    for a,b,c in os.walk(path):
        for i in c:
            f.append(os.path.join(a,i))
    return f

for path in sys.argv[1:]:
    if os.path.isfile(path):
        s = os.path.getsize(path)
        kb = round(float(s)/1024 + 0.05,1)
        mb = round(float(s)/1024/1024 + 0.05,1)
        gb = round(float(s)/1024/1024/1024 + 0.005,2)
        print "'%s' File Size: %.2fGB, %.1fMB, %.1fKB" %(os.path.normpath(path),gb,mb,kb)
        continue
    if not os.path.exists(path):
        print "%s Not Exists" %path
        continue
    filename = listdir3(path)
    if not len(filename):
        print "No file in %s" %path
        continue
    else:
        s = 0
        for f in filename:
            s += os.path.getsize(f)
        kb = round(float(s)/1024 + 0.05,1)              ### 向上取小数
        mb = round(float(s)/1024/1024 + 0.05,1)
        gb = round(float(s)/1024/1024/1024 + 0.005,2)
        print "'%s' Directory Size: %.2fGB, %.1fMB, %.1fKB" %(os.path.normpath(path),gb,mb,kb)
    