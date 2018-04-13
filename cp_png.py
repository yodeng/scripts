#!/usr/bin/env python
#coding:utf-8
#
import os,sys
with open(sys.argv[1],"r") as f:
	for i in f:
		if i.startswith("\t"):
			cmd = i.partition(">")[0]
			for cmd_s in cmd.split()[:-1]:
				if ".pdf" in cmd_s:
					png = cmd_s.replace(".pdf",".png")
					if not os.path.exists(png):
						continue
					des = cmd.split()[-1].replace("results","results/xlsx_txt/png")
					des = des.replace(".pdf",".png")
					if not des.endswith(".png"):
						des += "/"
					try:
						os.makedirs(os.path.dirname(des))
					except:
						pass
					os.popen("cp " + png + " " + des)
			
