#!/usr/bin/env python
#coding:utf-8
import sys,argparse,re,os,subprocess
from tempfile import TemporaryFile
from datetime import datetime
parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,description= "Subsampling randomly extracts a certain number or a certain percentage of the sequences(fasta/fastq) in the input sequences file.The extraction is performed as a random sampling with a uniform distribution among the input sequences and is performed without replacement. Both single reads and paired reads can be supported. There will be no output if subsample have more reads than the original sample.\
\nExample:\n'python extract_random_seq.py -fa R1.fasta R2.fasta -size 1000 -o R1.pick.fasta R2.pick.fasta' for paired fasta reads picking.\
\n'python extract_random_seq.py -fa filein.fasta -size 1000 -o fileout.fasta' for single fasta reads picking.")
parser.add_argument("-fa","--fasta",type=str,help="the fasta input files, '.gz' or '.bz2' file can be allowed",nargs="+")
parser.add_argument("-fq","--fastq",type=str,help="the fastq input files, '.gz' or '.bz2' file can be allowed",nargs="+")
#parser.add_argument("-p","--parallel",type=int,help="the cpu number used, default: 8",required = False, default = 8)
parser.add_argument("-pct","--sample_pct",type=float,help="Subsample the given percentage of the input sequences, Accepted values range from 0.0 to 100.0")
parser.add_argument("-size","--sample_size",type=int,help="sampling size, positive integer. Extract the given number of sequences")
parser.add_argument("-seed","--randseed",type=int,default=20,help="Use integer as a seed for the pseudo-random generator. A given seed always produces the same output, which is useful for replicability, default: 20")
parser.add_argument("-o","--out",type=str,help="the output subsampled sequences files, not compressed",nargs="+",required=True)
args = parser.parse_args()

#soft = "/lustre/shared_softwares/vsearch/bin/vsearch" if os.path.exists("/lustre/shared_softwares/vsearch/bin/vsearch") else "/lustre/work/yongdeng/software/vsearch/vsearch/bin/vsearch"
#cmd = soft + ' --threads %d --fastx_subsample '%args.parallel
tmp1 = TemporaryFile()
tmp2 = TemporaryFile()
cmd = "/lustre/shared_softwares/vsearch/bin/vsearch --fastx_subsample " if os.path.exists("/lustre/shared_softwares/vsearch/bin/vsearch") else "/lustre/work/yongdeng/software/vsearch/vsearch/bin/vsearch --fastx_subsample "
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

if args.fastq:
    if len(args.fastq) > 2 or len(args.out) > 2:
        print "only less then two fastq files can be input or output. if one file, single-reads-picking will be done. else, paired-reads-picking will be done"
        sys.exit(1)
    if len(args.fastq) == 1 and os.path.exists(args.fastq[0]):
        cmd += args.fastq[0] + " "
        if args.fastq[0].endswith(".gz"):cmd += "--gzip_decompress "
        if args.fastq[0].endswith(".bz2"):cmd += "--bzip2_decompress "
        if args.sample_pct:cmd += "--sample_pct " + str(args.sample_pct) + " "
        if args.sample_size:cmd += "--sample_size " + str(args.sample_size) + " "
        cmd += "--fastqout " + args.out[0] + " --randseed " + str(args.randseed) 
        #cmd += " &> /dev/null"
        print "["+datetime.now().strftime("%X")+"]","start randomly subsample, please wait ......"
        p1 = subprocess.Popen(cmd,shell=True,stdout=tmp1,stderr=tmp1);p1.wait()
        tmp1.seek(0);tf1 = tmp1.read()
        if p1.returncode != 0 and not re.search('\n.+?nt in.+?\n',tf1):
            print "Error:",tf1[tf1.find(":")+1:tf1.rfind("(")].strip()
            sys.exit(1)
        if p1.returncode != 0 and re.search('\n.+?nt in.+?\n',tf1):
            nbp = re.search('\n(.+?)nt in.+?\n',tf1).group(1).strip()
            nreads = re.search('\n.+?nt in(.+?)seqs,.+?\n',tf1).group(1).strip()
            orinfo = re.search('\n(.+?nt in.+?)\n',tf1).group(1)
            print "more reads than in the original sample(%s), remove output"%orinfo
            os.system("rm -fr %s"%args.out[0])
            sys.exit(0)
        print os.path.abspath(args.fastq[0]) + ":",re.search('\n.+?nt in.+?\n',tf1).group().strip().split(",")[0]+",",re.search('\nSubsampled \d+',tf1).group().strip()+" reads"
        print "["+datetime.now().strftime("%X")+"]","finished!"
        sys.exit(0)
    #if not os.path.exists(args.fastq[0]) or not os.path.exists(args.fastq[1]):
    #    print "%s or %s not exist!"%(args.fastq[0],args.fastq[1])
    #    sys.exit(1)
    if not os.path.exists(args.fastq[0]):
        print "Error: %s not exist!"%args.fastq[0]
        sys.exit(1)
    inputfile = args.fastq
    cmd1 = cmd + args.fastq[0] + " "
    if args.fastq[0].endswith(".gz"):cmd1 += "--gzip_decompress "
    if args.fastq[0].endswith(".bz2"):cmd1 += "--bzip2_decompress "
    if args.sample_pct:cmd1 += "--sample_pct " + str(args.sample_pct) + " "
    if args.sample_size:cmd1 += "--sample_size " + str(args.sample_size) + " "
    cmd1 += "--fastqout " + args.out[0] + " --randseed " + str(args.randseed) 
    #cmd1 += " &> /dev/null"
    cmd2 = cmd1.replace(args.fastq[0],args.fastq[1])
    cmd2 = cmd2.replace(args.out[0],args.out[1])
    if cmd1 == cmd2:
        print "filename error"
        sys.exit(1)
    
