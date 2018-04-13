#! perl -w
#this program is for the bulid of rice gtf from RAP build5 gff;

if(!$ARGV[0]){
	my $usage=<<DO;
	
	Usage: perl $0 genes.gff3 output.gtf
	
DO
	print $usage;exit
}

my $gff=$ARGV[0];
my $gtf=$ARGV[1];
my $k=0;
my $j=1;
open ANNO,">$gff.annotation";
open OUT1,">$gtf.deleGN.gtf";
print ANNO "#Gene_id\tEntrez_id\tChr\tStart\tEnd\tSymbol\tGenetype\tDescription\n";
open IN,$gff;
my %gene;
my %trans;
my %exon;
my %cds;
my %num;
my(%anno,%genecheck,%transcheck,%annoinf);
my @chr_pre;
my %ntrans;
my(%tRNA,%rRNA);
my($tRNA,$rRNA)=(1,1);
while(<IN>){
	chomp;
	next if /^\s+/;
	if(/^#/){
		next;
	};
	my @c=split /\t/;
	for my $ele(@c){
		$ele=~s/^\s+|\s+$//g;
	};
	if($c[2]=~/^gene/){
		push @chr_pre,$c[0];
		my @d=split /;/,$c[8];
		my ($entrez,$genetype,$geneid,$genesymbol,$gene);
		for my $ele(@d){
			if($ele=~/ID=(\S+)/){
				$geneid=$+;
			}
			elsif($ele=~/GeneID:(\d+)/){
				$entrez=$+;
			}
			elsif($ele=~/gene=(\S+)/){
				$genesymbol=$+;
			}
			elsif($ele=~/gene_biotype=(\S+)/){
				$genetype=$+;
			}
			elsif($ele=~/locus_tag=(\w+)/){
				$gene=$+;
			}
		}
		if(!$geneid){die("NO gene id for $_\n");}
		if(!$entrez){
			print "there some lines which don't have entrez id\n";
			exit;
		}
		if(!$genesymbol and !$gene){die("no gene info $_\n")};
		if(!$gene){$gene=$genesymbol}
		if(!$gene){die("no gene info $_\n")}
		$gene=~s/-/_/g;
		if(!$genesymbol){$genesymbol="-"}
		if(!$genetype){$genetype="-"}
		$genesymbol=~s/\s+/\_/g;
		if($num{$geneid}){ 
			$num{$geneid}++;
			print STDERR "$_\n";
			next;
		}
		push @{$anno{$geneid}},($gene,$entrez,$c[0],$c[3],$c[4],$genesymbol,$genetype);
		@c[3,4]=@c[4,3] if($c[3]>$c[4]);
		$gene{$c[0]}{$c[3]}{$geneid}=join "\t",($c[0],$c[1],$c[2],$c[3],$c[4],$c[5],$c[6],$c[7],$gene,$genetype,$genesymbol);
		$genecheck{$geneid}=$gene;
		$num{$geneid}++;
		next;
	}
	if($c[2]=~/RNA|transcript|gene_segment/){
		my ($geneid,$transid,$entrez,$anno,$genesymbol,$transgeneid,$gene);
		my @d=split /;/,$c[8];
		for my $ele(@d){
			if($ele=~/ID=(\S+)/){
				$transid=$+;
			}
			elsif($ele=~/Parent=(\S+)/){
				$geneid=$+
			}
			elsif($ele=~/GeneID:([^,]+)/){
				$entrez=$+;
			}
			elsif($ele=~/gene=(\S+)/){
				$genesymbol=$+;
			}
			elsif($ele=~/product=(.+)$/){
				$anno=$+;
			}
			elsif($ele=~/transcript_id=(\S+)/){
				$transgeneid=$+;
			}
			elsif($ele=~/locus_tag=(\w+)/){
				$gene=$+;
			}
		}
		if(!$geneid){
			$c[8]=~/gbkey=(\w+)/;
			my $type=$+;
			if($type eq "tRNA"){
				$geneid="tRNA_".$tRNA++;
			}
			elsif($type eq "rRNA"){
				$geneid="rRNA_".$rRNA++;
			}
			$genecheck{$geneid}=$geneid;
			$transcheck{$transid}=$geneid;
			$num{$geneid}++;
			push @{$anno{$geneid}},($geneid,$geneid,$c[0],$c[3],$c[4],$anno,$type);
			$c[2]="transcript";
			$gene{$c[0]}{$c[3]}{$geneid}=join "\t",($c[0],$c[1],"gene",$c[3],$c[4],$c[5],$c[6],$c[7],$geneid,$type,$anno);
			$trans{$c[0]}{$geneid}{$transid}=join "\t",($c[0],$c[1],$c[2],$c[3],$c[4],$c[5],$c[6],$c[7],$geneid,$geneid."_T",$anno,$anno);
			$annoinf{$geneid}=$anno;
			next;	
		}
		if(!$annoinf{$geneid} or $annoinf{$geneid} !~/^\w+/){
			$annoinf{$geneid}=$anno;
		}
		if(!$gene){
			if($genecheck{$geneid}){$gene=$genecheck{$geneid};$transcheck{$transid}=$genecheck{$geneid}}
			
		}
		
		if(!$gene){$gene=$genesymbol}
		if(!$gene){die("no gene info RNA $_\n")}
		$gene=~s/-/_/g;
		if(!$genesymbol){$genesymbol=$gene}
		$genesymbol=~s/\s+/\_/g;
		if(!$transgeneid){$transgeneid=$gene."_T";}
		if(!$anno){
			$anno="-";
		}
		@c[3,4]=@c[4,3] if($c[3]>$c[4]);
		if($c[2]=~/gene_segment/){$c[2]="RNA"}
		$trans{$c[0]}{$geneid}{$transid}=join "\t",($c[0],$c[1],$c[2],$c[3],$c[4],$c[5],$c[6],$c[7],$gene,$transgeneid,$genesymbol,$anno);
		next;
	}
	if($c[2]=~/exon/){
		my ($exonid,$transid,$entrez,$anno,$genesymbol,$transgeneid,$gene);
		my @d=split /;/,$c[8];
		for my $ele(@d){
			if($ele=~/ID=(\S+)/){
				$exonid=$+;
			}
			elsif($ele=~/Parent=(\w+)/){
				$transid=$+;
			}
			elsif($ele=~/GeneID:([^,]+)/){
				$entrez=$+;
			}
			elsif($ele=~/gene=(\S+)/){
				$genesymbol=$+;
			}
			elsif($ele=~/product=(.+)$/){
				$anno=$+;
			}
			elsif($ele=~/transcript_id=(\S+)/){
				$transgeneid=$+;
			}
			elsif($ele=~/locus_tag=(\w+)/){
				$gene=$+;
			}
		}
		if(!$transid){
			die("no Parent info $_\n");
		}
		
		if(!$annoinf{$transid} or $annoinf{$transid} !~/^\w+/){
			$annoinf{$transid}=$anno;
		}
		if(!$gene){
			if($transcheck{$transid}){$gene=$transcheck{$transid}}
			elsif($genecheck{$transid}){$gene=$genecheck{$transid}}
			
		}
		if(!$gene and $genesymbol){$genesymbol=~s/\s+/\_/g; $gene=$genesymbol}
		if(!$gene){die("no gene info EXON $_\n")};
		$gene=~s/-/_/g;
		if(!$genesymbol){$genesymbol=$gene}
		if(!$transgeneid){$transgeneid=$gene."_T";}
		if(!$anno and $annoinf{$transid}){$anno=$annoinf{$transid}}
		@c[3,4]=@c[4,3] if($c[3]>$c[4]);
		push @{$exon{$c[0]}{$transid}},[$c[0],$c[1],$c[2],$c[3],$c[4],$c[5],$c[6],$c[7],$gene,$transgeneid,$genesymbol,$anno];
		next;
	}
	if($c[2]=~/CDS/){
		my ($cdsid,$transid,$entrez,$anno,$genesymbol,$proteinid,$gene);
		my @d=split /;/,$c[8];
		for my $ele(@d){
			if($ele=~/ID=(\S+)/){
				$cdsid=$+;
			}
			elsif($ele=~/Parent=(\S+)/){
				$transid=$+;
			}
			elsif($ele=~/GeneID:([^,]+)/){
				$entrez=$+;
			}
			elsif($ele=~/gene=(\S+)/){
				$genesymbol=$+;
			}
			elsif($ele=~/product=(.+)$/){
				$anno=$+;
			}
			elsif($ele=~/protein_id=(\S+)/){
				$proteinid=$+;
			}
			elsif($ele=~/locus_tag=(\w+)/){
				$gene=$+;
			}
		}
		if(!$annoinf{$transid} or $annoinf{$transid} !~/^\w+/){
			$annoinf{$transid}=$anno;
		}
		if(!$gene){
			if($transcheck{$transid}){$gene=$transcheck{$transid}}
			elsif($genecheck{$transid}){$gene=$genecheck{$transid}}
			
		}
		if(!$gene and $genesymbol){$genesymbol=~s/\s+/\_/g; $gene=$genesymbol}
		if(!$gene){die("no gene info CDS $_\n")}
		$gene=~s/-/_/g;
		if(!$genesymbol){$genesymbol=$gene}
		if(!$transgeneid){$transgeneid=$gene."_T";}
		if(!$proteinid){$proteinid=$gene."\_P"}
		if(!$anno and $annoinf{$transid}){$anno=$annoinf{$transid}}
		elsif(!$annoinf{$transid} and $anno){
			$annoinf{$transid}=$anno;
		}
		@c[3,4]=@c[4,3] if($c[3]>$c[4]);
		
		push @{$cds{$c[0]}{$transid}},[$c[0],$c[1],$c[2],$c[3],$c[4],$c[5],$c[6],$c[7],$gene,$proteinid,$genesymbol,$anno];
	}
	else{next;};
}
close IN;

