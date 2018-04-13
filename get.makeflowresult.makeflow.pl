#! perl -w 
use Getopt::Long;
use File::Basename;

my  ($config,$help,$name,$od)=("","","","");

GetOptions(
	"config=s"	=>\$config,
	"od=s"	=>\$od,
	"name=s"	=>\$name,
	"h|help!"	=>\$help,
);

sub usage{
	print<<DO
	
	This program is to get the combination of all the modules you want 
	
	perl $0 -config [config file] -od [output directory] -name [makeflow name]
	
	#add the filter parts for propro and coexpression preparing for Cytoscape

	-config	all the information needed in later analysis
	-od	project directory and bash file output directory
	-name	makeflow name
	-h|help	help option
	
DO
}

my ($rawdata,$cleandata,$align,$cuffnorm,$nocufflinks,$cufflinks,$cuffdiff,$gokegg,$asprofile,$cluster,$coexpression,$fusion,$snp,$noveltranscripts,$propro)=("","","","","","","","","","","","","","");
my $ooops=0;
if(!$config or !-f $config){
	print "we need the config file containing analysis modules, repeat samples, and comparative groups\n";
	$ooops=1;
}
if(!$od){
	print "we need the project directory you run as the makeflow output od\n";
	$ooops=1;
}
if($ooops==1){
	&usage;
	exit;
}

my $kobasdb;
my @VS;
$config=&ABSOLUTE_DIR($config);
open CONFIG,"<",$config;
while(<CONFIG>){
	if(/^moduels=(\S+)/){
		my $allmoduels=$+;
		my @moduels=split /;/,$allmoduels;
		for my $ele(@moduels){
			#print "$ele\n";
			if($ele=~/rawdata/i){
				$rawdata=1;next
			}
			elsif($ele=~/cleandata/i){
				$cleandata=1;next
			}
			elsif($ele=~/align|alignment/i){
				$align=1;next 
			}
			elsif($ele=~/cuffnorm|^expression/){
				$cuffnorm=1;next
			}
			elsif($ele=~/^cufflinks/i){
				$cufflinks=1;next 
			}
			elsif($ele=~/^nocufflinks/i){
				$nocufflinks=1;next 
			}
			elsif($ele=~/noveltranscripts|novel_transcripts|novel_transcript|novel_isoforms|noveltranscript/i){
				$noveltranscripts=1;next
			}
			elsif($ele=~/cuffdiff/i){
				$cuffdiff=1;next 
			}
			elsif($ele=~/gokegg|go_kegg|enrichment/i){
				$gokegg=1;next 
			}
			elsif($ele=~/asprofile|alternative_splicing/i){
				$asprofile=1;next 
			}
			elsif($ele=~/cluster|clusters/i){
				$cluster=1;next 
			}
			elsif($ele=~/coexpression/i){
				$coexpression=1;next
			}
			elsif($ele=~/snp/i){
				$snp=1;next
			}
			elsif($ele=~/propro|protein_interaction|pro-pro|pro_pro/i){
				$propro=1;next
			}
		}
	}
	elsif(/^kobasdb=(\S+)/){
		$kobasdb=$+;next
	}
	elsif(/^vs=(\S+)/){
		my $vs1=$+;
		my @vs1=split /;/,$vs1;
		for my $ele(@vs1){
			$ele=~s/\(//g;
			$ele=~s/\)//g;
			push @VS,$ele;
			}
	}
}

my $samples=$config;
my @samples;
if(-f $samples){
	$samples=&ABSOLUTE_DIR($samples);
	open SAM,"<",$samples;
	while(<SAM>){
		chomp;
		next if(/^#|^\s+/);
		if(/^rep=(\S+)/){
			my $sample=$+;
			my @rep=split /;/,$sample;
			for my $ele(@rep){
				if($ele=~/=(\S+?)\)/){
					my $samplesss=$+;
					my @samplessss=split /,/,$samplesss;
					for my $samele(@samplessss){
						push @samples,$samele;
					}
				}
				else{
					push @samples,$ele;
				}
			}
			last;	
		}
		elsif($_=~/;/ and $_!~/-VS-/i){
			my @rep=split /;/;
			for my $repele(@rep){
				push @samples, $repele;
			}
			last;
		}	
	}
}
else{
	my @rep=split /;/;
	for my $repele(@rep){
		push @samples, $repele;
	}
}
my %hash;
@samples=grep {++$hash{$_}<2} @samples;

`mkdir $od` if(!-d $od);
$od=&ABSOLUTE_DIR($od);
if(!-d "$od/analysis"){
	print "we can't find the $od/analysis directory; Please check your $od directory\n";
	exit;
}
`mkdir $od/results` if(!-d "$od/results");
open MAKEFLOW,">>", "$od/$name";

my $report=0;

