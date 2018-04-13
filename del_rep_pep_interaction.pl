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
use Math::Round;

chomp $Bin;
#####时间和版本#######################################################################################################
my $BEGIN_TIME=time();
my $version="1.1";
########################################
####使用程序需要输入的参数############################################################################################
my ($pro_pro,$od);
GetOptions(		
	"help|?" =>\&USAGE,
	"pp:s"=>\$pro_pro, 
	"od:s"=>\$od,
) or &USAGE;
&USAGE unless ($pro_pro and $od);
&MKDIR($od);
$od=ABSOLUTE_DIR($od);
$pro_pro=ABSOLUTE_DIR($pro_pro);

open (PP,$pro_pro) or die $!;
<PP>;
my $head="gene1\tgene2\tcombine_score";
my %propro;
while (<PP>) {
	chomp;
	my ($gene1,$gene2,$score)=(split /\t/,$_)[0,1,-1];
	if ($gene1 eq $gene2) {next;}
	my @gene=($gene1,$gene2);
	@gene=sort @gene;
	my $gene=join "\t",@gene;
	push @{$propro{$gene}},$score;


}
close PP;


open OUT,">$od/pro_pro_interaction.norep.db";
print OUT"$head\n";
foreach my $gene (sort keys %propro) {
	my $sum=0;my $num=@{$propro{$gene}};
	for my $score(@{$propro{$gene}}){
		$sum+=$score;
	}
	my $ave=round($sum/$num);
	if($num>1){
		print "$gene\t$ave\t$num\n";
	}
	
	print OUT "$gene\t$ave\n";
}
close OUT;


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
	"pp:s"=>\$pro_pro, 
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
