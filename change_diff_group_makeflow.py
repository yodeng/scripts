#!/usr/bin/env py
#coding:utf-8
## 当修改分组名之后重新运行相关步骤，生成新的最少运行的makeflow文件。
### 先修改config文件，添加新的差异比较分组，然后生成新的makeflow文件
import os,sys
from collections import OrderedDict
if len(sys.argv) == 1:
	print '''USEAGE: python scripts.py GROUP1-VS-GROUP2
### before this program, you must DO:
### mv makeflow.sh makeflow.sh.old;mv Makeflow_new Makeflow_new.old  ## if an old makeflow.sh or Makeflow_new file exists
### perl /lustre/work/zhonghuali/software/rna.ref/bin/creat.all.makeflow.pl -config NEW_config.txt -od ./ -name Makeflow_new            ## if used normal_REf flow
### perl /lustre/work/zhonghuali/software/rna.ref/annoblastbin/creat.all.makeflow.pl -config NEW_config.txt -od ./ -name Makeflow_new   ## if used blast_REf flow
### bash makeflow.sh'''
	sys.exit(0)

# perl_cmd = 'perl /lustre/work/zhonghuali/software/rna.ref/bin/creat.all.makeflow.pl -config ' + sys.argv[1]  + ' -od ./ -name Makeflow_new; bash makeflow.sh;'
# os.popen(perl_cmd)

new_diff = sys.argv[1]

flow_d = OrderedDict()
with open("Makeflow_new","r") as flow:
	v = []
	for line in flow:
		if line.startswith("CATEGORY="):
			k = line
			if len(v):
				flow_d.setdefault(keys,[]).append(v)
			v = []
		else:
			v.append(line)
			keys = k
	flow_d.setdefault(keys,[]).append(v)

fo = open("Makeflow_diff","w")
for k,v in flow_d.items():
	for command in v:
		commands = "".join(command)
		if new_diff in commands:              ## new_diff为新的差异比较分组 group1-VS-group2
			fo.write(k + commands)
fo.close()