if($cleandata){

	$report++;
	`mkdir $od/results/$report.quality_control` if(!-d "$od/results/$report.quality_control");
	`mkdir $od/results/$report.quality_control/rawdata` if(!-d "$od/results/$report.quality_control/rawdata");
	`mkdir $od/results/$report.quality_control/cleandata` if(!-d "$od/results/$report.quality_control/cleandata");
	
	for my $key(@samples){
	
		`mkdir $od/results/$report.quality_control/rawdata/$key` if(!-d "$od/results/$report.quality_control/rawdata/$key");
		`mkdir $od/results/$report.quality_control/rawdata/$key/R1` if(!-d "$od/results/$report.quality_control/rawdata/$key/R1");
		`mkdir $od/results/$report.quality_control/rawdata/$key/R2` if(!-d "$od/results/$report.quality_control/rawdata/$key/R2");
		
		`mkdir $od/results/$report.quality_control/cleandata/$key` if(!-d "$od/results/$report.quality_control/cleandata/$key");
		`mkdir $od/results/$report.quality_control/cleandata/$key/R1` if(!-d "$od/results/$report.quality_control/cleandata/$key/R1");
		`mkdir $od/results/$report.quality_control/cleandata/$key/R2` if(!-d "$od/results/$report.quality_control/cleandata/$key/R2");

		print MAKEFLOW "CATEGORY=fastqcRaw\n";
		print MAKEFLOW "$od/results/$report.quality_control/rawdata/$key/R1/per_base_quality.png $od/results/$report.quality_control/rawdata/$key/R1/per_base_sequence_content.png : $od/analysis/fastqcRaw/$key/R1.fq_fastqc/Images/per_base_sequence_content.png $od/analysis/fastqcRaw/$key/R1.fq_fastqc/Images/per_base_quality.png\n";
		print MAKEFLOW "\tcp $od/analysis/fastqcRaw/$key/R1.fq_fastqc/Images/per_base_sequence_content.png $od/analysis/fastqcRaw/$key/R1.fq_fastqc/Images/per_base_quality.png $od/results/$report.quality_control/rawdata/$key/R1 > $od/analysis/fastqcRaw/$key/R1.fq_fastqc/Images/R1.cp.out 2> $od/analysis/fastqcRaw/$key/R1.fq_fastqc/Images/R1.cp.err\n\n";
		
		print MAKEFLOW "CATEGORY=fastqcRaw\n";
		print MAKEFLOW "$od/results/$report.quality_control/rawdata/$key/R2/per_base_quality.png $od/results/$report.quality_control/rawdata/$key/R2/per_base_sequence_content.png : $od/analysis/fastqcRaw/$key/R2.fq_fastqc/Images/per_base_sequence_content.png $od/analysis/fastqcRaw/$key/R2.fq_fastqc/Images/per_base_quality.png\n";
		print MAKEFLOW "\tcp $od/analysis/fastqcRaw/$key/R2.fq_fastqc/Images/per_base_sequence_content.png $od/analysis/fastqcRaw/$key/R2.fq_fastqc/Images/per_base_quality.png $od/results/$report.quality_control/rawdata/$key/R2 > $od/analysis/fastqcRaw/$key/R2.fq_fastqc/Images/R2.cp.out 2> $od/analysis/fastqcRaw/$key/R2.fq_fastqc/Images/R2.cp.err\n\n";
		
	print MAKEFLOW "CATEGORY=fastqcClean\n";
	print MAKEFLOW "$od/results/$report.quality_control/cleandata/$key/R1/per_base_sequence_content.png : $od/analysis/fastqcClean/$key/R1.clean.fq_fastqc/Images/per_base_sequence_content.png $od/analysis/fastqcClean/$key/R1.clean.fq_fastqc/Images/per_base_quality.png\n";
	print MAKEFLOW "\tcp $od/analysis/fastqcClean/$key/R1.clean.fq_fastqc/Images/per_base_sequence_content.png $od/analysis/fastqcClean/$key/R1.clean.fq_fastqc/Images/per_base_quality.png $od/results/$report.quality_control/cleandata/$key/R1 > $od/analysis/fastqcClean/$key/R1.clean.fq_fastqc/Images/fastqc.cp.out 2> $od/analysis/fastqcClean/$key/R1.clean.fq_fastqc/Images/fastqc.cp.err\n\n";
	
	print MAKEFLOW "CATEGORY=fastqcClean\n";
	print MAKEFLOW "$od/results/$report.quality_control/cleandata/$key/R1/R1.clean.fq_fastqc.zip : $od/analysis/fastqcClean/$key/R1.clean.fq_fastqc.zip\n";
	print MAKEFLOW "\tcp $od/analysis/fastqcClean/$key/R1.clean.fq_fastqc.zip $od/results/$report.quality_control/cleandata/$key/R1/R1.clean.fq_fastqc.zip\n\n";

	print MAKEFLOW "CATEGORY=fastqcClean\n";
	print MAKEFLOW "$od/results/$report.quality_control/cleandata/$key/R2/per_base_sequence_content.png : $od/analysis/fastqcClean/$key/R2.clean.fq_fastqc/Images/per_base_sequence_content.png $od/analysis/fastqcClean/$key/R2.clean.fq_fastqc/Images/per_base_quality.png\n";
	print MAKEFLOW "\tcp $od/analysis/fastqcClean/$key/R2.clean.fq_fastqc/Images/per_base_sequence_content.png $od/analysis/fastqcClean/$key/R2.clean.fq_fastqc/Images/per_base_quality.png $od/results/$report.quality_control/cleandata/$key/R2 > $od/analysis/fastqcClean/$key/R2.clean.fq_fastqc/Images/fastqc.cp.out 2> $od/analysis/fastqcClean/$key/R2.clean.fq_fastqc/Images/fastqc.cp.err\n\n";

	print MAKEFLOW "CATEGORY=fastqcClean\n";
	print MAKEFLOW "$od/results/$report.quality_control/cleandata/$key/R2/R2.clean.fq_fastqc.zip : $od/analysis/fastqcClean/$key/R2.clean.fq_fastqc.zip\n";
	print MAKEFLOW "\tcp $od/analysis/fastqcClean/$key/R2.clean.fq_fastqc.zip $od/results/$report.quality_control/cleandata/$key/R2/R2.clean.fq_fastqc.zip\n\n";
	}

	$report++;
	`mkdir $od/results/$report.cleandata` if(!-d "$od/results/$report.cleandata");
	
	for my $key(@samples){
		`mkdir $od/results/$report.cleandata/$key` if(!-d "$od/results/$report.cleandata/$key");
		
		print MAKEFLOW "CATEGORY=cleandata\n";
		print MAKEFLOW "$od/results/$report.cleandata/$key/summary.png $od/results/$report.cleandata/$key/R1_avgQual.png $od/results/$report.cleandata/$key/R2_avgQual.png : $od/analysis/cleandata/$key/summary.png $od/analysis/cleandata/$key/Filter_stat $od/analysis/cleandata/$key/R1_avgQual.png $od/analysis/cleandata/$key/R2_avgQual.png\n";
		print MAKEFLOW "\tcp $od/analysis/cleandata/$key/summary.png $od/analysis/cleandata/$key/R1_avgQual.png $od/analysis/cleandata/$key/R2_avgQual.png $od/results/$report.cleandata/$key > $od/analysis/cleandata/$key/trimming.cp.out 2> $od/analysis/cleandata/$key/trimming.cp.err\n\n";
	}
	
	print MAKEFLOW "CATEGORY=align\n";
	print MAKEFLOW "$od/analysis/cleandata/clean_data.state.xlsx : $od/analysis/cleandata/clean_data.state.txt\n";
	print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/cleandata/clean_data.state.txt $od/analysis/cleandata/clean_data.state.xlsx > $od/analysis/cleandata/align.state.xlsx.out 2> $od/analysis/cleandata/align.state.xlsx.err\n\n";

	print MAKEFLOW "CATEGORY=cleandata\n";
	print MAKEFLOW "$od/results/$report.cleandata/clean_data.state.xlsx : $od/analysis/cleandata/clean_data.state.xlsx\n";
	print MAKEFLOW "\tcp $od/analysis/cleandata/clean_data.state.xlsx $od/results/$report.cleandata/clean_data.state.xlsx > $od/analysis/cleandata/clean_data.state.cp.out 2> $od/analysis/cleandata/clean_data.state.cp.err\n\n";

}


if($align){
	
	$report++;
	`mkdir $od/results/$report.alignment_statistics` if(!-d "$od/results/$report.alignment_statistics");
	
	
	for my $key(@samples){
		`mkdir $od/results/$report.alignment_statistics/$key` if(!-d "$od/results/$report.alignment_statistics/$key");

		print MAKEFLOW "CATEGORY=picard_alignment_metrics\n";
		print MAKEFLOW "$od/results/$report.alignment_statistics/$key/element_distribution.png : $od/analysis/picard/$key/element_distribution.png $od/analysis/picard/$key/uniform_distribution.png\n";
		print MAKEFLOW "\tcp $od/analysis/picard/$key/element_distribution.png  $od/analysis/picard/$key/uniform_distribution.png $od/results/$report.alignment_statistics/$key > $od/analysis/picard/$key/distribution.cp.out 2> $od/analysis/picard/$key/distribution.cp.err\n\n";
		
		print MAKEFLOW "CATEGORY=saturation\n";
		print MAKEFLOW"$od/results/$report.alignment_statistics/$key/saturation.png : $od/analysis/picard/$key/saturation.png\n";
		print MAKEFLOW"\tcp $od/analysis/picard/$key/saturation.png $od/results/$report.alignment_statistics/$key/saturation.png > $od/analysis/picard/$key/saturation.cp.out 2> $od/analysis/picard/$key/saturation.cp.err\n\n";
	}
	
	print MAKEFLOW "CATEGORY=align\n";
	print MAKEFLOW "$od/analysis/align/align.state.xlsx : $od/analysis/align/align.state.txt\n";
	print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/align/align.state.txt $od/analysis/align/align.state.xlsx > $od/analysis/align/align.state.xlsx.out 2> $od/analysis/align/align.state.xlsx.err\n\n";

	print MAKEFLOW "CATEGORY=align\n";
	print MAKEFLOW "$od/results/$report.alignment_statistics/align.state.xlsx : $od/analysis/align/align.state.xlsx\n";
	print MAKEFLOW "\tcp $od/analysis/align/align.state.xlsx $od/results/$report.alignment_statistics/align.state.xlsx > $od/analysis/align/align.state.cp.out 2> $od/analysis/align/align.state.cp.err\n\n";
}

