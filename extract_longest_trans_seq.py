#!/usr/bin/env python
#coding:utf-8
import sys,re
if len(sys.argv) != 4 or len(sys.argv) == 1:
    print "USAGE: python script.py fa gtf outputseq"
    sys.exit(1)
from collections import OrderedDict
from os.path import abspath
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord
from Bio.SeqIO.FastaIO import FastaWriter

def getmergelen(al):
    a = sorted(al)
    b = [a[0]]      
    for i in range(1,len(a)):
        if a[i][0] <= b[-1][1] + 1:
            b[-1][1] = max(a[i][1],b[-1][1])
        else:
            b.append(a[i])
    return sum([abs(i[0]-i[1]) for i in b]) + len(b)
    
def getlen(al):
    b = sorted(al)
    return sum([abs(i[0]-i[1]) for i in b]) + len(b)

def main():
    fa = abspath(sys.argv[1])
    gtf = abspath(sys.argv[2])
    out = abspath(sys.argv[3])
    outseqrecord = []
    faindex = SeqIO.to_dict(SeqIO.parse(fa,"fasta"))
    gene = OrderedDict()
    with open(gtf) as fi:
        for line in fi:
            if line.strip() and not line.startswith("#") and "\texon\t" in line:
                geneid,transid = re.search('gene_id "(.+?)"; transcript_id "(.+?)";',line).group(1,2)
                s = int(line.split("\t")[3])
                e = int(line.split("\t")[4])
                chr = line.split("\t")[0]
                strand = line.split("\t")[6]
                gene.setdefault(geneid,OrderedDict()).setdefault(transid,{}).setdefault("pos",[]).append([s,e])
                gene.setdefault(geneid,OrderedDict()).setdefault(transid,{}).setdefault("chr",set()).add(chr)
                gene.setdefault(geneid,OrderedDict()).setdefault(transid,{}).setdefault("strand",set()).add(strand)
    for g in gene:
        translen = [[getlen(gene[g][t]["pos"]),t] for t in gene[g]]
        translen.sort(reverse=True)
        longtrans = translen[0][1]
        seq = ""
        name = g + " " + longtrans
        seqid = list(gene[g][longtrans]["chr"])[0]
        for i in gene[g][longtrans]["pos"]:
            seq += faindex[seqid].seq[i[0]-1:i[1]]
        if list(gene[g][longtrans]['strand'])[0] == "-":
            seqr = SeqRecord(seq.reverse_complement(),id = name,name="",description="")
        else:
            seqr = SeqRecord(seq,id = name,description="",name="")
        outseqrecord.append(seqr)
    handle = open(out,"w")
    writer = FastaWriter(handle,wrap=60)
    writer.write_file(outseqrecord)
    handle.close()
        
if __name__ =="__main__":
    main()
        

