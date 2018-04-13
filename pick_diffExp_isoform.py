#!/usr/bin/env python
#coding:utf-8
import argparse,os,sys
from math import log

parser = argparse.ArgumentParser(description="This Script is used to pick difference isoform/gene by fc and p_value.")
parser.add_argument("-i","--input",type=str,help="The imput diff file",required = True)
parser.add_argument("-fc","--fc",type=float,help="The Fold Change number of log2",default = 2)
parser.add_argument("-v","--version",action="version",version='%(prog)s 1.0')
args = parser.parse_args()

def main():
    pre = os.path.splitext(args.input)[0] if args.input.endswith(".txt") else args.input
    with open(pre + ".filter.up.diff","w") as up,open(pre + ".filter.down.diff","w") as down,open(pre + ".diff_info","w") as info,open(pre + ".plot_scatter.file","w") as scatter,open(pre + ".plot_valcano.file","w") as valcano:
        fi = open(args.input)
        header = fi.next()
        up.write(header.rstrip() + "\tUp/Down\n")
        down.write(header.rstrip() + "\tUp/Down\n")
        key = os.path.basename(os.path.dirname(args.input))
        test,control = key.partition("-VS-")[0],key.partition("-VS-")[-1]
        scatter.write("ID\t%s fpkm value\t%s fpkm value\t%s\n"%(control,test,key))
        valcano.write("ID\tlog2(fold change)\t-log10(p value)\t%s\n"%key)
        for line in fi:
            flag = ""
            n = line.split("\t")
            fc = float(n[9])
            p = float(n[11])
            if abs(fc) >= log(args.fc,2) and p <= 0.05:
                if fc < 0:
                    down.write(line.rstrip() + "\tdown\n")
                    info.writelines([i + "\t" + n[11] + "\tdown\n" for i in n[2].split(",")])
                    flag = "down"
                if fc >0:
                    up.write(line.rstrip() + "\tup\n")
                    info.writelines([i + "\t" + n[11] + "\tup\n" for i in n[2].split(",")])
                    flag = "up"
            if float(n[7]) >= 0.01 and float(n[8]) >= 0.01:
                log_pvalue = 0-log(p)/log(10)
                scatter.write(n[0]+"\t"+n[7]+"\t"+n[8]+"\t"+flag+"\n")
                if "inf" not in n[9]:
                    valcano.write(n[0]+"\t"+n[9]+"\t"+str(log_pvalue)+"\t"+flag+"\n")
        fi.close()        
if __name__ == "__main__"   :
    main()        