if($cufflinks){
	$report++;
	`mkdir $od/results/$report.assembly` if(!-d "$od/results/$report.assembly");

	print MAKEFLOW "CATEGORY=assembly\n";
	print MAKEFLOW "$od/analysis/cuffmerge/assembly.state.xlsx : $od/analysis/cuffmerge/assembly.state.txt\n";
	print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/cuffmerge/assembly.state.txt $od/analysis/cuffmerge/assembly.state.xlsx >$od/analysis/cuffmerge/state.xlsx.out 2> $od/analysis/cuffmerge/state.xlsx.err\n\n";

	print MAKEFLOW "CATEGORY=assembly\n";
	print MAKEFLOW "$od/results/$report.assembly/assembly.state.xlsx : $od/analysis/cuffmerge/assembly.state.xlsx\n";
	print MAKEFLOW "\tcp $od/analysis/cuffmerge/assembly.state.xlsx $od/results/$report.assembly/assembly.state.xlsx > $od/analysis/cuffmerge/assembly.cp.out 2> $od/analysis/cuffmerge/assembly.cp.err\n\n";
	
	print MAKEFLOW "CATEGORY=assembly\n";
	print MAKEFLOW "$od/results/$report.assembly/assembly.transcript.length_distribution.png : $od/analysis/cuffmerge/merged.gtf.filter.gtf.transcript.length_distribution.png\n";
	print MAKEFLOW "\tcp $od/analysis/cuffmerge/merged.gtf.filter.gtf.transcript.length_distribution.png  $od/results/$report.assembly/assembly.transcript.length_distribution.png > $od/analysis/cuffmerge/assembly.cp.out 2> $od/analysis/cuffmerge/assembly.cp.err\n\n";

	#print MAKEFLOW "CATEGORY=assembly\n";
	#print MAKEFLOW "$od/results/$report.assembly/allgeneseq.fa $od/results/$report.assembly/transcripts.fa : $od/analysis/cuffmerge/gene_seq/allgeneseq.fa $od/analysis/cuffmerge/gene_seq/transcripts.fa\n";
	#print MAKEFLOW "\tcp $od/analysis/cuffmerge/gene_seq/allgeneseq.fa $od/analysis/cuffmerge/gene_seq/transcripts.fa $od/results/$report.assembly/\n\n";
}
if($cuffnorm or $nocufflinks){
	$report++;
	`mkdir $od/results/$report.gene_expression` if(!-d "$od/results/$report.gene_expression");
	
	print MAKEFLOW "CATEGORY=gene_expression\n";
	print MAKEFLOW "$od/analysis/cuffnorm/gene.expression.xlsx : $od/analysis/cuffnorm/genes.fpkm_table.final.table\n";
	print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/cuffnorm/genes.fpkm_table.final.table $od/analysis/cuffnorm/gene.expression.xlsx > $od/analysis/cuffnorm/gene.expression.xlsx.out 2> $od/analysis/cuffnorm/gene.expression.xlsx.err\n\n";

	print MAKEFLOW "CATEGORY=gene_expression\n";
	print MAKEFLOW "$od/results/$report.gene_expression/gene.expression.xlsx : $od/analysis/cuffnorm/gene.expression.xlsx\n";
	print MAKEFLOW "\tcp $od/analysis/cuffnorm/gene.expression.xlsx  $od/results/$report.gene_expression/gene.expression.xlsx > $od/analysis/cuffnorm/gene.expression.out 2> $od/analysis/cuffnorm/gene_expression.err\n\n";
	
	print MAKEFLOW "CATEGORY=gene_expression\n";
        print MAKEFLOW "$od/analysis/cuffnorm/isoform.expression.xlsx : $od/analysis/cuffnorm/isoforms.fpkm_table.final.table\n";
        print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/cuffnorm/isoforms.fpkm_table.final.table $od/analysis/cuffnorm/isoform.expression.xlsx > $od/analysis/cuffnorm/isoform.expression.xlsx.out 2> $od/analysis/cuffnorm/gene.expression.isoform.xlsx.err\n\n";

	print MAKEFLOW "CATEGORY=gene_expression\n";
	print MAKEFLOW "$od/results/$report.gene_expression/isoform.expression.xlsx : $od/analysis/cuffnorm/isoform.expression.xlsx\n";
	print MAKEFLOW "\tcp $od/analysis/cuffnorm/isoform.expression.xlsx  $od/results/$report.gene_expression/isoform.expression.xlsx > $od/analysis/cuffnorm/isoform.expression.out 2> $od/analysis/cuffnorm/isoform.expression.err\n\n";
	
	if(-f "$od/analysis/cuffdiff/transid.geneid.refid.pos.txt"){

		print MAKEFLOW "CATEGORY=idtracking\n";
		print MAKEFLOW "$od/analysis/cuffdiff/transid.geneid.refid.pos.xlsx : $od/analysis/cuffdiff/transid.geneid.refid.pos.txt\n";
		print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/cuffdiff/transid.geneid.refid.pos.txt $od/analysis/cuffdiff/transid.geneid.refid.pos.xlsx > $od/analysis/cuffdiff/idmapping.xlsx.out 2> $od/analysis/cuffdiff/idmapping.xlsx.err\n\n";

		print MAKEFLOW "CATEGORY=idtracking\n";
		print MAKEFLOW "$od/results/$report.gene_expression/transid.geneid.refid.pos.xlsx : $od/analysis/cuffdiff/transid.geneid.refid.pos.xlsx\n";
		print MAKEFLOW "\tcp $od/analysis/cuffdiff/transid.geneid.refid.pos.xlsx $od/results/$report.gene_expression/transid.geneid.refid.pos.xlsx > $od/analysis/cuffnorm/idtracking.txt.out 2> $od/analysis/cuffnorm/idtracking.txt.err\n\n";	
	}
	else{
		print "Can't find the file $od/analysis/cuffdiff/transid.geneid.refid.pos.txt in $od/analysis/cuffdiff directory. Please check it\n";
	}
	
	$report++;
	`mkdir $od/results/$report.samples_correlation` if(!-d "$od/results/$report.samples_correlation");
	
	print MAKEFLOW "CATEGORY=samples_correlation\n";
	print MAKEFLOW "$od/results/$report.samples_correlation/sample.correlation.pdf : $od/analysis/cuffnorm/genes.fpkm.log2.sample_cor_matrix.pdf\n";
	print MAKEFLOW "\tcp $od/analysis/cuffnorm/genes.fpkm.log2.sample_cor_matrix.pdf  $od/results/$report.samples_correlation/sample.correlation.pdf > $od/analysis/cuffnorm/sample.correlation.out 2> $od/analysis/cuffnorm/sample.correlation.err\n\n";
	
	print MAKEFLOW "CATEGORY=samples_correlation\n";
        print MAKEFLOW "$od/analysis/cuffnorm/sample.correlation.matrix.xlsx : $od/analysis/cuffnorm/genes.fpkm.log2.result\n";
        print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/cuffnorm/genes.fpkm.log2.result $od/analysis/cuffnorm/sample.correlation.matrix.xlsx > $od/analysis/cuffnorm/sample.correlation.xlsx.out 2> $od/analysis/cuffnorm/sample.correlation.xlsx.err\n\n";

	print MAKEFLOW "CATEGORY=samples_correlation\n";
        print MAKEFLOW "$od/results/$report.samples_correlation/sample.correlation.matrix.xlsx : $od/analysis/cuffnorm/sample.correlation.matrix.xlsx\n";
        print MAKEFLOW "\tcp $od/analysis/cuffnorm/sample.correlation.matrix.xlsx $od/results/$report.samples_correlation/sample.correlation.matrix.xlsx > $od/analysis/cuffnorm/sample.correlation.txt.out 2> $od/analysis/cuffnorm/sample.correlation.txt.err\n\n";
}
=pod
if($nocufflinks){

	$report++;
	`mkdir $od/results/$report.gene_expression` if(!-d "$od/results/$report.gene_expression");
	
	print MAKEFLOW "CATEGORY=gene_expression\n";
	print MAKEFLOW "$od/analysis/cuffnorm/gene.expression.xlsx : $od/analysis/cuffnorm/genes.fpkm_table.final.table\n";
	print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/cuffnorm/genes.fpkm_table.final.table $od/analysis/cuffnorm/gene.expression.xlsx > $od/analysis/cuffnorm/gene.expression.xlsx.out 2> $od/analysis/cuffnorm/gene.expression.xlsx.err\n\n";

	print MAKEFLOW "CATEGORY=gene_expression\n";
	print MAKEFLOW "$od/results/$report.gene_expression/gene.expression.xlsx : $od/analysis/cuffnorm/gene.expression.xlsx\n";
	print MAKEFLOW "\tcp $od/analysis/cuffnorm/gene.expression.xlsx  $od/results/$report.gene_expression/gene.expression.xlsx > $od/analysis/cuffnorm/gene.expression.out 2> $od/analysis/cuffnorm/gene_expression.err\n\n";
	
	print MAKEFLOW "CATEGORY=gene_expression\n";
	print MAKEFLOW "$od/analysis/cuffnorm/isoform.expression.xlsx : $od/analysis/cuffnorm/isoforms.fpkm_table.final.table\n";
	print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/cuffnorm/isoforms.fpkm_table.final.table $od/analysis/cuffnorm/isoform.expression.xlsx > $od/analysis/cuffnorm/isoform.expression.xlsx.out 2> $od/analysis/cuffnorm/gene.expression.isoform.xlsx.err\n\n";

	print MAKEFLOW "CATEGORY=gene_expression\n";
	print MAKEFLOW "$od/results/$report.gene_expression/isoform.expression.xlsx : $od/analysis/cuffnorm/isoform.expression.xlsx\n";
	print MAKEFLOW "\tcp $od/analysis/cuffnorm/isoform.expression.xlsx  $od/results/$report.gene_expression/isoform.expression.xlsx > $od/analysis/cuffnorm/isoform.expression.out 2> $od/analysis/cuffnorm/isoform.expression.err\n\n";
	
	$report++;
	`mkdir $od/results/$report.samples_correlation` if(!-d "$od/results/$report.samples_correlation");
	
	print MAKEFLOW "CATEGORY=samples_correlation\n";
	print MAKEFLOW "$od/analysis/cuffnorm/sample.correlation.matrix.xlsx : $od/analysis/cuffnorm/genes.fpkm.log2.result\n";
	print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/cuffnorm/genes.fpkm.log2.result $od/analysis/cuffnorm/sample.correlation.matrix.xlsx > $od/analysis/cuffnorm/sample.correlation.xlsx.out 2> $od/analysis/cuffnorm/sample.correlation.xlsx.err\n\n";

	print MAKEFLOW "CATEGORY=samples_correlation\n";
	print MAKEFLOW "$od/results/$report.samples_correlation/sample.correlation.pdf : $od/analysis/cuffnorm/genes.fpkm.log2.sample_cor_matrix.pdf\n";
	print MAKEFLOW "\tcp $od/analysis/cuffnorm/genes.fpkm.log2.sample_cor_matrix.pdf  $od/results/$report.samples_correlation/sample.correlation.pdf > $od/analysis/cuffnorm/sample.correlation.out 2> $od/analysis/cuffnorm/sample.correlation.err\n\n";
	
	print MAKEFLOW "CATEGORY=samples_correlation\n";
	print MAKEFLOW "$od/results/$report.samples_correlation/sample.correlation.matrix.xlsx : $od/analysis/cuffnorm/sample.correlation.matrix.xlsx\n";
	print MAKEFLOW "\tcp $od/analysis/cuffnorm/sample.correlation.matrix.xlsx $od/results/$report.samples_correlation/sample.correlation.matrix.xlsx > $od/analysis/cuffnorm/sample.correlation.txt.out 2> $od/analysis/cuffnorm/sample.correlation.txt.err\n\n";
	
	}

