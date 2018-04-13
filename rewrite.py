#!/usr/bin/env python
#coding:utf-8
'''
重新改写fasta序列格式为标准的序列格式，序列字母全部改为大写
rewrite.py input_fasta out.fa [1]   "1"表示单行模式的fasta写入
#### 直接读取文件，同时将缓存立刻写入文件，速度更快，更节省内存。
'''
import sys,os

if len(sys.argv) != 4 and len(sys.argv) != 3:
	print "rewrite.py input_fasta out.fa [1]"
        exit(0)
if sys.argv[1] == sys.argv[2]:
	sys.argv[2] = sys.argv[1] + ".tmp"         ### ！！！避免当输入文件和输出文件名相同时，会清空输入文件内容，导致数据丢失

from Bio import SeqIO
	
if sys.argv[-1] == "1":                     ####单行模式的Fasta文件写入
	with open(sys.argv[2],"w") as f2:
		for i in SeqIO.parse(sys.argv[1],"fasta"):
			f2.write(">" + i.description + "\n")
			f2.write(str(i.seq.upper()) + "\n" )                 ## seq对象需转换为字符串对象才能与"\n"合并
else:
    with open (sys.argv[2],"w") as o1:
		for i in SeqIO.parse(sys.argv[1],"fasta"):
			SeqIO.write(i.upper(),o1,"fasta")		

if sys.argv[2] == sys.argv[1] + ".tmp":             
	os.rename(sys.argv[2],sys.argv[1])            ### ！！！避免当输入文件和输出文件名相同时，会清空输入文件内容，导致数据丢失