#!/usr/bin/env python
#coding:utf-8
### ensembl下载的gtf和fa,ncbi下载的gene_info,uniport下载的uniport
### 提取欧洲牛基因组anno文件,先根据locustag判断，然后再根据symbol和chr判断,测试失败

# awk '$3=="gene"{print}' *.gtf |head
# cut -f 1-4,7,9 *.gene_info|grep "gene_name" |head

import os,sys,re,tab,time,sqlite3
from Bio import SeqIO
from collections import  defaultdict

if len(sys.argv) == 8:
	gtf,gene_info,fa,uniport,abb,biomart,anno = sys.argv[1:]
elif len(sys.argv) == 7:
	gtf,gene_info,fa,uniport,abb,anno = sys.argv[1:]
elif len(sys.argv) == 6:
	gtf,gene_info,fa,abb,anno = sys.argv[1:]
else:
	print 'USAGE: python scripts.py gtf gene_info fasta [uniport] species_abbreviation [biomart] anno'
	sys.exit(0)
	
name = os.path.splitext(fa)[0]+".modified.fa"           ### 写入fasta文件
with open(name,"w") as fo: 
    for fa in SeqIO.parse(fa,"fasta"):
        if fa.description.endswith("REF"):
            SeqIO.write(fa,fo,"fasta")

filename_pre = "." + time.strftime('%m%d%H%M%S',time.localtime(time.time())) + ".tmp"

e2s,e2e,id_2_symbol,id_2_des = {},{},{},{}
with open(gene_info,"r") as fg:
	for i in fg:
		s = i.split("\t")[2]
		e_id = i.split("\t")[1]
		des = i.split("\t")[8] + "\n"
		id_2_des[e_id] = des
		id_2_symbol[e_id] = s
		e = re.findall('Ensembl:(.+?)\s+?',i)
		if e:
			e = e[0]
			e2s[e] = s
			e2e[e] = e_id
		
gtf_f = open(gtf,"r")
new_line = []
for line in gtf_f:
	if "\tgene\t" in line:
		a = line.split("\t")
		ensembl_id = re.findall('gene_id "(.+?)";',a[-1])
		ensembl_id = ensembl_id[0] if ensembl_id else "-"       
		symbol = re.findall('symbol "(.+?)";',a[-1])     ### 有用gene_name匹配，看gtf文件中是symbol还是gene_name
		symbol = symbol[0] if symbol else "-"
		symbol = symbol if symbol != "-" else e2s.get(ensembl_id,"-")		### 如果最后ensembl_id还是没有对应的symbol信息，则考虑用gene_info文件中的dbXrefs列（第六列）中的ensemble_id与symbol（第三列）对应, 对于ncbi和ensembl中相同的ensembol_id，不同的symbol，以ensemble数据库为准，原因是uniport数据库中的symbol信息和ensemble数据库相同，和NCBI的不同(此处可以考虑以gene_info为主)
		gene_biotype = re.findall('gene_biotype "(.+?)";',a[-1])
		gene_biotype = gene_biotype[0] if gene_biotype else "-"      ### 提取gtf文件中的信息
		new_line.append([ensembl_id,a[0],a[3],a[4],symbol,gene_biotype])                          ## ensembol_id  chr start end symbol gene_biotype
gtf_f.close()

# with open(gtf + filename_pre,"w") as gtf_tmp:
	# for i in new_line:
		# gtf_tmp.write("\t".join(i)+"\n")
	
# geneinof_all = os.popen("cut -f 1-4,7,9 " + gene_info)  ### 文件共七列，#tax_id	GeneID	Symbol	LocusTag	chromosome	description，GeneID唯一，没有重复行，Symbol有重复，symbol与gtf文件中的symbol相同。
# with open(gene_info + filename_pre,"w") as gene_info_new:
	# gene_info_new.write(geneinof_all.read())
       
geneinof_file = open(gene_info,"r")
geneinof_f = []
for gl in geneinof_file:
	z = gl.split("\t")
	geneinof_f.append([z[1],z[2],z[3],z[6],z[8]+"\n"])    ##   GeneID	Symbol	LocusTag  chromosome	description      ### description后面加上换行
geneinof_file.close()

symbol_chr_geneid_des = defaultdict(list)                           ### 提取gene_info文件中的symbol_chr对应的Entrez_id,description   
for line in geneinof_f:
	if line[1] == "-":                     ### 若symbol不存在，为"-",则忽略,避免gene_info中不存在symbol,gtf也不存在的symbol互相合并
		continue
	if "|" in line[3]:
		for k in line[3].split("|"):
			key = line[1].replace(" ","").upper() + "&" + k.upper()                ### 将symbol中的空格删除，添加上染色体信息，作为键
			symbol_chr_geneid_des[key].append(line[0])
			symbol_chr_geneid_des[key].append(line[-1]) 
	else:
		key = line[1].replace(" ","").upper() + "&" + line[3].upper()     ## 基因名去除空格，转换为大写，染色体名转换为大写
		symbol_chr_geneid_des[key].append(line[0])
		symbol_chr_geneid_des[key].append(line[-1])               ### description信息后面有换行符          