=cut
if($cuffdiff){
	$report++;
	`mkdir $od/results/$report.differentially_expressed_gene` if(!-d "$od/results/$report.differentially_expressed_gene");
	
	for my $key(@VS){
		`mkdir $od/results/$report.differentially_expressed_gene/$key` if(!-d "$od/results/$report.differentially_expressed_gene/$key");
		my @txt=("$od/analysis/cuffdiff/$key/deg.up.txt","$od/analysis/cuffdiff/$key/deg.down.txt","$od/analysis/cuffdiff/$key/$key.txt");
		for my $txtfile(@txt){
			my $outfile=$txtfile;
			$outfile=~s/txt$/xlsx/g;
			print MAKEFLOW "CATEGORY=cuffdiff\n";
			print MAKEFLOW "$outfile : $txtfile\n";
			print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $txtfile $outfile\n\n";
		}
		print MAKEFLOW "CATEGORY=cuffdiff\n";
		print MAKEFLOW "$od/analysis/cuffdiff/$key/deg.divided.out : $od/analysis/cuffdiff/$key/deg.up.xlsx $od/analysis/cuffdiff/$key/deg.down.xlsx $od/analysis/cuffdiff/$key/deg.num.txt $od/analysis/cuffdiff/$key/$key.xlsx $od/analysis/cuffdiff/$key/$key.plot_scatter.png $od/analysis/cuffdiff/$key/$key.plot_valcano.png $od/analysis/cuffdiff/$key/venn.pdf\n";
		print MAKEFLOW "\tcp $od/analysis/cuffdiff/$key/deg.up.xlsx $od/analysis/cuffdiff/$key/deg.down.xlsx $od/analysis/cuffdiff/$key/deg.num.txt $od/analysis/cuffdiff/$key/$key.xlsx $od/analysis/cuffdiff/$key/$key.plot_scatter.png $od/analysis/cuffdiff/$key/$key.plot_valcano.png $od/analysis/cuffdiff/$key/venn.pdf $od/results/$report.differentially_expressed_gene/$key > $od/analysis/cuffdiff/$key/deg.divided.out 2> $od/analysis/cuffdiff/$key/deg.divided.err\n\n";
		
	}
	print MAKEFLOW "CATEGORY=cuffdiff\n";
	print MAKEFLOW "$od/results/$report.differentially_expressed_gene/deg.state.pdf : $od/analysis/cuffdiff/deg.state.pdf\n";
	print MAKEFLOW "\tcp $od/analysis/cuffdiff/deg.state.pdf $od/results/$report.differentially_expressed_gene/deg.state.pdf\n\n";
}

