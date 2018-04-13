#!/bin/bash
pwd=$PWD
perl /lustre/work/zhonghuali/software/rna.ref/bin/get.makeflowresult.makeflow.pl -config config.txt -od ./ -name results_makeflow
nohup makeflow -T sge --log-verbose results_makeflow > result_out 2> result_e.out
grep '	cp' results_makeflow |awk '{print substr($0,1,index($0,">")-1)}' > cp.tmp
bash cp.tmp
## for i in `find results/ -name '*.xlsx'`;do du -sh $i; done
cd `readlink -f results`
mkdir xlsx_txt
cd xlsx_txt
for i in `find ../ -name '*.xlsx'`;do
	a=${i#*/}
	dir=${a%/*}
	name=${i##*/}
	mkdir -p $dir
	txt=$dir/$name.txt
	tab_csv_xlsx.py -f x2t -i $i -o $txt
	if [ $? -ne 0 ];then
		echo "###### convert "$i" error ####"
	fi
done
python `which cp_png.py`
cd $pwd
