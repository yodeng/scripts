#!/usr/bin/env python
#coding:utf-8
### 支持加减乘除指数余数
import sys,re
r = re.compile("[+-/*^%]")
s = "".join(sys.argv[1:])
s = s.replace(" ","")
if r.search(s):
    l = r.split(s)[0]
    s = s.replace(l,"%f"%float(l),1)
    print eval(s)