if($gokegg){
	$report++;
	`mkdir $od/results/$report.enrichment` if(!-d "$od/results/$report.enrichment");
	`mkdir $od/results/$report.enrichment/GO` if(!-d "$od/results/$report.enrichment/GO");
	`mkdir $od/results/$report.enrichment/Pathway` if(!-d "$od/results/$report.enrichment/Pathway");
	`mkdir $od/results/$report.enrichment/Disease` if(!-d "$od/results/$report.enrichment/Disease");
	for my $vs(@VS){
		`mkdir $od/results/$report.enrichment/GO/$vs` if(!-d "$od/results/$report.enrichment/GO/$vs");
		`mkdir $od/results/$report.enrichment/Pathway/$vs` if(!-d "$od/results/$report.enrichment/Pathway/$vs");
		`mkdir $od/results/$report.enrichment/Disease/$vs` if(!-d "$od/results/$report.enrichment/Disease/$vs");


		my @pathwaypdf;my @gopdf;my @diseasepdf;
		my @pathwaypng;my @gopng;my @diseasepng;
			
		push @pathwaypdf,"$od/analysis/enrichment/$vs/enrichment.Pathway.p_value.top.pdf";
		push @pathwaypdf,"$od/analysis/enrichment/$vs/enrichment.Pathway.q_value.top.pdf";
		#push @pathwaypng,"$od/analysis/enrichment/$vs/enrichment.Pathway.top.png";

		push @diseasepdf,"$od/analysis/enrichment/$vs/enrichment.Disease.p_value.top.pdf";
		push @diseasepdf,"$od/analysis/enrichment/$vs/enrichment.Disease.q_value.top.pdf";
		#push @diseasepng,"$od/analysis/enrichment/$vs/enrichment.Disease.top.png";
			
		push @gopdf,("$od/analysis/enrichment/$vs/enrichment.GO.p_value.top.pdf","$od/analysis/enrichment/$vs/enrichment.GO.q_value.top.pdf","$od/analysis/enrichment/$vs/enrichment.GO.hierarchy.biological_process.pdf","$od/analysis/enrichment/$vs/enrichment.GO.hierarchy.cellular_component.pdf","$od/analysis/enrichment/$vs/enrichment.GO.hierarchy.molecular_function.pdf");
		#push @gopng,("$od/analysis/enrichment/$vs/enrichment.GO.top.png","$od/analysis/enrichment/$vs/enrichment.GO.hierarchy.biological_process.png","$od/analysis/enrichment/$vs/enrichment.GO.hierarchy.cellular_component.png","$od/analysis/enrichment/$vs/enrichment.GO.hierarchy.molecular_function.png");
		
		#my $pathwaypng=join " ",@pathwaypng;
		my $pathwaypdf=join " ",@pathwaypdf;
	
		my $diseasepdf=join " ",@diseasepdf;
		#my $diseasepng=join " ",@diseasepng;
	
		#my $gopng=join " ",@gopng;
		my $gopdf=join " ",@gopdf;
		
		if($kobasdb=~/G/){
			print MAKEFLOW "CATEGORY=enrichment\n";
			print MAKEFLOW "$od/analysis/enrichment/$vs/enrichment.GO.xlsx : $od/analysis/enrichment/$vs/enrichment.GO.xls\n";
			print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/enrichment/$vs/enrichment.GO.xls $od/analysis/enrichment/$vs/enrichment.GO.xlsx > $od/analysis/enrichment/$vs/go.xlsx.out 2> $od/analysis/enrichment/$vs/go.xlsx.err\n\n";
			
			print MAKEFLOW "CATEGORY=enrichment\n";
			print MAKEFLOW "$od/analysis/enrichment/$vs/deg.go.class.xlsx : $od/analysis/enrichment/$vs/deg.go.class\n";
			print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/enrichment/$vs/deg.go.class $od/analysis/enrichment/$vs/deg.go.class.xlsx > $od/analysis/enrichment/$vs/go.class.out 2> $od/analysis/enrichment/$vs/go.class.err\n\n";

			print MAKEFLOW "CATEGORY=enrichment\n";
			print MAKEFLOW "$od/analysis/enrichment/$vs/go.cp.out : $gopdf $od/analysis/enrichment/$vs/deg.go.class.pdf $od/analysis/enrichment/$vs/enrichment.GO.xlsx $od/analysis/enrichment/$vs/deg.go.class.xlsx\n";
			print MAKEFLOW "\tcp $gopdf $od/analysis/enrichment/$vs/enrichment.GO.xlsx $od/analysis/enrichment/$vs/deg.go.class.pdf $od/analysis/enrichment/$vs/deg.go.class.xlsx $od/results/$report.enrichment/GO/$vs > $od/analysis/enrichment/$vs/go.cp.out 2> $od/analysis/enrichment/$vs/go.cp.err\n\n";
		}
		if($kobasdb=~/K/){
			print MAKEFLOW "CATEGORY=enrichment\n";
			print MAKEFLOW "$od/analysis/enrichment/$vs/enrichment.Pathway.xlsx : $od/analysis/enrichment/$vs/enrichment.Pathway.xls\n";
			print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/enrichment/$vs/enrichment.Pathway.xls $od/analysis/enrichment/$vs/enrichment.Pathway.xlsx > $od/analysis/enrichment/$vs/enrichment.xlsx.out 2> $od/analysis/enrichment/$vs/enrichment.xlsx.err\n\n";

			print MAKEFLOW "CATEGORY=enrichment\n";
			print MAKEFLOW "$od/analysis/enrichment/$vs/kegg.cp.out : $pathwaypdf $od/analysis/enrichment/$vs/enrichment.Pathway.xlsx\n";
			print MAKEFLOW "\tcp $pathwaypdf $od/analysis/enrichment/$vs/enrichment.Pathway.xlsx $od/results/$report.enrichment/Pathway/$vs > $od/analysis/enrichment/$vs/kegg.cp.out 2> $od/analysis/enrichment/$vs/kegg.cp.err\n\n";
		}
		if($kobasdb=~/[okfgN]/){
			print MAKEFLOW "CATEGORY=enrichment\n";
			print MAKEFLOW "$od/analysis/enrichment/$vs/enrichment.Disease.xlsx : $od/analysis/enrichment/$vs/enrichment.Disease.xls\n";
			print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/enrichment/$vs/enrichment.Disease.xls $od/analysis/enrichment/$vs/enrichment.Disease.xlsx > $od/analysis/enrichment/$vs/enrichment.disease.xlsx.out 2> $od/analysis/enrichment/$vs/enrichment.disease.xlsx.err\n\n";

			print MAKEFLOW "CATEGORY=enrichment\n";
			print MAKEFLOW "$od/analysis/enrichment/$vs/disease.cp.out : $diseasepdf $od/analysis/enrichment/$vs/enrichment.Disease.xlsx\n";
			print MAKEFLOW "\tcp $diseasepdf $od/analysis/enrichment/$vs/enrichment.Disease.xlsx $od/results/$report.enrichment/Disease/$vs > $od/analysis/enrichment/$vs/disease.cp.out 2> $od/analysis/enrichment/$vs/disease.cp.err\n\n";
		}
		
		print MAKEFLOW "CATEGORY=enrichment\n";
		print MAKEFLOW "$od/analysis/enrichment/$vs/KEGG_PATHWAY.second.list.xlsx : $od/analysis/enrichment/$vs/KEGG_PATHWAY.second.list\n";
		print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/enrichment/$vs/KEGG_PATHWAY.second.list $od/analysis/enrichment/$vs/KEGG_PATHWAY.second.list.xlsx > $od/analysis/enrichment/$vs/kegg.pathway.second.xlsx.out 2> $od/analysis/enrichment/$vs/kegg.pathway.second.xlsx.out\n\n";

		print MAKEFLOW "CATEGORY=enrichment\n";
		print MAKEFLOW "$od/analysis/enrichment/$vs/kegg.2.class.png.out : $od/analysis/enrichment/$vs/KEGG_PATHWAY.second.class.pdf $od/analysis/enrichment/$vs/KEGG_PATHWAY.second.list.xlsx\n";
		print MAKEFLOW "\tcp $od/analysis/enrichment/$vs/KEGG_PATHWAY.second.list.xlsx $od/analysis/enrichment/$vs/KEGG_PATHWAY.second.class.pdf $od/results/$report.enrichment/Pathway/$vs > $od/analysis/enrichment/$vs/kegg.2.class.png.out 2> $od/analysis/enrichment/$vs/kegg.2.class.png.err\n\n";
		
	}

	print MAKEFLOW "CATEGORY=enrichment\n";
	print MAKEFLOW "$od/analysis/enrichment/KEGG_PATHWAY.second.list.xlsx : $od/analysis/enrichment/KEGG_PATHWAY.second.list\n";
	print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/enrichment/KEGG_PATHWAY.second.list $od/analysis/enrichment/KEGG_PATHWAY.second.list.xlsx >$od/analysis/enrichment/kegg.pathway.xlsx.out 2> $od/analysis/enrichment/kegg.pathway.xlsx.err\n\n";

	print MAKEFLOW "CATEGORY=enrichment\n";
	print MAKEFLOW "$od/analysis/enrichment/kegg.2.class.png.out : $od/analysis/enrichment/KEGG_PATHWAY.second.class.pdf $od/analysis/enrichment/KEGG_PATHWAY.second.list.xlsx\n";
	print MAKEFLOW "\tcp $od/analysis/enrichment/KEGG_PATHWAY.second.list.xlsx $od/analysis/enrichment/KEGG_PATHWAY.second.class.pdf $od/results/$report.enrichment/Pathway > $od/analysis/enrichment/kegg.2.class.png.out 2> $od/analysis/enrichment/kegg.2.class.png.err\n\n";
	
	$report++;
	`mkdir $od/results/$report.gene.anno` if(!-d "$od/results/$report.gene.anno");
	
	print MAKEFLOW "CATEGORY=geneanno\n";
	print MAKEFLOW "$od/analysis/cuffdiff/gene.anno.xlsx : $od/analysis/cuffdiff/gene.anno.txt\n";
	print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/cuffdiff/gene.anno.txt $od/analysis/cuffdiff/gene.anno.xlsx > $od/analysis/cuffdiff/gene.anno.xlsx.out 2> $od/analysis/cuffdiff/gene.anno.xlsx.err\n\n";

	print MAKEFLOW "CATEGORY=geneanno\n";
	print MAKEFLOW "$od/results/$report.gene.anno/gene.anno.xlsx : $od/analysis/cuffdiff/gene.anno.xlsx\n";
	print MAKEFLOW "\tcp $od/analysis/cuffdiff/gene.anno.xlsx $od/results/$report.gene.anno/gene.anno.xlsx > $od/analysis/cuffdiff/geneanno.out 2> $od/analysis/cuffdiff/geneanno.err\n\n";	
	
}

