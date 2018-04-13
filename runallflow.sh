#!/bin/bash
if [ $# -ne 1 ];then
echo "runallflow config_file"
exit 0
fi
perl /lustre/work/zhonghuali/software/rna.ref/bin/creat.all.makeflow.pl -config $1 -od ./ -name Makeflow
bash makeflow.sh
makeflow -T sge --log-verbose Makeflow  > out 2> e.out 

