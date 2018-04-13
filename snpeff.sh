#!/bin/bash
fa=`readlink -f $2`
gtf=`readlink -f $3`
d=/lustre/work/minzhao/software/snpEff/data/$1
if [ -e $d ];then
	echo "path $d exist, please used another name"
	exit 0
fi
mkdir /lustre/work/minzhao/software/snpEff/data/$1
ln -s $fa /lustre/work/minzhao/software/snpEff/data/$1/sequences.fa
ln -s $gtf /lustre/work/minzhao/software/snpEff/data/$1/genes.gtf
sed -i "136i $1.genome : $1" /lustre/work/minzhao/software/snpEff/snpEff.config
cd /lustre/work/minzhao/software/snpEff
java -jar snpEff.jar build -gtf22 -v $1
cd -
