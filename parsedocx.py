#!/usr/bin/env python
#coding:utf-8

# python scripts.py input output [-d|-e]

import zipfile
from lxml import etree
import sys,os,re

def listdir(path):
    for a,b,c in os.walk(path):
        for i in c:
            yield os.path.join(a,i)

if len(sys.argv) != 4:
    print "USAGE: python scripts.py input output [-c|-e]"
    sys.exit(1)
   
if sys.argv[-1] == "-e":
    if not os.path.isdir(sys.argv[2]):
        os.makedirs(sys.argv[2])
    ZipFile = zipfile.ZipFile(sys.argv[1])
    ZipFile.extractall(sys.argv[2])
    docfile = os.path.join(sys.argv[2],"word","document.xml")
    #if int(os.popen("wc -l %s"%docfile).read().strip().split()[0]) < 100:
    s = open(docfile).read()
    ele = etree.fromstring(s)
    treestring = etree.tostring(ele, pretty_print=True,encoding="utf-8",xml_declaration='<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
    f = open(docfile,"w")
    f.write(treestring)
    f.close()

elif sys.argv[-1] == "-c":
    pwd = os.getcwd()
    out = sys.argv[2] if sys.argv[2].endswith(".docx") else sys.argv[2]+".docx"
    docxfile = zipfile.ZipFile(out, mode='w', compression=zipfile.ZIP_DEFLATED)
    os.chdir(sys.argv[1])
    docfile = os.path.join("word","document.xml")
    s = open(docfile).read()
    #s = re.sub("\n\s+","",s)
    ele = etree.fromstring(s)
    treestring = etree.tostring(ele, pretty_print=True,encoding="utf-8",xml_declaration='<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
    f = open(docfile,"w")
    f.write(treestring)
    f.close()
    for f in listdir("."):
        df = f[2:]
        docxfile.write(f,df)
    os.chdir(pwd)
        
else:
    print "USAGE: python scripts.py input output [-c|-e]"
    sys.exit(1)