if($cluster){
	$report++;
	`mkdir $od/results/$report.cluster` if(!-d "$od/results/$report.cluster");
	
	print MAKEFLOW "CATEGORY=geneanno\n";
	print MAKEFLOW "$od/analysis/cluster/diff.exp.gene.fpkm.xlsx : $od/analysis/cluster/diff.exp.gene.fpkm.txt\n";
	print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/cluster/diff.exp.gene.fpkm.txt $od/analysis/cluster/diff.exp.gene.fpkm.xlsx > $od/analysis/cluster/diff.xlsx.out 2> $od/analysis/cluster/diff.xlsx.err\n\n";
	
	print MAKEFLOW "CATEGORY=cluster\n";
	print MAKEFLOW "$od/results/$report.cluster/diff.exp.gene.fpkm.xlsx : $od/analysis/cluster/diff.exp.gene.fpkm.xlsx\n";
	print MAKEFLOW "\tcp $od/analysis/cluster/diff.exp.gene.fpkm.xlsx $od/results/$report.cluster/diff.exp.gene.fpkm.xlsx > $od/analysis/cluster/result.xlsx.cp.out 2> $od/analysis/cluster/result.xlsx.cp.err\n";
	
	print MAKEFLOW "CATEGORY=cluster\n";
	print MAKEFLOW "$od/results/$report.cluster/cluster.samples_heatmap.pdf : $od/analysis/cluster/diff_exp.fpkm.log2.centered.genes_vs_samples_heatmap.pdf\n";
	print MAKEFLOW "\tcp $od/analysis/cluster/diff_exp.fpkm.log2.centered.genes_vs_samples_heatmap.pdf $od/results/$report.cluster/cluster.samples_heatmap.pdf > $od/analysis/cluster/cluster.cp.out 2> $od/analysis/cluster/cluster.cp.out\n\n";
	
	for my $vs(@VS){
		`mkdir $od/results/$report.cluster/$vs` if(!-d "$od/results/$report.cluster/$vs");

		print MAKEFLOW "CATEGORY=cluster\n";
		print MAKEFLOW "$od/analysis/cluster/$vs/diff.exp.gene.fpkm.xlsx : $od/analysis/cluster/$vs/diff.exp.gene.fpkm.txt\n";
		print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/cluster/$vs/diff.exp.gene.fpkm.txt $od/analysis/cluster/$vs/diff.exp.gene.fpkm.xlsx > $od/analysis/cluster/$vs/diff.xlsx.out 2> $od/analysis/cluster/$vs/diff.xlsx.err\n\n";

		print MAKEFLOW "CATEGORY=cluster\n";
		print MAKEFLOW "$od/results/$report.cluster/$vs/diff.exp.gene.fpkm.xlsx : $od/analysis/cluster/$vs/diff.exp.gene.fpkm.xlsx\n";
		print MAKEFLOW "\tcp $od/analysis/cluster/$vs/diff.exp.gene.fpkm.xlsx $od/results/$report.cluster/$vs/diff.exp.gene.fpkm.xlsx > $od/analysis/cluster/$vs/result.xlsx.cp.out\n\n";

		print MAKEFLOW "CATEGORY=cluster\n";
		print MAKEFLOW "$od/results/$report.cluster/$vs/cluster.samples_heatmap.pdf : $od/analysis/cluster/$vs/diff_exp.fpkm.log2.centered.genes_vs_samples_heatmap.pdf\n";
		print MAKEFLOW "\tcp $od/analysis/cluster/$vs/diff_exp.fpkm.log2.centered.genes_vs_samples_heatmap.pdf $od/results/$report.cluster/$vs/cluster.samples_heatmap.pdf > $od/analysis/cluster/$vs/cluster.cp.out 2> $od/analysis/cluster/$vs/cluster.cp.err\n\n";
		
	}
}

