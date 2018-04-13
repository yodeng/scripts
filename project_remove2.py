#!/usr/bin/env python
#coding:utf-8
import sys,os
if len(sys.argv) == 1:
    print "USAGE: python scripts.py project_dir ..."
    sys.exit(1)

def listdir3(path):
    for a,b,c in os.walk(path):
            for i in c:
                        yield os.path.join(a,i)

for p in sys.argv[1:]:
    path_in = os.path.abspath(p)
    projectname = os.path.basename(path_in)
    filenext = listdir3(path_in)
    #all_file = os.popen('find ' + path_in + ' -type f').read().split()
    f_sh = open(projectname + ".bak.sh" ,"w")

    for f in filenext:
        if "results" in f or os.path.islink(f):continue
        if f.endswith(".fq.gz") or f.endswith(".fq") or f.endswith("RData") or f.endswith("unPaired_HQReads"):
            f_sh.write('rm -fr %s \n' %f)
        elif f.endswith("rmAdapter.info") or f.endswith("IlluQC_N.out") or f.endswith(".vcf") or f.endswith("transcripts.gtf") or f.endswith(".gff") or f.endswith(".cxb"):
            f_sh.write("/lustre/work/zhonghuali/software/application/pigz-2.3.3/pigz -p 8 %s \n" %f )
        else:
            continue
    f_sh.close()        
        