locus_geneid_des = defaultdict(list) 
for line in geneinof_f:
	if line[2] == "-":
		continue
	else:
		loc = line[2].split("_")[-1]                      ### 玉米种的locus_id去除下划线部分即为gtf文件中的ensemble_id
		locus_geneid_des[loc].append(line[0])
		locus_geneid_des[loc].append(line[1])
		locus_geneid_des[loc].append(line[-1])              ### description信息后面有换行符

entrez_geneid_des = defaultdict(list)
try:		
	biomart_f = os.popen("cut -f1,2,7 " + biomart)        ### ensembol id  entrez_id  description
	for line in biomart_f:
		mart_line = line.split("\t")
		g = mart_line[1] if mart_line[1] else "-"
		d = line.strip("\n").split("\t")[-1]
		d = d+"\n" if len(d) else "-\n"                                    ### description信息后面有换行符
		entrez_geneid_des[mart_line[0]].extend([g,d])
except:
	print "No biomart infomation"
# # for i in new_line:
	# # k = i[4] + "&" + i[1]
	# # i.insert(1,symbol_chr_geneid_des.get(k,entrez_geneid_des.get(i[0],["-"]))[0])                  ### 添加entrez_id列和description,若没有，则补充biomart中的信息，若都没有，则用"-"标识
	# # i.append(symbol_chr_geneid_des.get(k, entrez_geneid_des.get(i[0],["-\n","-\n"]))[-1])	

### 读取uniport信息，添加内容
symbol_unniport = defaultdict(str)
try:
	with open(uniport,"r") as uniport_f:
		for line in uniport_f:
			nam = line.strip("\n").split("\t")[-1].replace(" ","")
			if len(symbol_unniport[nam.upper()]):
				symbol_unniport[nam.upper()] += "," + line.split("\t")[0]
			else:
				symbol_unniport[nam.upper()] += line.split("\t")[0]	
except:
	print "No uniport file"

e_to_uniport={}
try:		
	kobas_path = "/export/software/target/kobas-3.0.1/sqlite3/"
	conn = sqlite3.connect( kobas_path + abb + ".db")		
	c= conn.cursor()
	for i in c.execute("SELECT * from GeneUniprotkbAcs"):          ##读取GeneUniprotkbAcs表
		kobas_k = str(i[0].split(":")[-1])
		if len(str(i[1].split(":")[-1])):
			e_to_uniport[kobas_k] = str(i[1].split(":")[-1])
except:
	print "species_abbreviation not in kobas %s database" % kobas_path


entry = []	
with open(anno,"w") as f:
	f.write("#Ensembl_id\tEntrez_id\tUniprot_id\tChr\tStart\tEnd\tSymbol\tGene_type\tDescription\n")
	for i in new_line:
		k = i[4].replace(" ","").upper() + "&" + i[1].upper()
 		ku = k.split("&")[0]
		q = e2e.get(i[0],locus_geneid_des.get(i[0],["-"])[0])
		q = e2e.get(i[0],symbol_chr_geneid_des.get(k,["-"])[0]) if q == "-" else q     ###  添加entrez_id列和description,若没有，则补充biomart中的信息，若都没有，则用"-"标识, 优先查找gene_info中如果有ensemble和entrez_id对应关系。
		if q != "-":
			entry.append(q)
		new_line_new_1 = q
		if entrez_geneid_des.has_key(i[0]):
			if entrez_geneid_des[i[0]][0] not in entry:
				new_line_new_1 = entrez_geneid_des.get(i[0],["-"])[0]
			else:
				new_line_new_1 = "-"
		if new_line_new_1 != "-":
			entry.append(new_line_new_1)
		new_line_new_2 = symbol_unniport.get(ku,"-")         
		if e_to_uniport.has_key(i[0]):
			new_line_new_2 = e_to_uniport[i[0]]
		if e_to_uniport.has_key(new_line_new_1):
			new_line_new_2 = e_to_uniport[new_line_new_1]                    ### 添加kobas中的uniport信息，如果kobas中有对应的uniport，则替换为kobas中的uniport	
		if i[-2] == "-":
			i[-2] = e2s.get(i[0],"-")                     ### 如果symbol为空，将gene_info文件中查到的symbol添加到列
		if i[-2] == "-":
			i[-2] = id_2_symbol.get(new_line_new_1,"-")   ## 如果symbol还是为空，将gene_info中entrez_id查到的symbol添加到列
		if new_line_new_2 == "-":
			new_line_new_2 = symbol_unniport.get(i[-2],"-")
		# else:
			# if e2s.has_key(i[0]):
				# i[-2] += "," + e2s[i[0]]       ## 将gene_info文件中查到的symbol补充到列
		new_line_new_e = id_2_des.get(new_line_new_1,"-\n")
		new_line_new_e = locus_geneid_des.get(i[0],entrez_geneid_des.get(i[0],["-\n"]))[-1] if new_line_new_e == "-\n" else new_line_new_e
		new_line_new_e = symbol_chr_geneid_des.get(k,entrez_geneid_des.get(i[0],["-\n"]))[-1] if new_line_new_e == "-\n" else new_line_new_e	
		new_line_list = [i[0],new_line_new_1,new_line_new_2]
		new_line_list.extend(i[1:])
		new_line_list.append(new_line_new_e)
		f.write("\t".join(new_line_list))



