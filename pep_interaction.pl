#!/lustre/software/target/plenv/shims/perl
#####程序所需加载的包################################################################################################
use strict;
use warnings;
use FileHandle;
use Getopt::Long;
use Data::Dumper;
use File::Basename qw(basename dirname);
use Cwd;
use FindBin qw($Bin $Script);

chomp $Bin;
#####时间和版本#######################################################################################################
my $BEGIN_TIME=time();
my $version="1.1";
########################################
####使用程序需要输入的参数############################################################################################
my ($gene_pro,$interactions,$od,$tax);
GetOptions(		
	"help|?" =>\&USAGE,
	"gp:s"=>\$gene_pro, 
	"inter:s"=>\$interactions, 
	"od:s"=>\$od,
	"tax:s"=>\$tax,
) or &USAGE;
&USAGE unless ($gene_pro and $interactions and $od);
&MKDIR($od);
$od=ABSOLUTE_DIR($od);
$gene_pro=ABSOLUTE_DIR($gene_pro);
$interactions=ABSOLUTE_DIR($interactions);

open (GP,$gene_pro) or die $!;
my @genes;
my %pro_gene;
while (<GP>) {
	chomp;
	my ($gene,$pro)=(split /\t/,$_)[0,1];
	push @genes,$gene;
	if ($gene=~/None/) {next;	}
	my @pro=split /,/,$pro;
	foreach my $pro_temp (@pro) {
		push @{$pro_gene{$pro_temp}},$gene;
	}
}
close GP;

open (INTER,$interactions) or die $!;
open OUT,">$od/pro_pro_interaction.db";
my $head=<INTER>;
chomp $head;
print OUT"gene1\tgene2\t$head\n";
while (<INTER>) {
	chomp;
	my ($p1,$p2,@info)=split /\s+/,$_;
$p1=~/$tax\.(.+)/;
	my $id_p1=$+;
	$p2=~/$tax\.(.+)/;
	my $id_p2=$+;
	if (($pro_gene{$id_p1}[0]) && ($pro_gene{$id_p2}[0])) {
		my %count1;
		my %count2;
		@{$pro_gene{$id_p1}} = grep { ++$count1{ $_ } < 2;} @{$pro_gene{$id_p1}};
		@{$pro_gene{$id_p2}} = grep { ++$count2{ $_ } < 2;} @{$pro_gene{$id_p2}};
#		my $gene1=join ",",@{$pro_gene{$id_p1}};
#		my $gene2=join ",",@{$pro_gene{$id_p2}};
		foreach my $gene1(@{$pro_gene{$id_p1}}){
			foreach my $gene2(@{$pro_gene{$id_p2}}){
				print OUT"$gene1\t$gene2\t$_\n";
			}
		}
#		print OUT"$gene1\t$gene2\t$_\n";
	}
}
close OUT;
close INTER;

##################################################################################
sub MKDIR
{ # &MKDIR($out_dir);
	my ($dir)=@_;
	rmdir($dir) if(-d $dir);
	mkdir($dir) if(!-d $dir);
}
#####输入说明子程序####################################################################################################
sub USAGE
{
my $usage=<<"USAGE";
Program: combine fpkm deg
Version: $version
Contact: lv ran <lvran18931993760\@163.com>
Description:

Usage:

	"help|?" =>\&USAGE,
	"gp:s"=>\$gene_pro, 
	"inter:s"=>\$interactions, 
	"tax:s"=>\$tax,
	"od:s"=>\$od,
	
#############################################
USAGE
	print $usage;
	exit;
}

#####获取文件绝对路径####################################################################################################
sub ABSOLUTE_DIR
{ #$pavfile=&ABSOLUTE_DIR($pavfile);
	my $cur_dir=`pwd`;chomp($cur_dir);
	my ($in)=@_;
	my $return="";
	
	if(-f $in)
	{
		my $dir=dirname($in);
		my $file=basename($in);
		chdir $dir;$dir=`pwd`;chomp $dir;
		$return="$dir/$file";
	}
	elsif(-d $in)
	{
		chdir $in;$return=`pwd`;chomp $return;
	}
	else
	{
		warn "Warning just for file and dir in [sub ABSOLUTE_DIR]\n";
		exit;
	}
	
	chdir $cur_dir;
	return $return;
}
