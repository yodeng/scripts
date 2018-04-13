#!/usr/bin/env py
#coding:utf-8
# import sys,os
# project_dir = sys.argv[1]
# des_dir = os.path.join(sys.argv[2] , project_dir + "_bak")
# sub_dir_list = os.popen('find ' + project_dir + ' -type d |sort -r').read().split()
# a=""
# for i in sub_dir_list:
	# if i in a:
		# continue
	# else:
		# des = os.path.join(des_dir,i.partition("/")[-1])
		# if "results" in des:
			# continue
		# os.makedirs(des)
		# a=i
# all_file = os.popen('find ' + project_dir + ' -type f').read().split()
# out = os.path.join(des_dir,f.partition("/")[-1]) + ".gz"
# for f in all_file:
	# if "results" in des or f.endswith(".fq.gz") or f.endswith(".fq") or f.endswith("RData") or f.endswith("unPaired_HQReads"):
		# continue
	# elif f.endswith("rmAdapter.info") or f.endswith("IlluQC_N.out") or f.endswith(".vcf") or f.endswith("transcripts.gtf") or f.endswith(".gff") or f.endswith(".cxb"):
		# os.system("/lustre/work/zhonghuali/software/application/pigz-2.3.3/pigz -kc -p 8 " + f + "> " + out)
	# else:
		# os.system("cp " + f + " " + os.path.join(des_dir,f.partition("/")[-1]) )

		
		
import sys,os
if len(sys.argv) != 3:
	print "USAGE: python scripts.py project_dir back_dir"
	sys.exit(0)
path_in = os.path.abspath(sys.argv[1])
projectname = os.path.basename(path_in)
path_out = os.path.abspath(sys.argv[2])
f_sh = open(projectname + ".bak.makeflow" ,"w")
if not os.path.exists(sys.argv[2]):
	print "output directory not exists, now creat %s" %path_out
os.system("mkdir -p " + path_out + "/" + projectname + "_bak")
sub_dir_list = os.popen('find ' + path_in + ' -type d |sort -r').read().split()
a=""
for i in sub_dir_list:
	if i in a:
		continue
	else:
		des_dir = os.path.join(path_out + "/" + projectname + "_bak",i.partition(projectname + "/")[-1])
		if "results" in des_dir:   ### results目录中的内容暂不备份
			continue
		des_dir = os.path.abspath(des_dir)
		os.system("mkdir -p " + des_dir)
		a=i

all_file = os.popen('find ' + path_in + ' -type f').read().split()

for f in all_file:
	if "results" in f or f.endswith(".fq.gz") or f.endswith(".fq") or f.endswith("RData") or f.endswith("unPaired_HQReads"):
		continue
	elif f.endswith("rmAdapter.info") or f.endswith("IlluQC_N.out") or f.endswith(".vcf") or f.endswith("transcripts.gtf") or f.endswith(".gff") or f.endswith(".cxb"):
		f_sh.write("CATEGORY=pigz\n") 
		f_sh.write(os.path.join(path_out + "/" + projectname + "_bak",f.partition(projectname + "/")[-1]) + ".gz : " + f + "\n")
		f_sh.write("\t/lustre/work/zhonghuali/software/application/pigz-2.3.3/pigz -kc -p 8 " + f + " > " + os.path.join(path_out + "/" + projectname + "_bak",f.partition(projectname + "/")[-1]) + ".gz\n\n")
	else:
		f_sh.write("CATEGORY=cp\n") 
		f_sh.write(os.path.join(path_out + "/" + projectname + "_bak",f.partition(projectname + "/")[-1]) + " : " + f + "\n")
		f_sh.write("\tcp " + f + " " + os.path.join(path_out + "/" + projectname + "_bak",f.partition(projectname + "/")[-1]) + "\n\n")
f_sh.close()		
		
		
		
		
		
		
