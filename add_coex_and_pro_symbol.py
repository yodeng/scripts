#!/usr/bin/env python
#coding:utf-8
import sys,re,os,argparse,fileinput

parser = argparse.ArgumentParser(description="This Script is used to find all deg.pro-pro.txt, Co-Expression.xls, filter.coexpression.txt, and filter.propro.txt under a given path, and add the symbol from anno file. New file will replace the old file, old file will be renamed with '.no.symbol.txt' extension.")
parser.add_argument("-path","--path",type=str,help="The input path, 'deg.pro-pro.txt','Co-Expression.xls','filter.coexpression.txt','filter.propro.txt' file will be found under this path.",required = True)
parser.add_argument("-anno","--anno",type=str,help="The input anno file, first column must be id, seventh column must be symbol information.",required = True)
parser.add_argument("-v","--version",action="version",version='%(prog)s 1.0')
args = parser.parse_args()

file_list = os.popen('find ' + args.path + " -name deg.pro-pro.txt -o -name Co-Expression.xls -o -name filter.coexpression.txt -o -name filter.propro.txt").read().rstrip("\n").split("\n")
anno_d = {}
with open(args.anno,"r") as anno:
    for i in anno:
        anno_d[i.split("\t")[0]] = i.split("\t")[6]
# anno_d["-"] = "-"
for i in fileinput.input(file_list,backup = ".no.symbol.txt",inplace = 1):
    t = re.sub('\(-\)?',"(-:-)",i)
    ensembol = re.findall('\S+\((.+?)\)\s+?',t)
    if ensembol:
        for ei in ensembol:
            if ei == "-:-":
                continue
            else:
                eii = ei.split(",")
                for index,eiii in enumerate(eii):
                    eii[index] = eiii + ":" + anno_d[eiii]
                an = ";".join(eii)
                t = re.sub(ei,an,t,1)
        sys.stdout.write(t)
    else:
        a = i.split("\t")
        for n,ai in enumerate(a):
             if anno_d.has_key(ai):
                 a[n] = ai + "(" + anno_d[ai] + ")"
        sys.stdout.write("\t".join(a))

    
