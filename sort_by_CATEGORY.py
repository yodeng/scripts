#!/usr/bin/env python
#coding:utf-8
#将原来无需的Makeflow文件，按照CATEGORY的先后顺序进行排序，相同的CATEGORY合并到一起
import sys
from collections import OrderedDict
flow_d = OrderedDict()
with open(sys.argv[1],"r") as flow:
	v = []
	for line in flow:
		if line.startswith("CATEGORY="):
			k = line
			if len(v):
				flow_d.setdefault(keys,[]).append(v)
			v = []
		else:
			v.append(line)
			keys = k
	flow_d.setdefault(keys,[]).append(v)

with open(sys.argv[1]+"_sorted","w") as fs:
	for k,v in flow_d.iteritems():
		for l in v:
			i = "".join(l)
			fs.write(k+i)

	
#CATEGORY=annotate
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.list : /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/back.list
#	cp /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/back.list /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.list > /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.cp.out 2> /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.cp.err
#
#CATEGORY=annotate
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.ko : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.list
#	/lustre/software/target/kobas-2.0/src/annotate.py -i /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.list -t id:ncbigene -s mmu -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.ko 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.annotate.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.annotate.err
#
#CATEGORY=GO
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.tsv /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.go : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.ko /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/database/obo20150526/go-basic.obo
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/parse_kobas_annotate.pl /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.ko /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/database/obo20150526/go-basic.obo /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.parse_kobas_annotate.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.parse_kobas_annotate.err
#
#CATEGORY=annotation
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/KEGG_PATHWAY.first.class /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/KEGG_PATHWAY.first.list /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/KEGG_PATHWAY.second.class /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/KEGG_PATHWAY.second.list /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/KEGG_PATHWAY.third.class /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/KEGG_PATHWAY.third.list : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.ko
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/KobasAnnoForClassify.pl -KobasAnno /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.ko -KEGGClassify /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/database/KEGG.pathway.classify.list -od  /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/kegg.classify.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/kegg.classify.err
#
#CATEGORY=annotation
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/KEGG_PATHWAY.second.class.png /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/KEGG_PATHWAY.second.class.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/KEGG_PATHWAY.second.class
#	Rscript /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/kegg-plot.R /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/KEGG_PATHWAY.second.class /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/KEGG_PATHWAY.second.class.png /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/KEGG_PATHWAY.second.class.pdf >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/KEGG_PATHWAY.second.class.plot.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/KEGG_PATHWAY.second.class.plot.err
#
#CATEGORY=GO
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.go.normalization : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.go /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.tsv /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/database/obo20150526/go-basic.obo
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/go_normalization.pl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/database/obo20150526/go-basic.obo /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.go /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.go.normalization 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.go_normalization.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.go_normalization.err
#
#CATEGORY=anno
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.anno.xls : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.tsv /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.go.normalization /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/database/obo20150526/go-basic.obo
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/ForKobasTsv.pl -tsv /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.tsv -od /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment -database /K/R/B/p/G -go /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.go.normalization -obo /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/database/obo20150526/go-basic.obo 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.anno.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.anno.err
#
#CATEGORY=cp
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.list /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.up_down.list : /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/IB-VS-NT/deg.list /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/IB-VS-NT/deg.up_down.list
#	cp /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/IB-VS-NT/deg.list /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/IB-VS-NT/deg.up_down.list /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT > /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.cp.out 2> /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.cp.err
#
#CATEGORY=cp
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.list /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.up_down.list : /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/IR-VS-NT/deg.list /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/IR-VS-NT/deg.up_down.list
#	cp /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/IR-VS-NT/deg.list /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/IR-VS-NT/deg.up_down.list /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT > /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.cp.out 2> /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.cp.err
#
#CATEGORY=annotate
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.ko : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.list
#	/lustre/software/target/kobas-2.0/src/annotate.py -i /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.list -t id:ncbigene -s mmu -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.ko 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.annotate.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.annotate.err
#
#CATEGORY=identify
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.pathway.enrichment : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.ko /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.ko
#	/lustre/software/target/kobas-2.0/bin/identify.py -c 1 -f /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.ko -b /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.ko -d /K/R/B/p -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.pathway.enrichment 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/identify.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/identify.err
#
#CATEGORY=enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/KEGG_PATHWAY.first.class /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/KEGG_PATHWAY.first.list /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/KEGG_PATHWAY.second.class /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/KEGG_PATHWAY.second.list /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/KEGG_PATHWAY.third.class /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/KEGG_PATHWAY.third.list : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.ko /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/database/KEGG.pathway.classify.list
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/KobasAnnoForClassify.pl -KobasAnno /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.ko -KEGGClassify /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/database/KEGG.pathway.classify.list -od  /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/kegg.classify.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/kegg.classify.err
#
#CATEGORY=enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/KEGG_PATHWAY.second.class.png /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/KEGG_PATHWAY.second.class.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/KEGG_PATHWAY.second.class
#	Rscript /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/kegg-plot.R /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/KEGG_PATHWAY.second.class /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/KEGG_PATHWAY.second.class.png /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/KEGG_PATHWAY.second.class.pdf >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/KEGG_PATHWAY.second.class.plot.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/KEGG_PATHWAY.second.class.plot.err
#
#CATEGORY=Pathway
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.q_value.top.pdf /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.q_value.top.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.txt
#	Rscript /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/draw_barplot.r Pathway 30 /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.txt /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.q_value /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.q_value >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.q_value.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.q_value.err
#
#CATEGORY=Pathway
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.p_value.top.pdf /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.p_value.top.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.txt
#	Rscript /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/draw_barplot_pvalue.r Pathway 30 /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.txt /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.p_value /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.p_value >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.p_value.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.p_value.err
#
#CATEGORY=Pathway
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/Pathway.temp.xls : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.txt
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/kobas_colour1.6.pl -deg /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.up_down.list -k_anno /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.ko -k_iden /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.txt -inf /lustre/work/zhonghuali/database/genomeInfo/Mus_musculus/38.84/fa.gtf/Mus_musculus.GRCm38.84.gtf.new.gtf.gene_id.list.ENSEMBL.anno -S symbol -Y id:ncbigene -od /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT -p Pathway.temp -gc 1 -ud 3 >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.change.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.change.err
#
#CATEGORY=Pathway
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.xls : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/Pathway.temp.xls
#	cut -f 1-13 /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/Pathway.temp.xls >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.xls
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.go.class /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.go.enrichment : /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/database/obo20150526/go-basic.obo /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.up_down.list /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.go.normalization
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/function_and_saturation/RNA-Seq_Anno3_enrichmentV1.pl -g /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/database/obo20150526/go-basic.obo -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT -q deg. /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.go.normalization /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.up_down.list >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/RNA-Seq_Anno3_enrichmentV1.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/RNA-Seq_Anno3_enrichmentV1.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.go.class.png /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.go.class.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.go.class
#	Rscript /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/GO_class.r /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.go.class /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.go.class.png /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.go.class.pdf>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.go.class.png.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.go.class.png.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.xls : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.go.enrichment /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.pathway.enrichment
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/ForKobasDot_v1.1.pl -ge /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.go.enrichment -ke /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.pathway.enrichment -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/ForKobasDot.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/ForKobasDot.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.molecular_function.dot /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.cellular_component.dot /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.biological_process.dot /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.txt /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Pathway.txt /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.Disease.txt : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.xls
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/parse_kobas_identify.pl /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.xls /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/database/obo20150526/go-basic.obo 30 /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/parse_kobas_identify.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/parse_kobas_identify.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.biological_process.png : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.biological_process.dot
#	dot -Tpng -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.biological_process.png /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.biological_process.dot 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/biological_process.png.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/biological_process.png.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.biological_process.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.biological_process.dot
#	dot -Tpdf -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.biological_process.pdf /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.biological_process.dot 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/biological_process.pdf.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/biological_process.pdf.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.cellular_component.png : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.cellular_component.dot
#	dot -Tpng -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.cellular_component.png /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.cellular_component.dot 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/cellular_component.png.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/cellular_component.png.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.cellular_component.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.cellular_component.dot
#	dot -Tpdf -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.cellular_component.pdf /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.cellular_component.dot 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/cellular_component.pdf.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/cellular_component.pdf.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.molecular_function.png : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.molecular_function.dot
#	dot -Tpng -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.molecular_function.png /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.molecular_function.dot 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/molecular_function.png.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/molecular_function.png.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.molecular_function.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.molecular_function.dot
#	dot -Tpdf -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.molecular_function.pdf /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.hierarchy.molecular_function.dot 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/molecular_function.pdf.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/molecular_function.pdf.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.q_value.top.pdf /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.q_value.top.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.txt
#	Rscript /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/draw_barplot.r GO 30 /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.txt /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.q_value /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.q_value >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.q_value.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.q_value.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.p_value.top.pdf /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.p_value.top.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.txt
#	Rscript /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/draw_barplot_pvalue.r GO 30 /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.txt /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.p_value /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.p_value >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.p_value.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.p_value.err
#
#CATEGORY=GO
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/GO.temp.xls : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.txt
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/kobas_colour1.6.pl -deg /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.up_down.list -k_anno /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/deg.ko -k_iden /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.txt -inf /lustre/work/zhonghuali/database/genomeInfo/Mus_musculus/38.84/fa.gtf/Mus_musculus.GRCm38.84.gtf.new.gtf.gene_id.list.ENSEMBL.anno -S symbol -Y id:ncbigene -od /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT -p GO.temp -gc 1 -ud 3 >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.change.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.change.err
#
#CATEGORY=GO
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.xls : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/GO.temp.xls
#	cut -f 1-13 /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/GO.temp.xls >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IB-VS-NT/enrichment.GO.xls
#
#CATEGORY=annotate
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.ko : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.list
#	/lustre/software/target/kobas-2.0/src/annotate.py -i /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.list -t id:ncbigene -s mmu -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.ko 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.annotate.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.annotate.err
#
#CATEGORY=identify
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.pathway.enrichment : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.ko /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.ko
#	/lustre/software/target/kobas-2.0/bin/identify.py -c 1 -f /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.ko -b /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.ko -d /K/R/B/p -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.pathway.enrichment 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/identify.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/identify.err
#
#CATEGORY=enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/KEGG_PATHWAY.first.class /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/KEGG_PATHWAY.first.list /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/KEGG_PATHWAY.second.class /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/KEGG_PATHWAY.second.list /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/KEGG_PATHWAY.third.class /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/KEGG_PATHWAY.third.list : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.ko /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/database/KEGG.pathway.classify.list
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/KobasAnnoForClassify.pl -KobasAnno /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.ko -KEGGClassify /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/database/KEGG.pathway.classify.list -od  /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/kegg.classify.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/kegg.classify.err
#
#CATEGORY=enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/KEGG_PATHWAY.second.class.png /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/KEGG_PATHWAY.second.class.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/KEGG_PATHWAY.second.class
#	Rscript /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/kegg-plot.R /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/KEGG_PATHWAY.second.class /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/KEGG_PATHWAY.second.class.png /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/KEGG_PATHWAY.second.class.pdf >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/KEGG_PATHWAY.second.class.plot.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/KEGG_PATHWAY.second.class.plot.err
#
#CATEGORY=Pathway
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.q_value.top.pdf /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.q_value.top.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.txt
#	Rscript /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/draw_barplot.r Pathway 30 /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.txt /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.q_value /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.q_value >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.q_value.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.q_value.err
#
#CATEGORY=Pathway
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.p_value.top.pdf /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.p_value.top.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.txt
#	Rscript /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/draw_barplot_pvalue.r Pathway 30 /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.txt /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.p_value /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.p_value >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.p_value.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.p_value.err
#
#CATEGORY=Pathway
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/Pathway.temp.xls : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.txt
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/kobas_colour1.6.pl -deg /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.up_down.list -k_anno /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.ko -k_iden /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.txt -inf /lustre/work/zhonghuali/database/genomeInfo/Mus_musculus/38.84/fa.gtf/Mus_musculus.GRCm38.84.gtf.new.gtf.gene_id.list.ENSEMBL.anno -S symbol -Y id:ncbigene -od /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT -p Pathway.temp -gc 1 -ud 3 >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.change.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.change.err
#
#CATEGORY=Pathway
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.xls : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/Pathway.temp.xls
#	cut -f 1-13 /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/Pathway.temp.xls >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.xls
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.go.class /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.go.enrichment : /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/database/obo20150526/go-basic.obo /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.up_down.list /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.go.normalization
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/function_and_saturation/RNA-Seq_Anno3_enrichmentV1.pl -g /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/database/obo20150526/go-basic.obo -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT -q deg. /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.go.normalization /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.up_down.list >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/RNA-Seq_Anno3_enrichmentV1.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/RNA-Seq_Anno3_enrichmentV1.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.go.class.png /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.go.class.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.go.class
#	Rscript /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/GO_class.r /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.go.class /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.go.class.png /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.go.class.pdf>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.go.class.png.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.go.class.png.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.xls : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.go.enrichment /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.pathway.enrichment
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/ForKobasDot_v1.1.pl -ge /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.go.enrichment -ke /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.pathway.enrichment -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/ForKobasDot.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/ForKobasDot.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.molecular_function.dot /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.cellular_component.dot /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.biological_process.dot /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.txt /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Pathway.txt /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.Disease.txt : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.xls
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/parse_kobas_identify.pl /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.xls /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/database/obo20150526/go-basic.obo 30 /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/parse_kobas_identify.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/parse_kobas_identify.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.biological_process.png : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.biological_process.dot
#	dot -Tpng -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.biological_process.png /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.biological_process.dot 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/biological_process.png.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/biological_process.png.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.biological_process.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.biological_process.dot
#	dot -Tpdf -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.biological_process.pdf /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.biological_process.dot 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/biological_process.pdf.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/biological_process.pdf.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.cellular_component.png : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.cellular_component.dot
#	dot -Tpng -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.cellular_component.png /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.cellular_component.dot 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/cellular_component.png.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/cellular_component.png.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.cellular_component.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.cellular_component.dot
#	dot -Tpdf -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.cellular_component.pdf /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.cellular_component.dot 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/cellular_component.pdf.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/cellular_component.pdf.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.molecular_function.png : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.molecular_function.dot
#	dot -Tpng -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.molecular_function.png /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.molecular_function.dot 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/molecular_function.png.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/molecular_function.png.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.molecular_function.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.molecular_function.dot
#	dot -Tpdf -o /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.molecular_function.pdf /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.hierarchy.molecular_function.dot 1>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/molecular_function.pdf.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/molecular_function.pdf.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.q_value.top.pdf /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.q_value.top.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.txt
#	Rscript /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/draw_barplot.r GO 30 /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.txt /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.q_value /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.q_value >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.q_value.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.q_value.err
#
#CATEGORY=gene_ontology_enrichment
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.p_value.top.pdf /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.p_value.top.pdf : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.txt
#	Rscript /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/program/draw_barplot_pvalue.r GO 30 /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.txt /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.p_value /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.p_value >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.p_value.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.p_value.err
#
#CATEGORY=GO
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/GO.temp.xls : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.txt
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/kobas/kobas_colour1.6.pl -deg /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.up_down.list -k_anno /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/deg.ko -k_iden /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.txt -inf /lustre/work/zhonghuali/database/genomeInfo/Mus_musculus/38.84/fa.gtf/Mus_musculus.GRCm38.84.gtf.new.gtf.gene_id.list.ENSEMBL.anno -S symbol -Y id:ncbigene -od /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT -p GO.temp -gc 1 -ud 3 >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.change.out 2>/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.change.err
#
#CATEGORY=GO
#/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.xls : /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/GO.temp.xls
#	cut -f 1-13 /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/GO.temp.xls >/mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/IR-VS-NT/enrichment.GO.xls
#
#CATEGORY=cuffdiff
#/mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/gene.fpkm.diff.anno : /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffnorm/genes.fpkm_table.final.table /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/IB-VS-NT/IB-VS-NT.txt /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/IR-VS-NT/IR-VS-NT.txt /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.anno.xls
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/total.gene.fpkm.diff.anno.v1.5.pl -diffdir /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff -fpkm /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffnorm/genes.fpkm_table.final.table -anno /lustre/work/zhonghuali/database/genomeInfo/Mus_musculus/38.84/fa.gtf/Mus_musculus.GRCm38.84.gtf.new.gtf.gene_id.list.ENSEMBL.anno -refid_type Ref_id -kobasid_type id:ncbigene -kobasbacktsv /mnt/icfs/work/yongdeng/Project/161565/analysis/enrichment/back.anno.xls > /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/total.gene.out 2> /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/total.gene.err
#
#CATEGORY=cuffdiff
#/mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/gene.fpkm.anno.list /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/gene.anno.txt : /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/gene.fpkm.diff.anno
#	perl /lustre/work/zhonghuali/software/rna.ref/bin/go_kegg/total.fpkm.anno.pl -total /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/gene.fpkm.diff.anno > /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/gene.fpkm.diff.anno.out 2> /mnt/icfs/work/yongdeng/Project/161565/analysis/cuffdiff/gene.fpkm.diff.anno.err
#
