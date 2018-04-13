#!/usr/bin/env python
#coding:utf-8
import sys,argparse,os,subprocess
parser = argparse.ArgumentParser(description="Subsampling randomly extracts a certain number or a certain percentage of the sequences(fasta/fastq) in the input file. The extraction is performed as a random sampling with a uniform distribution among the input sequences and is performed without replacement")
parser.add_argument("-fa","--fasta",type=str,help="the fasta input file, '.gz' or '.bz2' file can be allowed",nargs=2)
parser.add_argument("-fq","--fastq",type=str,help="the fastq input file, '.gz' or '.bz2' file can be allowed",nargs=2)
parser.add_argument("-pct","--sample_pct",type=float,help="Subsample the given percentage of the input sequences, Accepted values range from 0.0 to 100.0")
parser.add_argument("-size","--sample_size",type=int,help="sampling size, positive integer. Extract the given number of sequences")
parser.add_argument("-seed","--randseed",type=int,default=20,help="Use integer as a seed for the pseudo-random generator. A given seed always produces the same output, which is useful for replicability, default: 20")
parser.add_argument("-o","--out",type=str,help="the output subsampled sequences file and non-subsampled sequences file",nargs=2)
args = parser.parse_args()

#soft = "/lustre/shared_softwares/vsearch/bin/vsearch" if os.path.exists("/lustre/shared_softwares/vsearch/bin/vsearch") else "/lustre/work/yongdeng/software/vsearch/vsearch/bin/vsearch"
#cmd = soft + ' --threads %d --fastx_subsample '%args.parallel
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
    if not os.path.exists(args.fastq[0]) or not os.path.exists(args.fastq[1]):
        print "%s or %s not exist!"%(args.fastq[0],args.fastq[1])
        sys.exit(1)
    cmd1 = cmd + args.fastq[0] + " "
    if args.fastq[0].endswith(".gz"):cmd1 += "--gzip_decompress "
    if args.fastq[0].endswith(".bz2"):cmd1 += "--bzip2_decompress "
    if args.sample_pct:cmd1 += "--sample_pct " + str(args.sample_pct) + " "
    if args.sample_size:cmd1 += "--sample_size " + str(args.sample_size) + " "
    cmd1 += "--fastqout " + args.out[0] + " --randseed " + str(args.randseed) + " &> /dev/null"
    cmd2 = cmd1.replace(args.fastq[0],args.fastq[1])
    cmd2 = cmd2.replace(args.out[0],args.out[1])
    if cmd1 == cmd2:
        print "filename error"
        sys.exit(1)
    
if args.fasta:
    if not os.path.exists(args.fasta[0]) or not os.path.exists(args.fasta[1]):
        print "%s or %s not exist!"%(args.fasta[0],args.fasta[1])
        sys.exit(1)
    cmd1 = cmd + args.fasta[0] + " "
    if args.fasta[0].endswith(".gz"):cmd1 += "--gzip_decompress "
    if args.fasta[0].endswith(".bz2"):cmd1 += "--bzip2_decompress "
    if args.sample_pct:cmd1 += "--sample_pct " + str(rgs.sample_pct) + " "
    if args.sample_size:cmd1 += "--sample_size " + str(args.sample_size) + " "
    cmd1 += "--fastaout " + args.out[0] + " --randseed " + str(args.randseed) + " &> /dev/null"
    cmd2 = cmd1.replace(args.fasta[0],args.fasta[1])
    cmd2 = cmd2.replace(args.out[0],args.out[1])
    if cmd1 == cmd2:
        print "filename error"
        sys.exit(1)
print cmd1
print cmd2
p1 = subprocess.Popen(cmd1,shell=True)
p2 = subprocess.Popen(cmd2,shell=True)
p1.wait()
p2.wait()
    

    