my %hash;
@chr_pre=grep {++$hash{$_}<2} @chr_pre;
my $chr_index=modi_chr(\@chr_pre);
my %generep;
my %transrep;
open GTF,">$gtf";
my %check;
for my $chr(@$chr_index){
	for my $start(sort {$a <=> $b} keys $gene{$chr}){
		for my $gene(keys $gene{$chr}{$start}){
			my @a=split "\t",$gene{$chr}{$start}{$gene};
			my $genenew=$a[8];
			if(!$generep{$a[8]}){
				$generep{$a[8]}=1;
				$check{$gene}=$genenew;
			}else{
				$genenew.="\_".$generep{$a[8]};
				$check{$gene}=$genenew;
				$generep{$a[8]}++;
			}
			print GTF "$a[0]\t$a[1]\t$a[2]\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\tgene_id \"$genenew\"\; gene_biotype \"$a[9]\"\; gene_name \"$a[10]\";\n";
			print OUT1 "$a[0]\t$a[1]\t$a[2]\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\tgene_id \"$genenew\"\; gene_biotype \"$a[9]\"\;\n";
			my $sourcetype="transcript";
			
			my @anno=@{$anno{$gene}};
			$anno[0]=$genenew;
			my $anno=join "\t",@anno;
			if(!$annoinf{$gene}){$annoinf{$gene}="-";}
			$annoinf{$gene}=~s/\%3B/;/g;
			$annoinf{$gene}=~s/\%20/ /g;
			$annoinf{$gene}=~s/\%28/\(/g;
			$annoinf{$gene}=~s/\%29/\)/g;
			$annoinf{$gene}=~s/\%2F/\//g;
			$annoinf{$gene}=~s/\%2C/,/g;
			print ANNO "$anno\t$annoinf{$gene}\n";
			if(!$trans{$chr}{$gene}){
				my $exonnum=0;
				if($exon{$chr}{$gene} and !$cds{$chr}{$gene}){
					my @exoninf=@{$exon{$chr}{$gene}};			
					my %hash1;
					@exoninf=grep {++$hash1{$_}<2} @exoninf;
					if($a[6] eq "-"){
						@exoninf=reverse sort {$$a[3] <=> $$b[3]} @exoninf;
					}
					else{
						@exoninf=sort {$$a[3] <=> $$b[3]} @exoninf;
					}
					print GTF "$a[0]\t$a[1]\t$sourcetype\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
					print GTF "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; gene_name \"$a[10]\"; gene_anno \"$annoinf{$gene}\";\n";
					
					print OUT1 "$a[0]\t$a[1]\t$sourcetype\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
					print OUT1 "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; gene_anno \"$annoinf{$gene}\";\n";
					
					for my $exonid(@exoninf){
						$exonnum++;
						my @c=@$exonid;
						if(!$c[11] or $c[11] eq ""){$c[11]=$annoinf{$gene}}
						$c[11]=~s/\%3B/;/g;
						$c[11]=~s/\%20/ /g;
						$c[11]=~s/\%28/\(/g;
						$c[11]=~s/\%29/\)/g;
						$c[11]=~s/\%2F/\//g;
						$c[11]=~s/\%2C/,/g;
						print GTF "$c[0]\t$c[1]\t$c[2]\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
						print GTF "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; gene_name \"$a[10]\"; gene_anno \"$c[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
						
						print OUT1 "$c[0]\t$c[1]\t$c[2]\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
						print OUT1 "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; gene_anno \"$c[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
					}
					next;
				}
				if($cds{$chr}{$gene} and !$exon{$chr}{$gene}){
					my @cdsinf=@{$cds{$chr}{$gene}};
					my %hash1;
					@cdsinf=grep {++$hash1{$_}<2} @cdsinf;
					if($a[6] eq "-"){
						@cdsinf=reverse sort {$$a[3] <=> $$b[3]} @cdsinf;
					}
					else{
						@cdsinf=sort {$$a[3] <=> $$b[3]} @cdsinf;
					}
					print GTF "$a[0]\t$a[1]\ttranscript\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
					print GTF "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; gene_name \"$a[10]\"; gene_anno \"$annoinf{$gene}\";\n";
					
					print OUT1 "$a[0]\t$a[1]\ttranscript\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
					print OUT1 "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; gene_anno \"$annoinf{$gene}\";\n";
					for my $cdsinfo(@cdsinf){
						$exonnum++;
						my @d=@$cdsinfo;
						$d[11]=~s/\%3B/;/g;
						$d[11]=~s/\%20/ /g;
						$d[11]=~s/\%28/\(/g;
						$d[11]=~s/\%29/\)/g;
						$d[11]=~s/\%2F/\//g;
						$d[11]=~s/\%2C/,/g;
						print GTF "$d[0]\t$d[1]\texon\t$d[3]\t$d[4]\t$d[5]\t$d[6]\t$d[7]\t";
						print GTF "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"; gene_name \"$a[10]\"; gene_anno \"$d[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
						print GTF "$d[0]\t$d[1]\t$d[2]\t$d[3]\t$d[4]\t$d[5]\t$d[6]\t$d[7]\t";
						print GTF "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; protein_id \"$d[9]\"; gene_name \"$a[10]\"; gene_anno \"$d[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
						
						print OUT1 "$d[0]\t$d[1]\texon\t$d[3]\t$d[4]\t$d[5]\t$d[6]\t$d[7]\t";
						print OUT1 "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"; gene_anno \"$d[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
						print OUT1 "$d[0]\t$d[1]\t$d[2]\t$d[3]\t$d[4]\t$d[5]\t$d[6]\t$d[7]\t";
						print OUT1 "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; protein_id \"$d[9]\"; gene_anno \"$d[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
					}
				}
				elsif($cds{$chr}{$gene} and $exon{$chr}{$gene}){
					my @exon=@{$exon{$chr}{$gene}};
					my @cds=@{$cds{$chr}{$gene}};
					my (%hash1,%hash2);
					@exon=grep {++$hash1{$_}<2} @exon;
					@cds=grep {++$hash2{$_}<2} @cds;
					if(@exon >= @cds){
						if($a[6] eq "-"){
							@exon=reverse sort {$$a[3] <=> $$b[3]} @exon;
						}
						else{
							@exon=sort {$$a[3] <=> $$b[3]} @exon;
						}
						print GTF "$a[0]\t$a[1]\ttranscript\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
						print GTF "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; gene_name \"$a[10]\"; gene_anno \"$annoinf{$gene}\";\n";
						
						print OUT1 "$a[0]\t$a[1]\ttranscript\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
						print OUT1 "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; gene_anno \"$annoinf{$gene}\";\n";
						my $proteinid="-";
						for my $exonid(@exon){
							$exonnum++;
							my @c=@$exonid;
							if(!$c[11] or $c[11] eq ""){$c[11]=$annoinf{$gene}}
							$c[11]=~s/\%3B/;/g;
							$c[11]=~s/\%20/ /g;
							$c[11]=~s/\%28/\(/g;
							$c[11]=~s/\%29/\)/g;
							$c[11]=~s/\%2F/\//g;
							$c[11]=~s/\%2C/,/g;
							print GTF "$c[0]\t$c[1]\t$c[2]\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
							print GTF "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; gene_name \"$a[10]\"; gene_anno \"$c[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
							
							print OUT1 "$c[0]\t$c[1]\t$c[2]\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
							print OUT1 "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; gene_anno \"$c[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
							my $checkexon=0;
							
							for my $cdsinfo(@cds){
								my @d=@$cdsinfo;
								$d[11]=~s/\%3B/;/g;
								$d[11]=~s/\%20/ /g;
								$d[11]=~s/\%28/\(/g;
								$d[11]=~s/\%29/\)/g;
								$d[11]=~s/\%2F/\//g;
								$d[11]=~s/\%2C/,/g;
								if( $d[3] >= $c[3] and $d[4] <= $c[4]){
									print GTF "$d[0]\t$d[1]\t$d[2]\t$d[3]\t$d[4]\t$d[5]\t$d[6]\t$d[7]\t";
									print GTF "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; protein_id \"$d[9]\"; gene_name \"$a[10]\"; gene_anno \"$d[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
									
									print OUT1 "$d[0]\t$d[1]\t$d[2]\t$d[3]\t$d[4]\t$d[5]\t$d[6]\t$d[7]\t";
									print OUT1 "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; protein_id \"$d[9]\"; gene_anno \"$d[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
									$checkexon=1;$proteinid=$d[9];
								}
							}
						}
					}
					else{
						print GTF "$a[0]\t$a[1]\ttranscript\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
						print GTF "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; gene_name \"$a[10]\"; gene_anno \"$annoinf{$gene}\";\n";
						
						print OUT1 "$a[0]\t$a[1]\ttranscript\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
						print OUT1 "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; gene_anno \"$annoinf{$gene}\";\n";
						if($a[6] eq "-"){
							@cds=reverse sort {$$a[3] <=> $$b[3]} @cds;
						}
						else{
							@cds=sort {$$a[3] <=> $$b[3]} @cds;
						}
						for my $cdsid(@cds){
							$exonnum++;
							my @c=@$cdsid;
							if(!$c[11] or $c[11] eq ""){$c[11]=$annoinf{$gene}}
							$c[11]=~s/\%3B/;/g;
							$c[11]=~s/\%20/ /g;
							$c[11]=~s/\%28/\(/g;
							$c[11]=~s/\%29/\)/g;
							$c[11]=~s/\%2F/\//g;
							$c[11]=~s/\%2C/,/g;
							my $checkn=0;
							for my $exoninfo(@exon){
								my @d=@$exoninfo;
								if($d[3]<=$c[3] and $d[4]>=$c[4]){
									
									print GTF "$d[0]\t$d[1]\t$d[2]\t$d[3]\t$d[4]\t$d[5]\t$d[6]\t$d[7]\t";
									print GTF "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; gene_name \"$a[10]\"; gene_anno \"$c[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
									
									print GTF "$c[0]\t$c[1]\t$c[2]\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
									print GTF "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; protein_id \"$c[9]\"; gene_name \"$a[10]\"; gene_anno \"$c[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
									
									print OUT1 "$d[0]\t$d[1]\t$d[2]\t$d[3]\t$d[4]\t$d[5]\t$d[6]\t$d[7]\t";
									print OUT1 "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; gene_anno \"$c[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
									
									print OUT1 "$c[0]\t$c[1]\t$c[2]\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
									print OUT1 "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; protein_id \"$c[9]\"; gene_anno \"$c[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
									$checkn=1;
								}
							}
							if(!$checkn){
								print GTF "$c[0]\t$c[1]\texon\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
								print GTF "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; gene_name \"$a[10]\"; gene_anno \"$c[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
								print GTF "$c[0]\t$c[1]\t$c[2]\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
								print GTF "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; protein_id \"$c[9]\"; gene_name \"$a[10]\"; gene_anno \"$c[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
								
								print OUT1 "$c[0]\t$c[1]\texon\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
								print OUT1 "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; gene_anno \"$c[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
								print OUT1 "$c[0]\t$c[1]\t$c[2]\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
								print OUT1 "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; protein_id \"$c[9]\"; gene_anno \"$c[11]\"; exon_id \"$genenew\_T\_$exonnum\";\n";
							}
						}
					}
				}
				else{
					print GTF "$a[0]\t$a[1]\t$sourcetype\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
					print GTF "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; gene_name \"$a[10]\"; gene_anno \"$annoinf{$gene}\";\n";
					print GTF "$a[0]\t$a[1]\texon\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
					print GTF "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"1\"\; gene_name \"$a[10]\"; gene_anno \"$annoinf{$gene}\";\n";
					
					print OUT1 "$a[0]\t$a[1]\t$sourcetype\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
					print OUT1 "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; gene_anno \"$annoinf{$gene}\";\n";
					print OUT1 "$a[0]\t$a[1]\texon\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
					print OUT1 "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"1\"\; gene_anno \"$annoinf{$gene}\";\n";
					
					if($a[9] =~/protein_coding/){
						print GTF "$a[0]\t$a[1]\tCDS\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
						print GTF "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"1\"\; protein_id \"$genenew\_P\"\; gene_name \"$a[10]\"; gene_anno \"$annoinf{$gene}\";\n";
						
						print OUT1 "$a[0]\t$a[1]\tCDS\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
						print OUT1 "gene_id \"$genenew\"\; transcript_id \"$genenew\_T\"\; gene_biotype \"$a[9]\"\; exon_number \"1\"\; protein_id \"$genenew\_P\"\; gene_anno \"$annoinf{$gene}\";\n";
					
					}
				}
			}
			else{
				for my $trans(sort {$a cmp $b} keys $trans{$chr}{$gene}){
					my @b=split /\t/,$trans{$chr}{$gene}{$trans};
					$b[11]=~s/\%3B/;/g;
					$b[11]=~s/\%20/ /g;
					$b[11]=~s/\%28/\(/g;
					$b[11]=~s/\%29/\)/g;
					$b[11]=~s/\%2F/\//g;
					$b[11]=~s/\%2C/,/g;
					$b[1]="transcript";
					#20171214
					if(!$check{$gene}){die("some problems about $gene\n");} 
					if($transrep{$b[9]}){$b[9]=$check{$gene}."\_T";$transrep{$b[9]}++;}
					else{$transrep{$b[9]}++;}
					print GTF "$b[0]\t$b[1]\t$b[2]\t$b[3]\t$b[4]\t$b[5]\t$b[6]\t$b[7]\t";
					print GTF "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; gene_name \"$b[10]\"; gene_anno \"$b[11]\";\n";
					
					print OUT1 "$b[0]\t$b[1]\t$b[2]\t$b[3]\t$b[4]\t$b[5]\t$b[6]\t$b[7]\t";
					print OUT1 "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; gene_anno \"$b[11]\";\n";
					my $exonnum=0;
					if($exon{$chr}{$trans} and !$cds{$chr}{$trans}){
						my @exoninf=@{$exon{$chr}{$trans}};			
						my %hash1;
						@exoninf=grep {++$hash1{$_}<2} @exoninf;
						if($a[6] eq "-"){
							@exoninf=reverse sort {$$a[3] <=> $$b[3]} @exoninf;
						}
						else{
							@exoninf=sort {$$a[3] <=> $$b[3]} @exoninf;
						}
						for my $exonid(@exoninf){
							$exonnum++;
							my @c=@$exonid;
							if(!$c[11] or $c[11] eq ""){$c[11]=$annoinf{$gene}}
							$c[11]=~s/\%3B/;/g;
							$c[11]=~s/\%20/ /g;
							$c[11]=~s/\%28/\(/g;
							$c[11]=~s/\%29/\)/g;
							$c[11]=~s/\%2F/\//g;
							$c[11]=~s/\%2C/,/g;
							print GTF "$c[0]\t$c[1]\t$c[2]\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
							print GTF "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; gene_name \"$a[10]\"; gene_anno \"$c[11]\"; exon_id \"$b[9]\_$exonnum\";\n";
							
							print OUT1 "$c[0]\t$c[1]\t$c[2]\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
							print OUT1 "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; gene_anno \"$c[11]\"; exon_id \"$b[9]\_$exonnum\";\n";
						}
					}
					elsif($cds{$chr}{$trans} and !$exon{$chr}{$trans}){
						my @cdsinf=@{$cds{$chr}{$trans}};
						my %hash1;
						@cdsinf=grep {++$hash1{$_}<2} @cdsinf;
						if($a[6] eq "-"){
							@cdsinf=reverse sort {$$a[3] <=> $$b[3]} @cdsinf;
						}
						else{
							@cdsinf=sort {$$a[3] <=> $$b[3]} @cdsinf;
						}
						for my $cdsinfo(@cdsinf){
							$exonnum++;
							my @d=@$cdsinfo;
							$d[11]=~s/\%3B/;/g;
							$d[11]=~s/\%20/ /g;
							$d[11]=~s/\%28/\(/g;
							$d[11]=~s/\%29/\)/g;
							$d[11]=~s/\%2F/\//g;
							$d[11]=~s/\%2C/,/g;
							print GTF "$d[0]\t$d[1]\texon\t$d[3]\t$d[4]\t$d[5]\t$d[6]\t$d[7]\t";
							print GTF "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"; gene_name \"$a[10]\"; gene_anno \"$d[11]\"; exon_id \"$b[9]\_$exonnum\";\n";
							print GTF "$d[0]\t$d[1]\t$d[2]\t$d[3]\t$d[4]\t$d[5]\t$d[6]\t$d[7]\t";
							print GTF "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; protein_id \"$d[9]\"; gene_name \"$a[10]\"; gene_anno \"$d[11]\"; exon_id \"$b[9]\_$exonnum\";\n";
							
							print OUT1 "$d[0]\t$d[1]\texon\t$d[3]\t$d[4]\t$d[5]\t$d[6]\t$d[7]\t";
							print OUT1 "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"; gene_anno \"$d[11]\"; exon_id \"$b[9]\_$exonnum\";\n";
							print OUT1 "$d[0]\t$d[1]\t$d[2]\t$d[3]\t$d[4]\t$d[5]\t$d[6]\t$d[7]\t";
							print OUT1 "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; protein_id \"$d[9]\"; gene_anno \"$d[11]\"; exon_id \"$b[9]\_$exonnum\";\n";
						}
					}
					elsif($cds{$chr}{$trans} and $exon{$chr}{$trans}){
						my @exon=@{$exon{$chr}{$trans}};
						my @cds=@{$cds{$chr}{$trans}};
						my (%hash1,%hash2);
						@exon=grep {++$hash1{$_}<2} @exon;
						@cds=grep {++$hash2{$_}<2} @cds;
						if(@exon >= @cds){
							if($a[6] eq "-"){
								@exon=reverse sort {$$a[3] <=> $$b[3]} @exon;
							}
							else{
								@exon=sort {$$a[3] <=> $$b[3]} @exon;
							}
							my $proteinid="-";
							for my $exonid(@exon){
								$exonnum++;
								my @c=@$exonid;
								if(!$c[11] or $c[11] eq ""){$c[11]=$annoinf{$gene}}
								$c[11]=~s/\%3B/;/g;
								$c[11]=~s/\%20/ /g;
								$c[11]=~s/\%28/\(/g;
								$c[11]=~s/\%29/\)/g;
								$c[11]=~s/\%2F/\//g;
								$c[11]=~s/\%2C/,/g;
								print GTF "$c[0]\t$c[1]\t$c[2]\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
								print GTF "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; gene_name \"$a[10]\"; gene_anno \"$c[11]\"; exon_id \"$b[9]\_$exonnum\";\n";
								
								print OUT1 "$c[0]\t$c[1]\t$c[2]\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
								print OUT1 "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; gene_anno \"$c[11]\"; exon_id \"$b[9]\_$exonnum\";\n";
								
								my $checkexon=0;
							
								for my $cdsinfo(@cds){
									my @d=@$cdsinfo;
									$d[11]=~s/\%3B/;/g;
									$d[11]=~s/\%20/ /g;
									$d[11]=~s/\%28/\(/g;
									$d[11]=~s/\%29/\)/g;
									$d[11]=~s/\%2F/\//g;
									$d[11]=~s/\%2C/,/g;
									if( $d[3] >= $c[3] and $d[4] <= $c[4]){
										print GTF "$d[0]\t$d[1]\t$d[2]\t$d[3]\t$d[4]\t$d[5]\t$d[6]\t$d[7]\t";
										print GTF "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; protein_id \"$d[9]\"; gene_name \"$a[10]\"; gene_anno \"$d[11]\";exon_id \"$b[9]\_$exonnum\";\n";
										
										print OUT1 "$d[0]\t$d[1]\t$d[2]\t$d[3]\t$d[4]\t$d[5]\t$d[6]\t$d[7]\t";
										print OUT1 "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; protein_id \"$d[9]\"; gene_anno \"$d[11]\";exon_id \"$b[9]\_$exonnum\";\n";
										$checkexon=1;$proteinid=$d[9];
									}
								}
							}
						}
						else{
							if($a[6] eq "-"){
							@cds=reverse sort {$$a[3] <=> $$b[3]} @cds;
							}
							else{
								@cds=sort {$$a[3] <=> $$b[3]} @cds;
							}
							for my $cdsid(@cds){
								$exonnum++;
								my @c=@$cdsid;
								if(!$c[11] or $c[11] eq ""){$c[11]=$annoinf{$gene}}
								$c[11]=~s/\%3B/;/g;
								$c[11]=~s/\%20/ /g;
								$c[11]=~s/\%28/\(/g;
								$c[11]=~s/\%29/\)/g;
								$c[11]=~s/\%2F/\//g;
								$c[11]=~s/\%2C/,/g;
								my $checkn=0;
								for my $exoninfo(@exon){
									my @d=@$exoninfo;
									if($d[3]<=$c[3] and $d[4]>=$c[4]){
									
										print GTF "$d[0]\t$d[1]\t$d[2]\t$d[3]\t$d[4]\t$d[5]\t$d[6]\t$d[7]\t";
										print GTF "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; gene_name \"$a[10]\"; gene_anno \"$c[11]\"; exon_id \"$b[9]\_$exonnum\";\n";
									
										print GTF "$c[0]\t$c[1]\t$c[2]\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
										print GTF "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; protein_id \"$c[9]\"; gene_name \"$a[10]\"; gene_anno \"$c[11]\"; exon_id \"$b[9]\_$exonnum\";\n";
										
										print OUT1 "$d[0]\t$d[1]\t$d[2]\t$d[3]\t$d[4]\t$d[5]\t$d[6]\t$d[7]\t";
										print OUT1 "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; gene_anno \"$c[11]\"; exon_id \"$b[9]\_$exonnum\";\n";
									
										print OUT1 "$c[0]\t$c[1]\t$c[2]\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
										print OUT1 "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; protein_id \"$c[9]\"; gene_anno \"$c[11]\"; exon_id \"$b[9]\_$exonnum\";\n";
										$checkn=1;
									}
								}
								if(!$checkn){
									print GTF "$c[0]\t$c[1]\texon\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
									print GTF "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; gene_name \"$a[10]\"; gene_anno \"$c[11]\"; exon_id \"$b[9]\_$exonnum\";\n";
									print GTF "$c[0]\t$c[1]\t$c[2]\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
									print GTF "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; protein_id \"$c[9]\"; gene_name \"$a[10]\"; gene_anno \"$c[11]\"; exon_id \"$b[9]\_$exonnum\";\n";
									
									print OUT1 "$c[0]\t$c[1]\texon\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
									print OUT1 "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; gene_anno \"$c[11]\"; exon_id \"$b[9]\_$exonnum\";\n";
									print OUT1 "$c[0]\t$c[1]\t$c[2]\t$c[3]\t$c[4]\t$c[5]\t$c[6]\t$c[7]\t";
									print OUT1 "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"$exonnum\"\; protein_id \"$c[9]\"; gene_anno \"$c[11]\"; exon_id \"$b[9]\_$exonnum\";\n";
								}
							}
						}
					}
					else{
						#print "no exon and cds info for gene $genenew\n";
						print GTF "$a[0]\t$a[1]\texon\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
						print GTF "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"1\"\; gene_name \"$a[10]\"; gene_anno \"$annoinf{$gene}\";\n";
						
						print OUT1 "$a[0]\t$a[1]\texon\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
						print OUT1 "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"1\"\; gene_anno \"$annoinf{$gene}\";\n";
						if($a[9] =~/protein_coding/){
							print GTF "$a[0]\t$a[1]\tCDS\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
							print GTF "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"1\"\; protein_id \"$b[9]\_P\"\; gene_name \"$a[10]\"; gene_anno \"$annoinf{$gene}\";\n";
							
							print OUT1 "$a[0]\t$a[1]\tCDS\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
							print OUT1 "gene_id \"$genenew\"\; transcript_id \"$b[9]\"\; gene_biotype \"$a[9]\"\; exon_number \"1\"\; protein_id \"$b[9]\_P\"\; gene_anno \"$annoinf{$gene}\";\n";
					
						}
					}
				}
			}
		}
	}
}
close GTF;

sub modi_chr{
	my ($index)=@_;
	my @chr=@$index;
	my (@tmp,@integer,@string);
	for my $ele (@chr){
		if($ele=~/^chr(\d+)$/ or $ele=~/^(\d+)$/){
			push @integer,$+;
		}
		else{
			push @string,$ele;
		}
	}
	map { 
		if($_ ~~ @chr){push @tmp,$_;}
		else{push @tmp,"chr".$_};
	} sort {$a <=> $b} @integer;
	map {push @tmp,$_;} sort {$a cmp $b} @string;
	
	return(\@tmp);
}
