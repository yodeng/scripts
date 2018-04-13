#!/usr/bin/env python
#coding:utf-8
## python pick_diffexp.py group1-VS-group2/group1-VS-group2.txt group3-VS-group4/group3-VS-group4.txt.... 
import os,sys
from math import log
def dofile(filename):
    pre = filename[:filename.rfind(".txt")] if filename.rfind(".txt") > 0 else filename
    os.system("grep -E '\tup_down$|\tup$' %s > %s" %(filename,pre+".up.diff"))
    os.system("grep -E '\tup_down$\tdown$' %s > %s" %(filename,pre+".down.diff"))
    os.system("grep -E '\tdown$|up$' %s | cut -f1,6,7 > %s"%(filename,pre+".diff_info"))
    with open(pre + ".plot_scatter.file","w") as scatter,open(pre + ".plot_valcano.file","w") as valcano:
        fi = open(filename)
        header = fi.next()
        key = os.path.basename(os.path.dirname(filename))
        test,control = key.partition("-VS-")[0],key.partition("-VS-")[-1]
        scatter.write("ID\t%s rpm value\t%s rpm value\t%s\n"%(control,test,key))
        valcano.write("ID\tlog2(fold change)\t-log10(q value)\t%s\n"%key)
        for line in fi:
            n = line.split("\t")
            flag = "\n" if n[-1] == "no\n" else n[-1]
            q = float(n[-2])
            if float(n[1]) >= 0.01 and float(n[2]) >= 0.01:
                log_qvalue = 0-log(q)/log(10)
                scatter.write(n[0]+"\t"+n[1]+"\t"+n[2]+"\t"+flag)
                valcano.write(n[0]+"\t"+n[3]+"\t"+str(log_qvalue)+"\t"+flag)
        fi.close()        
if __name__ == "__main__":
    for filename in sys.argv[1:]:
        dofile(filename)