#!/usr/bin/env pypy
#coding:utf-8
## 备份某个目录下的所有以.py结尾的文件到指定目录，并保持其目录结构
import os,sys
from collections import  Counter
### 修改列表中的元素，重复出现的元素，添加序号".n"
def modify_list_v1(li_source):    ## 需事先定义好函数pick_index
	li = li_source[:]
	counter_li = Counter(li)
	gt_count_1 = dict(filter(lambda x:x[1]>1,counter_li.items()))
	for i in gt_count_1.keys():
		n = 1
		for index in pick_index(i,li):
			li[index] += "." + str(n)
			n += 1
	return li

def modify_list_v2(li_source):      ## 需事先定义好函数pick_index
	li = li_source[:]
	gt_count_1 = set([ i for i in li if li.count(i) > 1])
	for i in gt_count_1:
		n = 1
		for index in pick_index(i,li):
			li[index] += "." + str(n)
			n += 1
	return li
	
## 提取列表中某一个元素出现的所有位置
def pick_index(s,list_s):  
	if s not in list_s:
		return
	return [i for (i,j) in enumerate(list_s) if j == s]
	
def modify_pick(li_source):
	li = li_source[:]
	rep_i = set([ i for i in li if li.count(i) > 1])
	if not len(rep_i):
		return li
	for i in rep_i:
		n = 1
		for index in [m for (m,z) in enumerate(li) if z == i]:
			li[index]  += "." + str(n)
			n += 1
	return li
			
			
	
if len(sys.argv) != 3:
	print "USAGE: python scripts.py source_dir back_dir"
	sys.exit(0)
path_in = os.path.abspath(sys.argv[1])
relative_dir = os.path.basename(path_in)
path_out = os.path.abspath(sys.argv[2])
if not os.path.exists(sys.argv[2]):
	print "output directory not exists, now creat %s" %path_out
os.system("mkdir -p " + path_out + "/" + relative_dir + "_py_scripts_bak")
all_py_file = os.popen('find ' + path_in + ' -type f | grep ".py$"').read().split()   ### 注意，一定避免将备份后的文件重复查找，又一次备份，资源重复
name = []
for i in all_py_file:
	des_file = os.path.join(path_out + "/" + relative_dir + "_py_scripts_bak",i.partition(relative_dir + "/")[-1]) 
	
	try:
		os.makedirs(os.path.dirname(des_file))
	except:
		pass
	os.system("cp %s %s" %(i,des_file))
	name.append(os.path.basename(i))
os.system("mkdir -p " + path_out + "/" + relative_dir + "_all_py_scripts/")
out_name = map(lambda x:path_out + "/" + relative_dir + "_all_py_scripts/" + x, modify_pick(name))
for n,i in enumerate(all_py_file):
	os.system("cp %s %s" %(i,out_name[n]))
	
