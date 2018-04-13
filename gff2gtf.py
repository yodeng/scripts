#!/usr/bin/env python
#coding:utf-8
### 
import sys,re
from collections import  OrderedDict
import argparse


parser = argparse.ArgumentParser(description="This Script is used for Changing The input gff3 file from NCBI download to gtf file, It can deal with the most species' gff file.")
parser.add_argument("-t","--genometype",type=str,choices=["p","e"],help='The genometype of you species, "p" for protokaryon and "e" for eukaryon')
parser.add_argument("-i","--input",type=str,help="The input gff3 file from NCBI download")
parser.add_argument("-o","--output",type=str,help="The output gtf file name")
parser.add_argument("-v","--version",action="version",version='%(prog)s 1.0')
args = parser.parse_args()


def _flatten_features(rec):
    """Make sub_features in an input rec flat for output.
    GenBank does not handle nested features, so we want to make
    everything top level.
    """
    out = []
    for f in rec.features:
        cur = [f]
        while len(cur) > 0:
            nextf = []
            for curf in cur:
                out.append(curf)
                if len(curf.sub_features) > 0:
                    nextf.extend(curf.sub_features)
            cur = nextf
    rec.features = out
    return rec
	
def sort_exon_cds(f,exon_n):
	sorted_rna = []
	for i in f[:exon_n]:
		for j in f[exon_n:]:
			if j.location.start>=i.location.start and j.location.end <= i.location.end:
				sorted_rna.extend([i,j])
				break
		else:
			sorted_rna.append(i)
	return sorted_rna


def protokaryon(gff_group_list):
	for gene in gff_group_list:       
		gene = map(lambda x:x.strip() + ";",gene)
		gene_name = gene[0]
		gene.sort(key=lambda x:x.split("\t")[3]) if gene_name.split("\t")[6] == "+" else gene.sort(key=lambda x:x.split("\t")[3],reverse=True)
		
		pre_gene_line = "\t".join(gene_name.split("\t")[:-1]) + "\t"
			
		gene_str = "".join(gene)
		
		symbol = re.findall('gene=(.+?);.*',gene_name)
		symbol = symbol if symbol else re.findall('Name=(.+?);.*',gene_name)
		gene_biotype = re.findall('gene_biotype=(.+?);.*',gene_name)
		gene_id = re.findall('GeneID:(.+?)\D+?',gene_name)
		locus_id = re.findall('locus_tag=(.+?);.*',gene_name)
		if locus_id:
			gene_id = locus_id
		gene_s = 'gene_id "' + gene_id[0] + '"; ' + 'symbol "' + symbol[0] + '"; ' + 'gene_biotype "' + gene_biotype[0] + '"; '		
		if re.findall('old_locus_tag=(.+?);.*',gene_name):		
		    gene_s += 'old_locus_tag "' + re.findall('old_locus_tag=(.+?);.*',gene_name)[0] + '"; '
		gene_s_p = gene_s + 'product "' + re.findall('product=(.+?);.*',gene_str)[0]  + '"; ' if re.findall('product=(.+?);.*',gene_str) else gene_s  ### 原核生物一个基因只产生一个product,真核则不同,因此原核生物写入product信息，真核则不写入
		transcript_id = re.findall(';transcript_id=(.+?);.*',gene_str)	
		transcript_id = transcript_id if transcript_id else [gene_id[0] + "_T"]
		protein_id = re.findall(';protein_id=(.+?);.*',gene_str)
		protein_id = protein_id if protein_id else [gene_id[0] + "_P"]
		exon_n = "1"
		isbt = gene_s_p + 'transcript_id "' + transcript_id[0] + '"; '
		isbte = isbt + 'exon_num "' + exon_n + '"; '
		isbtep = isbte + 'protein_id "' + protein_id[0] + '"; '
		
		gtf.write(pre_gene_line + gene_s + "\n")
		if len(gene) == 1:
			ll = pre_gene_line.replace("\t"+pre_gene_line.split("\t")[2]+"\t","\ttranscript\t") 
			gtf.write(ll + isbt + "\n")
			gtf.write( ll.replace("\ttranscript\t","\texon\t") + isbte + "\n")
			continue
		if "\tCDS\t" in gene_str:	
			gtf.write(pre_gene_line.replace("\tgene\t","\tmRNA\t") + isbt + "\n")
			gtf.write(pre_gene_line.replace("\tgene\t","\texon\t") + isbte + "\n")
			gtf.write(pre_gene_line.replace("\tgene\t","\tCDS\t") + isbtep + "\n")
		else:
			p  = gene[1].rpartition("\t")[0] + "\t"
			type_g = p.split("\t")[2]
			gtf.write(p + isbt + "\n")                
			gtf.write(p.replace("\t" + type_g + "\t","\texon\t") + isbte + "\n")      		

