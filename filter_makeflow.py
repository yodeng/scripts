#!/usr/bin/env python
#coding:utf-8
## 过滤makeflow步骤，当makeflow中某一小步骤的target文件全部存在，则不执行该步骤，删除该CATEGORY，若至少有一个target文件不存在，则删除该CATEGORY的所有target文件，保留该CATEGORY，生成新的makeflow
## 删除makeflow中的所有target生成的文件，重新运行该makeflow

import re,os,argparse,sys
from collections import OrderedDict

parser = argparse.ArgumentParser(description="This Script is used to deal with the makeflow file.")
parser.add_argument("-mf",dest = "makeflow",type=str,help="The input makeflow file",required = True)
parser.add_argument("-f",dest = "filter",action = "store_true",help="filter the makeflow CATEGORY by target output file")
parser.add_argument("-r",dest = "remove",action = "store_true", help="remove all target file that makeflow will generate, *.bam will not be remove if *.sam not exists.soft link file will be considered as read link file")
args = parser.parse_args()

def classfy_makeflow_file(makeflow):
    input_file,out_file,result_file,need_file,no_file = set(),set(),set(),set(),set()
    with open(makeflow) as f:
        for line in f:
            line = line.strip()
            if ":" in line and line.startswith("/"):
                out = line.split(":")
                for i in out[0].split():
                    if "results" in i:
                        result_file.add(i)
                    else:
                        out_file.add(i)
                for i in out[1].split():
                    if "results" in i:
                        result_file.add(i)
                    else:
                        input_file.add(i)
            else:
                continue
    need_file = input_file.difference(out_file,result_file)
    for i in need_file:
	if os.path.exists(i):
		continue
	else:
		no_file.add(i)
    return input_file,out_file,result_file,need_file,no_file

def check_file(filelist):
    for i in filelist:
        if not os.path.exists(i):
            return False
    return True
    
def get_makeflow_dict(makeflow):
    flow_d = OrderedDict()
    f = open(makeflow,"r").read()
    flow_tuple = zip(re.findall("CATEGORY=.+?\n",f),re.split("CATEGORY=.+?\n",f)[1:])
    category = map(lambda x:x[0]+x[1],flow_tuple)
    d = OrderedDict()
    for c in category:
        out = re.search("\n\s*(/.+?)\s*?:\s*?/.+?\n",c).group(1)
        k = tuple(out.strip().split())
        d[k] = c
    return d

def check_str_in_list(strn,listn):
    for i in listn:
        if strn in i:
            return True
    return False

def get_list_number_by_substr(strn,listn):
    a = []
    for i in listn:
        if i.endswith(strn):
            a.append(i)
    return a

def main():
    if args.filter and args.remove:
        print "Only one args of '-f' and '-r' can be set"
        sys.exit(1)
    if not args.filter and not args.remove:
        print "One args of '-f' and '-r' must be set"
        sys.exit(1)
    input_file,out_file,result_file,need_file,no_file = classfy_makeflow_file(args.makeflow)
    flowDict = get_makeflow_dict(args.makeflow)
    if args.filter:
        with open(args.makeflow+".new.mf","w") as new,open(args.makeflow+".new.rm.sh","w") as sh:
            for k in flowDict:
                if check_file(list(k)):
                    continue
                else:
                    if check_str_in_list(".fastq.gz",list(k)) or check_str_in_list(".rm.fq.gz",list(k)) or check_str_in_list("run-cutadapt ",list(k)) or 'CATEGORY=RM_adapter' in flowDict[k]:
                        continue  ### 跳过原始文件
                    if get_list_number_by_substr(".sam",list(k)):
                        samlist = get_list_number_by_substr(".sam",list(k))
                        bamlist = map(lambda x:x[:x.rfind(".sam")] + ".bam",samlist)
                        if check_file(bamlist):
                            continue
                    if get_list_number_by_substr("total.bam",list(k)):
                        f = get_list_number_by_substr("total.bam",list(k))[0]
                        snpvcf = f[:f.rfind("total.bam")] + "snp.vcf"
                        indelvcf = f[:f.rfind("total.bam")] + "indel.vcf"
                        if os.path.exists(snpvcf) and os.path.exists(indelvcf):
                            continue
                    l = []
                    for file_out in list(k):
                        if os.path.exists(file_out):
                            l.append(file_out) 
                    if l:
                        sh.write("rm -fr %s\n"%" ".join(l))
                    new.write(flowDict[k])
    if args.remove:
        with open(args.makeflow+".new.rm.sh","w") as sh:
            for k in flowDict:
                if get_list_number_by_substr(".bam",list(k)):
                    bamlist = get_list_number_by_substr(".bam",list(k))
                    samlist = map(lambda x:x[:x.rfind(".bam")] + ".sam",bamlist)
                    if not any(map(lambda x:os.path.exists(x),samlist)):
                        continue
                    else:
                        file_out = [f for f in list(k) if os.path.exists(f)]
                        if file_out:
                            sh.write("rm -fr %s\n"%" ".join(file_out))
                        continue
                file_out = [f for f in list(k) if os.path.exists(f)]
                if file_out: sh.write("rm -fr %s\n"%" ".join(file_out))                        
if __name__ == "__main__":
    main()
        

        
