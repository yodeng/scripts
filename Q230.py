#!/usr/bin/env python
#from Bio import SeqIO
from multiprocessing import Pool,cpu_count
import sys,os

def get_q230(File):
    f = open(File)
    flines = f.readlines()
    f.close()
    q20=0
    q30=0
    base = 0
    for i in range(3,len(flines),4):
        l = flines[i].strip()
        base += len(l)
        q20 += len(filter(lambda x:ord(x)-33 >= 20,l))
        q30 += len(filter(lambda x:ord(x)-33 >= 30,l))
    a = float(q20)/base*100
    b = float(q30)/base*100
    return a,b
        
#	fq = SeqIO.parse(File,"fastq")
#	q20=0
#	q30=0
#	base=0
#	for seq in fq:
#		phred_quality = seq.letter_annotations['phred_quality']
#		q20 += len(filter(lambda x:x>=20,phred_quality))
#		q30 += len(filter(lambda x:x>=30,phred_quality))
#		base += len(seq)
#	a=float(q20)/base*100
#	b=float(q30)/base*100
#	return a,b

if __name__ == "__main__":
    a = all([os.path.exists(f) for f in sys.argv[1:]])
    if not a:
        print "Error:some input file not exists"
        sys.exit(1)
    pool = Pool(min(len(sys.argv),cpu_count()))
    results = []
    for f in sys.argv[1:]:
        results.append(pool.apply_async(get_q230,(f,)))
    pool.close()
    pool.join()
    for i,f in enumerate(sys.argv[1:]):
        print os.path.abspath(f)
        print "Q20(Phred+33):\t%.2f"%results[i].get()[0]
        print "Q30(Phred+33):\t%.2f\n"%results[i].get()[1]
        
        
    
