#!/usr/bin/env python
#coding:utf-8
##查看系统cpu信息，（核数，cpu个数，线程数，是否超线程）
import os
if not os.path.exists("/proc/cpuinfo"):
	print "No /proc/cpuinfo file, No Check!"
	sys.exit(0)
cpu_num = os.popen('grep "physical id" /proc/cpuinfo | sort| uniq| wc -l').read().strip()
core_per_cpu = os.popen('grep "cpu cores" /proc/cpuinfo| uniq|cut -d":" -f2').read().strip()
cpu_name = os.popen('grep "name" /proc/cpuinfo | cut -f2 -d: | uniq').read().strip()
logical_cpu_num = os.popen('grep "processor" /proc/cpuinfo| wc -l').read().strip()
hyper_threading_support = "No"
if int(logical_cpu_num) > int(cpu_num)*int(core_per_cpu):
	hyper_threading_support = "Yes"
MemTotal = os.popen('grep MemTotal /proc/meminfo |cut -d":" -f2').read().strip()
MemTotal = float(MemTotal.split()[0]) ## KB
MemTotal_G = round(MemTotal/1024/1024 - 0.005,2)
MemTotal_M = round(MemTotal/1024 - 0.05,1)
MemTotal_K = MemTotal
MemFree = os.popen('grep MemFree /proc/meminfo |cut -d":" -f2').read().strip()
MemFree = float(MemFree.split()[0]) ## KB
MemFree_G = round(MemFree/1024/1024 - 0.005,2)       ### 向下取小数
MemFree_M = round(MemFree/1024 - 0.05,1)
MemFree_K = MemFree

print "CPU name:\t%s" %cpu_name
print "CPU number:\t%s" %cpu_num 
print "Core number per CPU:\t%s" %core_per_cpu
print "logical CPU number (processors number):\t%s" %logical_cpu_num
print "Hyper-threading support:\t%s" %hyper_threading_support
print "Total Memory:\t%.2fG, %.1fM, %.0fKB" % (MemTotal_G,MemTotal_M,MemTotal_K)
print "Free Memory:\t%.2fG, %.1fM, %.0fKB" % (MemFree_G,MemFree_M,MemFree_K)
