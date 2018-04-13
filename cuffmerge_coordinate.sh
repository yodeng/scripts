#!/bin/bash
### cuffmerge出现转录本位置超出错误的解决
if [ $# -ne 2 ];then
	echo "cuffmerge_coordinate.sh assembly_GTF_list.txt fasta_Ref.fa"
	exit 0
fi
assembly_GTF_list=$1
fa=$2    ## fasta序列绝对路径
fa_path=`dirname $2`
while read line;do
	mv $line ${line%/*}/pre-transcripts.gtf
done < $assembly_GTF_list
#awk '/^>/&&NR>1{print "";}{ printf "%s",/^>/ ? $0"\t":$0 }END{printf "\n"}' $fa |awk 'BEGIN{FS = "\t"}{a=match($1," ");print substr($1,2,a-2)"\t"length($NF)}' > $fa_path/fa_scaffold.length.txt
sed -e 's/^>//g' -e 's/\/len=//g' ${fa}.hdrs |tr ' ' '\t'|cut -f1,2 > $fa_path/fa_scaffold.length.txt

cuff=`head -1 $assembly_GTF_list`
cufflinks_dir=${cuff%cufflinks*}cufflinks
pre_gtf=`find ${cufflinks_dir} -name pre-transcripts.gtf`
for i in $pre_gtf;do
	gtf=${i%/*}/transcripts.gtf
	perl /lustre/work/zhonghuali/software/rna.ref/correct_cufflinksgtf_wrongpos/check.chr_length.pl $i $fa_path/fa_scaffold.length.txt > $gtf
done