if args.fasta:
    if len(args.fasta) > 2 or len(args.out) > 2:
        print "only two fasta files can be input or output. if one file, single-reads will be done. else, paired-reads will be done"
        sys.exit(1)
    if len(args.fasta) == 1 and os.path.exists(args.fasta[0]):
        cmd += args.fasta[0] + " "
        if args.fasta[0].endswith(".gz"):cmd += "--gzip_decompress "
        if args.fasta[0].endswith(".bz2"):cmd += "--bzip2_decompress "
        if args.sample_pct:cmd += "--sample_pct " + str(args.sample_pct) + " "
        if args.sample_size:cmd += "--sample_size " + str(args.sample_size) + " "
        cmd += "--fastaout " + args.out[0] + " --randseed " + str(args.randseed) 
        #cmd += " &> /dev/null"
        print "["+datetime.now().strftime("%X")+"]","start randomly subsample, please wait ......"
        p1 = subprocess.Popen(cmd,shell=True,stdout=tmp1,stderr=tmp1);p1.wait()
        tmp1.seek(0);tf1 = tmp1.read()
        if p1.returncode != 0 and not re.search('\n.+?nt in.+?\n',tf1):
            print "Error:",tf1[tf1.find(":")+1:tf1.rfind("(")].strip()
            sys.exit(1)
        if p1.returncode != 0 and re.search('\n.+?nt in.+?\n',tf1):
            nbp = re.search('\n(.+?)nt in.+?\n',tf1).group(1).strip()
            nreads = re.search('\n.+?nt in(.+?)seqs,.+?\n',tf1).group(1).strip()
            orinfo = re.search('\n(.+?nt in.+?)\n',tf1).group(1)
            print "more reads than in the original sample(%s), remove output"%orinfo
            os.system('rm -fr %s'%args.out[0])
            sys.exit(0)
        print os.path.abspath(args.fasta[0]) + ":",re.search('\n.+?nt in.+?\n',tf1).group().strip().split(",")[0]+",",re.search('\nSubsampled \d+',tf1).group().strip()+" reads"
        print "["+datetime.now().strftime("%X")+"]","finished!"
        sys.exit(0)        
   # if not os.path.exists(args.fasta[0]) or not os.path.exists(args.fasta[1]):
   #     print "%s or %s not exist!"%(args.fasta[0],args.fasta[1])
   #     sys.exit(1)
    if not os.path.exists(args.fasta[0]):
        print 'Error: %s not exist!'%args.fasta[0]
        sys.exit(1)
    inputfile = args.fasta
    cmd1 = cmd + args.fasta[0] + " "
    if args.fasta[0].endswith(".gz"):cmd1 += "--gzip_decompress "
    if args.fasta[0].endswith(".bz2"):cmd1 += "--bzip2_decompress "
    if args.sample_pct:cmd1 += "--sample_pct " + str(rgs.sample_pct) + " "
    if args.sample_size:cmd1 += "--sample_size " + str(args.sample_size) + " "
    cmd1 += "--fastaout " + args.out[0] + " --randseed " + str(args.randseed) 
    #cmd1 += " &> /dev/null"
    cmd2 = cmd1.replace(args.fasta[0],args.fasta[1])
    cmd2 = cmd2.replace(args.out[0],args.out[1])
    if cmd1 == cmd2:
        print "filename error"
        sys.exit(1)
print "["+datetime.now().strftime("%X")+"]","start randomly subsample, please wait ......"
p1 = subprocess.Popen(cmd1,shell=True,stdout=tmp1,stderr=tmp1)
p2 = subprocess.Popen(cmd2,shell=True,stdout=tmp2,stderr=tmp2)
p1.wait()
p2.wait()
tmp1.seek(0);tmp2.seek(0)
tf1 = tmp1.read();tf2 = tmp2.read()
if p1.returncode != 0  and not re.search('\n.+?nt in.+?\n',tf1):
    print "Error:",tf1[tf1.find(":")+1:tf1.rfind("(")].strip()
    sys.exit(1)
if p1.returncode != 0 and re.search('\n.+?nt in.+?\n',tf1):
    nbp = re.search('\n(.+?)nt in.+?\n',tf1).group(1).strip()
    nreads = re.search('\n.+?nt in(.+?)seqs,.+?\n',tf1).group(1).strip()
    orinfo = re.search('\n(.+?nt in.+?)\n',tf1).group(1)
    print "more reads than in the original sample(%s), remove output"%orinfo
    os.system("rm -fr %s"%(" ".join(args.out)))
    sys.exit(0)
info1 = [os.path.abspath(inputfile[0])+":",re.search('\n.+?nt in.+?\n',tf1).group().strip().split(",")[0]+",",re.search('\nSubsampled \d+',tf1).group().strip()+" reads"]
info2 = [os.path.abspath(inputfile[1])+":",re.search('\n.+?nt in.+?\n',tf2).group().strip().split(",")[0]+",",re.search('\nSubsampled \d+',tf2).group().strip()+" reads"]
print " ".join(info1)
print " ".join(info2)
print "["+datetime.now().strftime("%X")+"]","finished!" 
if  re.search("nt in (\d+)\s",info1[1]).group(1) != re.search("nt in (\d+)\s",info2[1]).group(1):
    print "number of sequences in %s and %s are not equal, the output files are invalid, please remove!"%(inputfile[0],inputfile[1])
    sys.exit(0)
