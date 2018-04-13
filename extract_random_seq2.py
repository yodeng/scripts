#!/usr/bin/env python
#coding:utf-8
### 将序列全部读入的过程非常消耗内存,采用numpy进行随机处理
import sys,os,argparse
from collections import OrderedDict
from numpy import random
import gzip,bz2file
from datetime import datetime
from math import ceil

def readseq(handle,ft):
    if handle.endswith(".gz"):handle = gzip.open(handle)
    elif handle.endswith(".bz2"):handle = bz2file.open(handle)
    else:handle = open(handle)
    seqdict=OrderedDict()
    s = []
    if ft == "fq":
        for n,line in enumerate(handle):
            if n%4 == 0:
                if not s:
                    s = [line,]
                    continue
                seqdict[s[0]] = s
                s = [line,]
            else:
                s.append(line)
        seqdict[s[0]] = s
        handle.close()
        return seqdict
    if ft == "fa":
        for line in handle:
            if line.startswith(">"):
                if not s:
                    s = [line,]
                    continue
                seqdict[s[0]] = s
                s = [line,]
            else:
                s.append(line)
        seqdict[s[0]] = s
        handle.close()
        return seqdict
        
def parserArg():
    parser = argparse.ArgumentParser(description= "Subsampling randomly extracts a certain number or a certain percentage of the sequences(fasta/fastq) in the input sequences file.The extraction is performed as a random sampling with a uniform distribution among the input sequences and is performed without replacement.")
    parser.add_argument("-fa","--fasta",type=str,help="the fasta input files, '.gz' or '.bz2' file can be allowed")
    parser.add_argument("-fq","--fastq",type=str,help="the fastq input files, '.gz' or '.bz2' file can be allowed")
    #parser.add_argument("-p","--parallel",type=int,help="the cpu number used, default: 8",required = False, default = 8)
    parser.add_argument("-pct","--sample_pct",type=float,help="Subsample the given percentage of the input sequences, Accepted values range from 0.0 to 100.0")
    parser.add_argument("-size","--sample_size",type=int,help="sampling size, positive integer. Extract the given number of sequences")
    parser.add_argument("-seed","--randseed",type=int,default=20,help="Use integer as a seed for the pseudo-random generator. A given seed always produces the same output, which is useful for replicability, default: 20")
    parser.add_argument("-o","--out",type=str,help="the output subsampled sequences files",required=True)
    return parser.parse_args()

def main():
    args = parserArg()
    if not args.fasta and not args.fastq:
        print "please give your input sequence"
        sys.exit(1)
    if args.fasta and args.fastq:
        print "only one of '-fa' and '-fq' can be set"
        sys.exit(1)
    if not args.sample_pct and not args.sample_size:
        print "please give your sampling condition"
        sys.exit(1)
    if args.sample_pct and args.sample_size:
        print "only one of '-pct' and '-size' can be set"
        sys.exit(1)
    if args.fasta:
        inputfile = args.fasta
        print "["+datetime.now().strftime("%X")+"]","start read input %s file, please wait ......"%inputfile
        seq = readseq(args.fasta,"fa")
    if args.fastq:
        inputfile = args.fastq
        print "["+datetime.now().strftime("%X")+"]","start read input %s file, please wait ......"%inputfile
        seq = readseq(args.fastq,"fq")
    if args.sample_pct:pick_num = int(ceil(len(seq)*(args.sample_pct)/100))
    if args.sample_size:pick_num = args.sample_size
    #print "Memory Used : %.3f GB"%(float(sys.getsizeof(seq[1]))/1024/1024/1024)
    assert pick_num <= len(seq), "sample_size is great then sequence number"
    outfile = args.out
    random.seed(seed = args.randseed)
    if outfile.endswith(".gz"):out = gzip.open(outfile,"wb")
    elif outfile.endswith(".bz2"):out = bz2file.open(outfile,"wb")
    else:out = open(outfile,"w")
    print "["+datetime.now().strftime("%X")+"]","start randomly subsample and write output %s file ..."%outfile
    for name in random.choice(seq.keys(),pick_num,replace=False):
        out.writelines(seq[name])
    out.close()
    print os.path.abspath(inputfile)+":",len(seq),"seqs, Subsampled %d reads." % pick_num
    print "["+datetime.now().strftime("%X")+"]","finished!"
    #sys.exit(0)

if __name__ == "__main__":
    main()