if($snp){
	$report++;
	`mkdir $od/results/$report.cSNP.InDel` if(!-d "$od/results/$report.cSNP.InDel");
	my @snptxt=("$od/analysis/snp/snp.readcount.txt","$od/analysis/snp/snpeff.state.txt","$od/analysis/snp/indel.readcount.txt","$od/analysis/snp/indeleff.state.txt","$od/analysis/snp/snpeff.filter.txt","$od/analysis/snp/indeleff.filter.txt","$od/analysis/snp/snpeff.high.filter.txt","$od/analysis/snp/indeleff.high.filter.txt");
	for my $snptxt(@snptxt){
		my $outxlsx=$snptxt;
		$outxlsx=~s/txt$/xlsx/g;
		print MAKEFLOW "CATEGORY=SNPEFF\n";
		print MAKEFLOW "$outxlsx : $snptxt\n";
		print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $snptxt $outxlsx >$snptxt.2xlsx.out 2>$snptxt.2xlsx.err\n\n";
	}

	print MAKEFLOW  "CATEGORY=SNPEFF\n";
	print MAKEFLOW  "$od/results/$report.cSNP.InDel/snpeff.csv $od/results/$report.cSNP.InDel/indeleff.csv : $od/analysis/snp/snpeff.csv $od/analysis/snp/indeleff.csv $od/analysis/snp/snpeff.vcf $od/analysis/snp/indeleff.vcf $od/analysis/snp/snpEFF.pdf $od/analysis/snp/indelEFF.pdf $od/analysis/snp/indeleff.state.xlsx $od/analysis/snp/snpeff.state.xlsx $od/analysis/snp/snp.readcount.xlsx $od/analysis/snp/indel.readcount.xlsx $od/analysis/snp/snpeff.filter.xlsx $od/analysis/snp/indeleff.filter.xlsx $od/analysis/snp/snpeff.high.filter.xlsx $od/analysis/snp/indeleff.high.filter.xlsx\n";
	print MAKEFLOW  "\tcp $od/analysis/snp/snpeff.csv $od/analysis/snp/indeleff.csv $od/analysis/snp/snpeff.vcf $od/analysis/snp/indeleff.vcf $od/analysis/snp/snpEFF.pdf $od/analysis/snp/indelEFF.pdf $od/analysis/snp/indeleff.state.xlsx $od/analysis/snp/snp.readcount.xlsx $od/analysis/snp/indel.readcount.xlsx $od/analysis/snp/snpeff.state.xlsx $od/analysis/snp/snpeff.filter.xlsx $od/analysis/snp/indeleff.filter.xlsx $od/analysis/snp/snpeff.high.filter.xlsx $od/analysis/snp/indeleff.high.filter.xlsx $od/results/$report.cSNP.InDel >$od/analysis/snp/cp.snpeff.out 2> $od/analysis/snp/cp.snpeff.err\n\n";
	
}

if($noveltranscripts){
	$report++;
	`mkdir $od/results/$report.novel_isoforms` if(!-d "$od/results/$report.novel_isoforms");
	
	print MAKEFLOW "CATEGORY=novel_transcripts\n";
	print MAKEFLOW "$od/results/$report.novel_isoforms/novel_transcripts.gtf : $od/analysis/noveltranscripts/cuffmerge/merged.gtf.filter.gtf.gff.novel_transcripts.gtf\n";
	print MAKEFLOW "\tcp $od/analysis/noveltranscripts/cuffmerge/merged.gtf.filter.gtf.gff.novel_transcripts.gtf $od/results/$report.novel_isoforms/novel_transcripts.gtf > $od/analysis/noveltranscripts/cuffmerge/novel_isoform.cp.out 2> $od/analysis/noveltranscripts/cuffmerge/novel_isoform.cp.err\n\n";

	print MAKEFLOW "CATEGORY=novel_transcripts\n";
	print MAKEFLOW "$od/analysis/noveltranscripts/novel_transcripts.state.xlsx : $od/analysis/noveltranscripts/novel_transcripts.state.txt\n";
	print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/noveltranscripts/novel_transcripts.state.txt $od/analysis/noveltranscripts/novel_transcripts.state.xlsx > $od/analysis/noveltranscripts/cuffmerge/novel_isoform.state.xlsx.out 2> $od/analysis/noveltranscripts/cuffmerge/novel_isoform.state.xlsx.err\n\n";

	print MAKEFLOW "CATEGORY=novel_transcripts\n";
	print MAKEFLOW "$od/results/$report.novel_isoforms/novel_transcripts.state.xlsx : $od/analysis/noveltranscripts/novel_transcripts.state.xlsx\n";
	print MAKEFLOW "\tcp $od/analysis/noveltranscripts/novel_transcripts.state.xlsx $od/results/$report.novel_isoforms/novel_transcripts.state.xlsx > $od/analysis/noveltranscripts/cuffmerge/novel_isoform.state.cp.out 2> $od/analysis/noveltranscripts/cuffmerge/novel_isoform.state.cp.err\n\n";
	
}

if($asprofile){
	$report++;
	`mkdir $od/results/$report.alternative_splicing` if(!-d "$od/results/$report.alternative_splicing");
	for my $key (@samples){
		`mkdir $od/results/$report.alternative_splicing/$key` if(!-d "$od/results/$report.alternative_splicing/$key");
		
		print MAKEFLOW "CATEGORY=asprofile\n";
		print MAKEFLOW "$od/analysis/asprofile/$key/ASprofile.as.info.ref.xlsx : $od/analysis/asprofile/$key/ASprofile.as.info.ref.txt\n";
		print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/asprofile/$key/ASprofile.as.info.ref.txt $od/analysis/asprofile/$key/ASprofile.as.info.ref.xlsx > $od/analysis/asprofile/$key/tab2xlsx.out 2> $od/analysis/asprofile/$key/tab2xlsx.err\n\n";
		
		print MAKEFLOW "CATEGORY=asprofile\n";
		print MAKEFLOW "$od/results/$report.alternative_splicing/$key/ASprofile.as.info.ref.xlsx : $od/analysis/asprofile/$key/ASprofile.as.info.ref.xlsx\n";
		print MAKEFLOW "\tcp $od/analysis/asprofile/$key/ASprofile.as.info.ref.xlsx $od/results/$report.alternative_splicing/$key/ASprofile.as.info.ref.xlsx > $od/analysis/asprofile/$key/ref.cp.out 2> $od/analysis/asprofile/$key/ref.cp.err\n\n";
	}
	`mkdir $od/results/$report.alternative_splicing/cuffmerge` if(!-d "$od/results/$report.alternative_splicing/cuffmerge");

	print MAKEFLOW "CATEGORY=asprofile\n";
	print MAKEFLOW "$od/analysis/asprofile/cuffmerge/ASprofile.as.info.ref.xlsx : $od/analysis/asprofile/cuffmerge/ASprofile.as.info.ref.txt\n";
	print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/asprofile/cuffmerge/ASprofile.as.info.ref.txt $od/analysis/asprofile/cuffmerge/ASprofile.as.info.ref.xlsx > $od/analysis/asprofile/cuffmerge/tab2xlsx.out 2> $od/analysis/asprofile/cuffmerge/tab2xlsx.err\n\n";

	print MAKEFLOW "CATEGORY=asprofile\n";
	print MAKEFLOW "$od/results/$report.alternative_splicing/cuffmerge/ASprofile.as.info.ref.xlsx : $od/analysis/asprofile/cuffmerge/ASprofile.as.info.ref.xlsx\n";
	print MAKEFLOW "\tcp $od/analysis/asprofile/cuffmerge/ASprofile.as.info.ref.xlsx $od/results/$report.alternative_splicing/cuffmerge/ASprofile.as.info.ref.xlsx > $od/analysis/asprofile/cuffmerge/ref.cp.out 2> $od/analysis/asprofile/cuffmerge/ref.cp.err\n\n";
	
	print MAKEFLOW "CATEGORY=asprofile\n";
	print MAKEFLOW "$od/analysis/asprofile/asprofile.state.xlsx : $od/analysis/asprofile/asprofile.state.txt\n";
	print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/asprofile/asprofile.state.txt $od/analysis/asprofile/asprofile.state.xlsx > $od/analysis/asprofile/state.xlsx.out 2> $od/analysis/asprofile/state.xlsx.err\n\n";

	print MAKEFLOW "CATEGORY=asprofile\n";
	print MAKEFLOW "$od/results/$report.alternative_splicing/asprofile.state.xlsx : $od/analysis/asprofile/asprofile.state.xlsx\n";
	print MAKEFLOW "\tcp $od/analysis/asprofile/asprofile.state.xlsx $od/results/$report.alternative_splicing/asprofile.state.xlsx > $od/analysis/asprofile/state.cp.out 2> $od/analysis/asprofile/state.cp.err\n\n";
	
}