if __name__ == '__main__':
	gtf = open(args.output,"w") 
	if args.genometype == "e":
		try:
			from BCBio import GFF
		except:
			print "No GFF Parser in you Python enveriment, please install this modules. You can easy install this modules by 'pip install bcbio-gff biopython'."
			sys.exit(0)
		try:
			gff=GFF.parse(args.input)
		except:
			print "The gff file can not parse by GFF Parser, please check you file"
			sys.exit(0)
		for rec in gff:
			gff_gene=OrderedDict()
			all_features = _flatten_features(rec).features
			for feature in all_features:
				if feature.type in ["sequence_feature","region" ,"match" , "cDNA_match", "sequence_feature"] : 
					continue
				if "gene" in feature.id:   
					gene_num = feature.id
					gff_gene.setdefault(gene_num,[]).append(feature)
				else:
				    try:
				        gff_gene[gene_num].append(feature)
				    except:
				        continue
			for gene,gene_feature in gff_gene.items():
				new_gene_feature = []
				new_gene_feature.append(gene_feature[0])
				rna = OrderedDict()
				rna_feature = {}
				for feature in gene_feature[1:]:
					if feature.qualifiers['Parent'][0] == gene:
							rna[feature.id] =[]
							rna_feature[feature.id] = feature
							continue
					else:
						rna[feature.qualifiers['Parent'][0]].append(feature)
				for r,f in 	rna.items():
					exons = map(lambda x:x.type,f).count("exon")
					new_gene_feature.append(rna_feature[r])
					rna[r] = sort_exon_cds(f,exons)
					new_gene_feature.extend(rna[r])
				
				symbol = gene_feature[0].qualifiers.get("gene",feature.qualifiers.get("Name",[""]))[0]
				biotype = gene_feature[0].qualifiers.get("gene_biotype")[0]
				try:
					gi = [gene_feature[0].qualifiers.get("Dbxref")[0].split(":")[-1]]
					gene_id = gene_feature[0].qualifiers.get("locus_tag",gi)[0]
					se = 'gene_id "' + gene_id + '"; ' +   'symbol "' + symbol + '"; ' + 'gene_biotype "' + biotype + '"; '
				except:
					se = 'symbol "' + symbol + '"; ' + 'gene_biotype "' + biotype + '"; '
				for feature in new_gene_feature:
					strand = "+" if feature.strand == 1 else "-"
					score = feature.qualifiers["score"][0] if feature.qualifiers.has_key("score") else "."
					phase = feature.qualifiers["phase"][0] if feature.qualifiers.has_key("phase") else "."
					l = [rec.id, feature.qualifiers["source"][0], feature.type, str(feature.location.start+1), str(feature.location.end), score, strand, phase]
					s = "\t".join(l) + "\t"
					if feature.type == "gene":
						gtf.write( s + se  + "\n"  )
						
					elif feature.qualifiers['Parent'][0] == gene:
						try:
							transcript_id = feature.qualifiers.get("transcript_id")[0]
							sr = se + 'transcript_id "' + transcript_id + '"; '
						except:
							pass
						gtf.write(s + sr + "\n")
						exon_num = 1
					
					elif feature.type == "exon":
						see = sr + 'exon_num "' + str(exon_num) + '"; '
						exon_num += 1
						gtf.write(s + see + "\n")
					
					elif feature.type == "CDS":
						protein_id = feature.qualifiers.get("protein_id")[0]
						sp = see + 'protein_id "' + protein_id + '"; '
						gtf.write( s + sp + "\n")
					else:
						continue
		gtf.close()	
	elif args.genometype == "p":
		gff_group = []
		with open(args.input,"r") as gff:
			for line in gff:
				if not line.strip() or "\tregion\t" in line:
					continue
				elif line.startswith("#"):
					gtf.write(line)
				else:
					if "ID=gene" in line:
						gff_group.append([line])
					elif "Parent=" in line:
						gff_group[-1].append(line)
		protokaryon(gff_group)
		gtf.close()
	else:
		print "Please Choice the correct genometype of you species"
		gtf.close()
		sys.exit
	
	
