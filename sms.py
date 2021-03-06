#!/usr/bin/env python
#coding:utf-8
# 统计所给序列文件(fasta或fastq)的序列条数和长度(均值+标准差),总的碱基个数等等信息，（并将信息写入summary文件）。
## 脚本全面优化，结果返回更快，增加读取gz和bz2压缩文件的功能
## 对于序列的读取，采用普通的文件打开形式，未用到biopython模块，因此，暂未加入碱基质量Q20,Q30的统计功能。
   
def GzOpen(f):
    import gzip
    return gzip.open(f)

def bz2Open(f):
    import bz2file
    return bz2file.open(f)    
            
def get_memory_free():
    MemFree = os.popen('cat /proc/meminfo |grep MemFree|cut -d":" -f2').read().strip()
    MemTotal = os.popen('cat /proc/meminfo |grep MemTotal|cut -d":" -f2').read().strip()
    MemFree = int(MemFree.split()[0]) << 10  ## B
    MemTotal = int(MemTotal.split()[0]) << 10  ## B
    return MemFree,MemTotal

def N50(seq_list):
    seq_list_sorted = sorted(seq_list,reverse=True)
    N50_pos = base_sum / 2.0
    ValueSum,n50 = 0,0
    for value in seq_list_sorted:
        ValueSum += value
        if ValueSum >= N50_pos:
            n50 = value
            break
    return n50

def sum_seq(seq_list):
    import numpy                    
    seq_len=numpy.array(seq_list)
    median_len=numpy.median(seq_len)                ##序列长度的中位数
    first_len=numpy.percentile(seq_len,25)          ##25%分位数
    third_len=numpy.percentile(seq_len,75)          ##75%分位数
    std_len = numpy.std(seq_len)                    ##序列长度的标准差			
    return median_len,first_len,third_len,std_len

if __name__ == "__main__":
    import sys,os,datetime
    for file1 in sys.argv[1:]:
        file_abs= os.path.abspath(file1)
        start = datetime.datetime.now()
        if not os.path.exists(file1):
            print "Warining: %s not exists, Pass the summary, Please Check the file!" %file_abs
            continue
        seq_len=[]   		###序列长度的列表
        count_GC=0
        free_memory = get_memory_free()[0] - os.path.getsize(file1)
        if file1.endswith(".gz"):
            try:
                f1 = GzOpen(file1)
            except:
                print "Warining: %s is not a gzip type file" % file_abs
                continue          
        elif file1.endswith(".bz2"):
            try:
                f1 = bz2Open(file1)
            except:
                print "Warining: %s is not a bz2 type file" % file_abs
                continue
        else:
            f1 = open(file1)
        file_head = f1.readline()
        if file_head.startswith("@"):
            if free_memory > (2 << 30) or free_memory > int(0.1*get_memory_free()[1]):   
                f1 = f1.readlines()
                for i in range(0,len(f1),4):
                    count_GC += f1[i].strip().upper().count("G") + f1[i].strip().upper().count("C")
                    seq_len.append(len(f1[i].strip())) 
                del f1
            else:
                print "Warining: MemoryOut when summarize %s file, USE CPU module, Please Wait!" % file_abs
                for n,line in enumerate(f1):
                    if n%4 == 0:
                        count_GC += line.strip().upper().count("G") + line.strip().upper().count("C")
                        seq_len.append(len(line.strip().strip()))
        elif file_head.startswith(">"):
            seq = ""
            if free_memory > (2 << 30) or free_memory > int(0.1*get_memory_free()[1]):
                f1 = f1.readlines()
            else:
                print "Warining: MemoryOut when summarize %s file, USE CPU module, Please Wait!" % file_abs	
            for line in f1:
                if not line.strip():
                    continue
                if len(seq) and line.startswith(">"):
                    seq_len.append(len(seq))
                    count_GC += seq.upper().count("G") + seq.upper().count("C")
                    seq = ""
                else:
                    seq += line.strip()
            seq_len.append(len(seq))
            count_GC += seq.upper().count("G") + seq.upper().count("C")
            del f1
        else:
            print "\n"+"Error: "+ file_abs +" is not a sequence file, Please Check it!!!\n"
            continue        
        seq_num = len(seq_len)
        base_sum = sum(seq_len)
        max_len = max(seq_len)
        min_len = min(seq_len)
        average_len = float(base_sum)/seq_num
        average_len = int("%.0f"%float(average_len))
        N_50 = N50(seq_len)
        median_len,first_len,third_len,std_len = sum_seq(seq_len)
        GC_count = float(count_GC)/base_sum            
        GC_count = float("%.2f"%(GC_count*100))
        txt = "{:<30}	{:<30}\n{:<30}	{:<30}\n{:<30}	{:<30}\n{:<30}	{:<30}\n{:<30}	{:<30}\n{:<30}	{:<30}\n{:<30}	{:<30}\n{:<30}	{:<30}\n{:<30}	{:<30}\n{:<30}	{:<30}\n{:<30}     {:<30}".format("序列条数:",seq_num,"碱基个数:",base_sum,"GC含量:",GC_count,"最长碱基:",max_len,"最短碱基:",min_len,"N50:",N_50,"平均长度:",average_len,"中位数:",median_len,"下侧中位数:",first_len,"上侧中位数:",third_len,"标准差:",std_len)
        if seq_num >= 1 and seq_num <= 20:
            print file_abs,"\t",seq_len
            print txt
        else:
            print file_abs
            print txt
        end = datetime.datetime.now()
        print "开始时间: %s,\t耗时: %f Seconds\n" %(start.strftime("%x %X"),(end-start).total_seconds())
        del seq_len,count_GC
        