if($coexpression){

	if(@samples<=2){
		print "all samples are just 2,which doesn't meet the coexpression rule\n";
	}
	else{
		$report++;
		`mkdir $od/results/$report.coexpression` if(!-d "$od/results/$report.coexpression");
		my @coe=glob "$od/analysis/coexpression/*/Co-Expression.xls";

		print MAKEFLOW "CATEGORY=Coexpression\n";
		print MAKEFLOW "$od/analysis/coexpression/Co-Expression.xlsx : $od/analysis/coexpression/Co-Expression.xls\n";
		print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/coexpression/Co-Expression.xls $od/analysis/coexpression/Co-Expression.xlsx > $od/analysis/coexpression/coexpression.xlsx.out 2> $od/analysis/coexpression/coexpression.xlsx.err\n\n";

		print MAKEFLOW "CATEGORY=Coexpression\n";
		print MAKEFLOW "$od/results/$report.coexpression/Co-Expression.xlsx : $od/analysis/coexpression/Co-Expression.xlsx\n";
		print MAKEFLOW "\tcp $od/analysis/coexpression/Co-Expression.xlsx $od/results/$report.coexpression/Co-Expression.xlsx > $od/analysis/coexpression/coexpression.cp.out 2> $od/analysis/coexpression/coexpression.cp.err\n\n";
	
		print MAKEFLOW "CATEGORY=Coexpression\n";
		print MAKEFLOW "$od/results/$report.coexpression/filter.coexpression.txt : $od/analysis/coexpression/filter.coexpression.txt\n";
		print MAKEFLOW "\tcp $od/analysis/coexpression/filter.coexpression.txt $od/results/$report.coexpression/filter.coexpression.txt\n\n";

		if((scalar @coe)>=1){
			for my $file(@coe){
				my $vsname=(split /\//,dirname $file)[-1];
				`mkdir $od/analysis/coexpression/$vsname` if(!-d "$od/analysis/coexpression/$vsname");
				`mkdir $od/results/$report.coexpression/$vsname` if(!-d "$od/results/$report.coexpression/$vsname");
				
				print MAKEFLOW "CATEGORY=Coexpression\n";
				print MAKEFLOW "$od/analysis/coexpression/$vsname/Co-Expression.xlsx : $od/analysis/coexpression/$vsname/Co-Expression.xls\n";
				print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/coexpression/$vsname/Co-Expression.xls $od/analysis/coexpression/$vsname/Co-Expression.xlsx > $od/analysis/coexpression/$vsname/coexpression.xlsx.out 2> $od/analysis/coexpression/$vsname/coexpression.xlsx.err\n\n";
	
				print MAKEFLOW "CATEGORY=Coexpression\n";
                	        print MAKEFLOW "$od/results/$report.coexpression/$vsname/Co-Expression.xlsx : $od/analysis/coexpression/$vsname/Co-Expression.xlsx\n";
                        	print MAKEFLOW "\tcp $od/analysis/coexpression/$vsname/Co-Expression.xlsx $od/results/$report.coexpression/$vsname/Co-Expression.xlsx > $od/analysis/coexpression/$vsname/coexpression.cp.out 2> $od/analysis/coexpression/$vsname/coexpression.cp.err\n\n";

				print MAKEFLOW "CATEGORY=Coexpression\n";
				print MAKEFLOW "$od/results/$report.coexpression/$vsname/filter.coexpression.txt : $od/analysis/coexpression/$vsname/filter.coexpression.txt\n";
				print MAKEFLOW "\tcp $od/analysis/coexpression/$vsname/filter.coexpression.txt $od/results/$report.coexpression/$vsname/filter.coexpression.txt\n\n";
	
			}
		}
	}
}

if($propro){
	$report++;
	`mkdir $od/results/$report.protein_interaction` if(!-d "$od/results/$report.protein_interaction");
	for my $vs(@VS){
		`mkdir $od/results/$report.protein_interaction/$vs` if(!-d "$od/results/$report.protein_interaction/$vs");
		
		print MAKEFLOW "CATEGORY=protein_interaction\n";
		print MAKEFLOW "$od/analysis/propro/$vs/deg.pro-pro.xlsx : $od/analysis/propro/$vs/deg.pro-pro.txt\n";
		print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/propro/$vs/deg.pro-pro.txt $od/analysis/propro/$vs/deg.pro-pro.xlsx > $od/analysis/propro/$vs/propro.xlsx.out 2> $od/analysis/propro/$vs/propro.xlsx.err\n\n";

		print MAKEFLOW "CATEGORY=protein_interaction\n";
		print MAKEFLOW "$od/results/$report.protein_interaction/$vs/deg.pro-pro.xlsx : $od/analysis/propro/$vs/deg.pro-pro.xlsx\n";
		print MAKEFLOW "\tcp $od/analysis/propro/$vs/deg.pro-pro.xlsx $od/results/$report.protein_interaction/$vs/deg.pro-pro.xlsx > $od/analysis/propro/$vs/propro.cp.out 2> $od/analysis/propro/$vs/propro.cp.err\n\n";

		print MAKEFLOW "CATEGORY=protein_interaction\n";
		print MAKEFLOW "$od/results/$report.protein_interaction/$vs/filter.propro.txt : $od/analysis/propro/$vs/filter.propro.txt\n";
		print MAKEFLOW "\tcp $od/analysis/propro/$vs/filter.propro.txt $od/results/$report.protein_interaction/$vs/filter.propro.txt\n\n";

	}
}

$report++;
`mkdir $od/results/total.table.for.DEG` if(!-d "$od/results/total.table.for.DEG");

print MAKEFLOW "CATEGORY=genetotaltable\n";
print MAKEFLOW "$od/analysis/cuffdiff/gene.fpkm.diff.anno.xlsx : $od/analysis/cuffdiff/gene.fpkm.diff.anno\n";
print MAKEFLOW "\tperl /lustre/work/zhonghuali/software/rna.ref/bin/pm/Excel-Writer-XLSX-0.95/examples/tab2xlsx.pl $od/analysis/cuffdiff/gene.fpkm.diff.anno $od/analysis/cuffdiff/gene.fpkm.diff.anno.xlsx > $od/analysis/cuffdiff/gene.fpkm.diff.anno.xlsx.out 2> $od/analysis/cuffdiff/gene.fpkm.diff.anno.xlsx.err\n\n";

print MAKEFLOW "CATEGORY=genetotaltable\n";
print MAKEFLOW "$od/results/total.table.for.DEG/gene.fpkm.diff.anno.xlsx : $od/analysis/cuffdiff/gene.fpkm.diff.anno.xlsx\n";
print MAKEFLOW "\tcp $od/analysis/cuffdiff/gene.fpkm.diff.anno.xlsx $od/results/total.table.for.DEG/gene.fpkm.diff.anno.xlsx > $od/analysis/cuffdiff/geneanno.out 2> $od/analysis/cuffdiff/geneanno.err\n\n";	

sub ABSOLUTE_DIR
{ #$pavfile=&ABSOLUTE_DIR($pavfile);
	my $cur_dir=`pwd`;chomp($cur_dir);
	my ($in)=@_;
	my $return="";
	
	if(-f $in)
	{
		my $od=dirname($in);
		my $file=basename($in);
		chdir $od;$od=`pwd`;chomp $od;
		$return="$od/$file";
	}
	elsif(-d $in)
	{
		chdir $in;$return=`pwd`;chomp $return;
	}
	else
	{
		warn "Warning just for file and od in [sub ABSOLUTE_DIR]\n";
		exit;
	}
	
	chdir $cur_dir;
	return $return;
}


