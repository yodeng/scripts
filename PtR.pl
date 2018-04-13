#!/usr/bin/env perl

use strict;
use warnings;
use Carp;
use Getopt::Long qw(:config no_ignore_case bundling pass_through);
use FindBin;
use File::Basename;

my $min_rowSums = 10;
my $min_colSums = 10;

my $usage = <<__EOUSAGE__;

#################################################################################### 
#
#######################
# Inputs and Outputs: #
#######################
#
#  --matrix <string>        matrix.RAW.normalized.FPKM
#
#  Optional:
#
#  Sample groupings:
#
#  --samples <string>      tab-delimited text file indicating biological replicate relationships.
#                                   ex.
#                                        cond_A    cond_A_rep1
#                                        cond_A    cond_A_rep2
#                                        cond_B    cond_B_rep1
#                                        cond_B    cond_B_rep2
#
#  --gene_factors <string>   tab-delimited file containing gene-to-factor relationships.
#                               ex.
#                                    liver_enriched <tab> gene1
#                                    heart_enriched <tab> gene2
#                                    ...
#                            (use of this data in plotting is noted for corresponding plotting options)
#
#
#  --output <string>        prefix for output file (default: "\${matrix_file}.heatmap")
#
#  --save                   save R session (as .RData file)
#
#####################
#  Plotting Actions #
#####################
#
#  --compare_replicates        provide scatter, MA, QQ, and correlation plots to compare replicates.
#
#   
#
#  --barplot_sum_counts        generate a barplot that sums frag counts per replicate across all samples.
#
#  --boxplot_log2_dist <float>        generate a boxplot showing the log2 dist of counts where counts >= min fpkm
#
#  --sample_cor_matrix         generate a sample correlation matrix plot
#    --sample_cor_scale_limits <string>    ex. "-0.2,0.6"
#    --sample_cor_sum_gene_factor_expr <factor=string>    instead of plotting the correlation value, plot the sum of expr according to gene factor
#                                                         requires --gene_factors 
#
#  --sample_cor_subset_matrix <string>  plot the sample correlation matrix, but create a disjoint set for rows,cols.
#                                       The subset of the samples to provide as the columns is provided as parameter.
#
#  --gene_cor_matrix           generate a gene-level correlation matrix plot
#
#  --indiv_gene_cor <string>   generate a correlation matrix and heatmaps for '--top_cor_gene_count' to specified genes (comma-delimited list)
#      --top_cor_gene_count <int>   (requires '--indiv_gene_cor with gene identifier specified')
#      --min_gene_cor_val <float>   (requires '--indiv_gene_cor with gene identifier specified')
#
#  --heatmap                   genes vs. samples heatmap plot
#      --heatmap_scale_limits "<int,int>"  cap scale intensity to low,high  (ie.  "-5,5")
#      --heatmap_colorscheme <string>  default is greenred
#      --lexical_column_ordering        order samples by column name lexical order.
#      --order_by_gene_factor           order the genes by their factor (given --gene_factors)
#
#  --gene_heatmaps <string>    generate heatmaps for just one or more specified genes
#                              Requires a comma-delimited list of gene identifiers.
#                              Plots one heatmap containing all specified genes, then separate heatmaps for each gene.
#                                 if --gene_factors set, will include factor annotations as color panel.
#                                 else if --prin_comp set, will include include principal component color panel.
#
#  --prin_comp <int>           generate principal components, include <int> top components in heatmap  
#      --add_prin_comp_heatmaps <int>  draw heatmaps for the top <int> features at each end of the prin. comp. axis.
#                                      (requires '--prin_comp') 
#      --add_top_loadings_pc_heatmap <int>  draw a heatmap containing the <int> top feature loadings across all PCs.
#
#  --mean_vs_sd               expression variability plot. (highlight specific genes by category via --gene_factors )
#
#  --var_vs_count_hist <vartype=string>        create histogram of counts of samples having feature expressed within a given expression bin.
#                                              vartype can be any of 'sd|var|cv|fano'
#      --count_hist_num_bins <int>  number of bins to distribute counts in the histogram (default: 10)
#      --count_hist_max_expr <float>  maximum value for the expression histogram (default: max(data))
#      --count_hist_convert_percentages       convert the histogram counts to percentage values.
#
#
#  --per_gene_plots                   plot each gene as a separate expression plot (barplot or lineplot)
#    --per_gene_plot_width <float>     default: 2.5
#    --per_gene_plot_height <float>    default: 2.5
#    --per_gene_plots_per_row <int>   default: 1
#    --per_gene_plots_per_col <int>   default: 2
#
#
########################################################
#  Data Filtering, in order of operation below:  #########################################################
#
#
#  --restrict_samples <string>   comma-delimited list of samples to restrict to (comma-delim list)
#
#  --top_rows <int>         only include the top number of rows in the matrix, as ordered.
#
#  --min_colSums <int>      min number of fragments, default: $min_colSums
#
#  --min_rowSums <int>      min number of fragments, default: $min_rowSums
#
#  --gene_grep <string>     grep on string to restrict to genes
#
#
#  --min_expressed_genes <int>        minimum number of genes (rows) for a column (replicate) having at least '--min_gene_expr_val'
#       --min_gene_expr_val <float>   a gene must be at least this value expressed across all samples.  (default: 0)
#
#  --min_across_ALL_samples_gene_expr_val <int>   a gene must have this minimum expression value across ALL samples to be retained.
#
#  --min_across_ANY_samples_gene_expr_val <int>   a gene must have at least this expression value across ANY single sample to be retained.
#
#  --minValAltNA <float>    minimum cell value after above transformations, otherwise convert to NA
#
#
#
#  --top_genes <int>        use only the top number of most highly expressed transcripts
#
#  --top_variable_genes <int>      Restrict to the those genes with highest coeff. of variability across samples (use median of replicates)
#
#      --var_gene_method <string>   method for ranking top variable genes ( 'coeffvar|anova', default: 'anova' )
#           --anova_maxFDR <float>    if anova chose, require FDR value <= anova_maxFDR  (default: 0.05)
#            or
#           --anova_maxP <float>    if set, over-rides anova_maxQ  (default, off, uses --anova_maxQ)
#
######################################
#  Data transformations:             #
######################################
#
#  --CPM                    convert to counts per million (uses sum of totals before filtering)
#
#  --log2
#
#  --center_rows            subtract row mean from each data point. (only used under '--heatmap' )
#
#  --Zscale_rows            Z-scale the values across the rows (genes)  
#
#########################
#  Clustering methods:  #
#########################
#
#  --gene_dist <string>        Setting used for --heatmap (samples vs. genes)
#                                  Options: euclidean, gene_cor
#                                           maximum, manhattan, canberra, binary, minkowski
#                                  (default: 'gene_cor')  Note: if using 'gene_cor', set method using '--gene_cor' below.
#
#
#  --sample_dist <string>      Setting used for --heatmap (samples vs. genes)
#                                  Options: euclidean, gene_cor
#                                           maximum, manhattan, canberra, binary, minkowski
#                                  (default: 'sample_cor')  Note: if using 'sample_cor', set method using '--sample_cor' below.
#
#
#  --gene_clust <string>       ward, single, complete, average, mcquitty, median, centroid (default: complete)
#  --sample_clust <string>     ward, single, complete, average, mcquitty, median, centroid (default: complete)
#
#  --gene_cor <string>             Options: pearson, spearman  (default: pearson)
#  --sample_cor <string>           Options: pearson, spearman  (default: pearson)
#
####################
#  Image settings: #
####################
#
#
#  --pdf_width <int>
#  --pdf_height <int>
#
################
# Misc. params #
################
#
#  --write_intermediate_data_tables         writes out the data table after each transformation.
#
#  --show_pipeline_flowchart                describe order of events and exit.
#
####################################################################################



__EOUSAGE__

    ;


my $SAVE_SESSION_FLAG;

my $matrix_file;
my $output_prefix = "";
my $LOG2_MEDIAN_CENTER = 0;
my $LOG2 = 0;

my $top_rows;

my $minValAltNA = undef;

my $CENTER = 0;
my $CPM = 0;
my $top_genes;

my $restrict_samples = "";

my $top_variable_genes;
my $var_gene_method = "anova";

my $gene_dist = "gene_cor";  # use --gene_cor setting (default: Pearson)
my $gene_clust = "complete";

my $sample_dist = "sample_cor"; # use --sample_cor setting (default: Pearson)
my $sample_clust = "complete";

my $prin_comp = "";
my $prin_comp_heatmaps = 0;
my $top_loadings_pc_heatmap = 0;

my $help_flag = 0;

my $pdf_width;
my $pdf_height;

my $use_columns_as_samples = 0;

my $samples_file;
my $compare_replicates_flag = 0;

my $write_intermediate_data_tables_flag = 0;

my $barplot_sum_counts_flag = 0;
my $boxplot_log2_dist;
my $sample_cor_matrix_flag = 0;
my $gene_cor_matrix_flag = 0;
my $heatmap_flag = 0;
my $heatmap_colorscheme;

my $mean_vs_sd_plot;

my $show_pipeline_flowchart = 0;

my $indiv_gene_cor;
my $top_cor_gene_count = undef;
my $min_gene_cor_val = undef;

my $gene_cor = 'pearson';
my $sample_cor = 'pearson';

my $gene_heatmaps;

my $min_expressed_genes;
my $min_gene_expr_val = 0;

my $min_across_ALL_samples_gene_expr_val = 0;
my $min_across_ANY_samples_gene_expr_val = 0;

my $anova_maxFDR = 0.05;
my $anova_maxP;

my $heatmap_scale_limits = "";
my $sample_cor_scale_limits = "";
my $sample_cor_subset_matrix = "";
my $sample_cor_sum_gene_factor_expr = "";

my $gene_grep;


my $ZSCALE_ROWS = 0;
my $gene_factors_file;

my $var_vs_count_hist_plot;
my $count_hist_num_bins = 10;
my $count_hist_max_expr;
my $count_hist_convert_percentages;

my $lexical_column_ordering;
my $order_by_gene_factor;

my $per_gene_plot_flag;
my $per_gene_plot_width = 2.5;
my $per_gene_plots_per_row = 1;
my $per_gene_plots_per_col = 2;


&GetOptions (  
    
    ## Inputs and outputs
    'matrix|m=s' => \$matrix_file,
    'samples|s=s' => \$samples_file, 
    'output|o=s' => \$output_prefix,
    'gene_factors|g=s' => \$gene_factors_file,
    

    ## Plotting actions:
    'compare_replicates' => \$compare_replicates_flag,
    'barplot_sum_counts' => \$barplot_sum_counts_flag,
    'boxplot_log2_dist=f' => \$boxplot_log2_dist,

    'sample_cor_matrix' => \$sample_cor_matrix_flag,
    'sample_cor_scale_limits=s' => \$sample_cor_scale_limits,
    'sample_cor_sum_gene_factor_expr=s' => \$sample_cor_sum_gene_factor_expr,
    
    'sample_cor_subset_matrix=s' => \$sample_cor_subset_matrix,
    
    'gene_cor_matrix' => \$gene_cor_matrix_flag,

    'indiv_gene_cor=s' => \$indiv_gene_cor,
    'top_cor_gene_count=i' => \$top_cor_gene_count,
    'min_gene_cor_val=f' => \$min_gene_cor_val,


    'heatmap' => \$heatmap_flag,
    "heatmap_scale_limits=s" => \$heatmap_scale_limits,
    "heatmap_colorscheme=s" => \$heatmap_colorscheme,
    "lexical_column_ordering" => \$lexical_column_ordering,
    "order_by_gene_factor" => \$order_by_gene_factor,
    
    'gene_heatmaps=s' => \$gene_heatmaps,
    
    'prin_comp=i' => \$prin_comp,
    'add_prin_comp_heatmaps=i' => \$prin_comp_heatmaps,           
    'add_top_loadings_pc_heatmap=i' => \$top_loadings_pc_heatmap,

    'mean_vs_sd' => \$mean_vs_sd_plot,
    
    'var_vs_count_hist=s' => \$var_vs_count_hist_plot,
    'count_hist_num_bins=i' => \$count_hist_num_bins,
    'count_hist_max_expr=f' => \$count_hist_max_expr,
    'count_hist_convert_percentages' => \$count_hist_convert_percentages,
    
    'per_gene_plots' => \$per_gene_plot_flag,
    'per_gene_plot_width=f' => \$per_gene_plot_width,
    'per_gene_plots_per_row=i' => \$per_gene_plots_per_row,
    'per_gene_plots_per_col=i' => \$per_gene_plots_per_col,

    ## Data transformations, in order of operation
    
    'restrict_samples=s' => \$restrict_samples,
    'top_rows=i' => \$top_rows,
    'min_colSums=i' => \$min_colSums,
    'min_rowSums=i' => \$min_rowSums,
    
    'gene_grep=s' => \$gene_grep,
    
    'min_expressed_genes=i' => \$min_expressed_genes,
    'min_gene_expr_val=f' => \$min_gene_expr_val,
    
    'min_across_ALL_samples_gene_expr_val=f' => \$min_across_ALL_samples_gene_expr_val,
    'min_across_ANY_samples_gene_expr_val=f' => \$min_across_ANY_samples_gene_expr_val,
    'minValAltNA=f' => \$minValAltNA,
    
    
    'CPM' => \$CPM,
    'top_genes=i' => \$top_genes,
    'log2' => \$LOG2,
    'top_variable_genes=i' => \$top_variable_genes,
    'var_gene_method=s' => \$var_gene_method,
    'anova_maxFDR=f' => \$anova_maxFDR,  # note, this is a filter not a transformation, but tied to var_gene_method='anova'
    'anova_maxP=f' => \$anova_maxP,           
               
    'center_rows' => \$CENTER,
    'Zscale_rows' => \$ZSCALE_ROWS,

    ## Clustering methods:
               
    'gene_dist=s' => \$gene_dist,
    'gene_clust=s' => \$gene_clust,
        
    'sample_dist=s' => \$sample_dist,
    'sample_clust=s' => \$sample_clust,
    
    'gene_cor=s' => \$gene_cor,
    'sample_cor=s' => \$sample_cor,
        
    ## Image settings:
    'pdf_width=i' => \$pdf_width,
    'pdf_height=i' => \$pdf_height,
    
    
    ## Misc params
    'help|h' => \$help_flag,
    'write_intermediate_data_tables' => \$write_intermediate_data_tables_flag,
    
    'show_pipeline_flowchart' => \$show_pipeline_flowchart,

    'save' => \$SAVE_SESSION_FLAG,
    
    );


if (@ARGV) {
    die "Error, don't understand parameters: @ARGV";
}

if ($help_flag) {
    die $usage;
}


if ($show_pipeline_flowchart) {
    &print_pipeline_flowcart();
    exit(1);
}


unless ($matrix_file) {
    die $usage;
}
my $col_line_num=`wc -l $matrix_file`;
my $col_name_line;
if ($col_line_num>=121){
	$col_name_line="FALSE";
}else{
	$col_name_line="NULL";
}
if ($heatmap_scale_limits) {
    if ($heatmap_scale_limits =~ /([\-\d\.]+),([\-\d\.]+)/) {
        my ($low, $high) = ($1, $2);
        $heatmap_scale_limits = [$low,$high];
    }
    else {
        die "Error, cannot parse heatmap_scale_limits: $heatmap_scale_limits";
    }
}

if (my $var_method = $var_vs_count_hist_plot) {

    unless ($var_method =~ /^(sd|var|cv|fano)$/) {
        die "Error, don't recognize method $var_method for --var_vs_count_hist  ";
    }
}


if (@ARGV) {
    die "Error, do not recognize params: @ARGV ";
}

unless ($output_prefix) {
    $output_prefix = basename($matrix_file);;
}

if ($var_gene_method && ! $var_gene_method =~ /^(coeffvar|anova)$/) {
    die "Error, do not recognize var_gene_method: $var_gene_method ";
}


if ($gene_dist !~ /^(euclidean|gene_cor|maximum|manhattan|canberra|binary|minkowski)$/) {
    
    die "Error, gene_dist must be set to euclidean|gene_cor|maximum|manhattan|canberra|binary|minkowski ";
}

if ($sample_dist !~ /^(euclidean|sample_cor|maximum|manhattan|canberra|binary|minkowski)$/) {
    
    die "Error, sample_dist must be set to euclidean|sample_cor|maximum|manhattan|canberra|binary|minkowski ";
}



main: {
    
    my $R_script_file = "$output_prefix.R";
        
    my $R_data_file = "$output_prefix.RData";

    my $Rscript = "library(cluster)\n";
    #$Rscript .= "library(gplots)\n";
    $Rscript .= "library(Biobase)\n";
    $Rscript .= "library(qvalue)\n";

    $Rscript .= "\n# try to reuse earlier-loaded data if possible\n";
    $Rscript .= "if (file.exists(\"$R_data_file\")) {\n"
             .  "    print('RESTORING DATA FROM EARLIER ANALYSIS')\n"
             .  "    load(\"$R_data_file\")\n"
             .  "} else {\n"
             .  "    print('Reading matrix file.')\n"
             .  "    primary_data = read.table(\"$matrix_file\", header=T, com=\'\', sep=\"\\t\", row.names=1, check.names=F)\n"
             .  "    primary_data = as.matrix(primary_data)\n"
             .  "}\n";
    

    # source these after potential data restoration above - in case they changed.
    $Rscript .= "source(\"$FindBin::Bin/R/heatmap.3.R\")\n";
    $Rscript .= "source(\"$FindBin::Bin/R/misc_rnaseq_funcs.R\")\n";
    $Rscript .= "source(\"$FindBin::Bin/R/pairs3.R\")\n";


    
    $Rscript .= "data = primary_data\n";
    
    
    if ($samples_file) {

        $Rscript .= "samples_data = read.table(\"$samples_file\", header=F, check.names=F)\n";
        #$Rscript .= "sample_types = as.factor(unique(samples_data[,1]))\n";
        $Rscript .= "sample_types = as.character(unique(samples_data[,1]))\n";
        
        # restrict data to those entries in the samples file
        $Rscript .= "data = data[, colnames(data) \%in% samples_data[,2], drop=F ]\n";
        
        # associate the data column names with the sample type
        $Rscript .= "nsamples = length(sample_types)\n"
            . "sample_colors = rainbow(nsamples)\n"
            . "names(sample_colors) = sample_types\n"
            . "sample_type_list = list()\n"
            . "for (i in 1:nsamples) {\n"
            . "    samples_want = samples_data[samples_data[,1]==sample_types[i], 2]\n"
            . "    sample_type_list[[sample_types[i]]] = as.vector(samples_want)\n"
            . "}\n";

    }
    else {

        ## Just use column names as the sample definitions
        
        $Rscript .= "sample_types = colnames(data)\n";
        
        $Rscript .= "nsamples = length(sample_types)\n"
            . "sample_colors = rainbow(nsamples)\n"
            . "sample_type_list = list()\n"
            . "for (i in 1:nsamples) {\n"
            . "    sample_type_list[[sample_types[i]]] = sample_types[i]\n"
            . "}\n";
        
    }

    ## sample factoring
    $Rscript .= "sample_factoring = colnames(data)\n";
    
    # sample factoring
    $Rscript .= "for (i in 1:nsamples) {\n"
        .  "    sample_type = sample_types[i]\n"
        .  "    replicates_want = sample_type_list[[sample_type]]\n"
        .  "    sample_factoring[ colnames(data) \%in% replicates_want ] = sample_type\n"
        .  "}\n";


    ## Filter out columns based on sample restriction
    if ($restrict_samples) {
        $restrict_samples =~ s/\s+//g;
        my @restricted_samples = split(/,/, $restrict_samples);
        $Rscript .= "restricted_samples = c(\"" . join("\",\"", @restricted_samples) . "\")\n";
        $Rscript .= "data = data[, sample_factoring \%in% restricted_samples, drop=F]\n";
        $Rscript .= "sample_types = restricted_samples\n";
        $Rscript .= "nsamples = length(sample_types)\n";
        
        ## redo the sample factoring

        $Rscript .= "sample_factoring = c()\n"
            .  "for (i in 1:nsamples) {\n"
            .  "    sample_type = sample_types[i]\n"
            .  "    replicates_want = sample_type_list[[sample_type]]\n"
            .  "    sample_factoring[ colnames(data) \%in% replicates_want ] = sample_type\n"
            .  "}\n";
        
    }

    if ($top_rows) {
        $Rscript .= "# restrict to top $top_rows rows of matrix.\n";
        $Rscript .= "data = data[1:min($top_rows,dim(data)[1]),]\n";
    }
    
    if ($samples_file) {
        ## reorder according to sample type:
        $Rscript .= "# reorder according to sample type.\n"
            .  "tmp_sample_reordering = order(sample_factoring)\n"
            .  "data = data[,tmp_sample_reordering,drop=F]\n"
            .  "sample_factoring = sample_factoring[tmp_sample_reordering]\n";

    }

    if ($gene_factors_file) {
        $Rscript .= "# parse gene factors\n"
                 .  "gene_factor_table = read.table(\"$gene_factors_file\", header=F, row.names=2)\n"
                 .  "gene_factors = unique(gene_factor_table[,1])\n";

        $Rscript .= "gene_factor_colors = rainbow(length(gene_factors))\n";
        $Rscript .= "names(gene_factor_colors) = gene_factors\n";
    }
    

    #################
    ## PLOTTING #####
    #################

    if ($barplot_sum_counts_flag) {

        ## set up the pdf output
        $Rscript .= "pdf(\"$output_prefix.barplot_sum_counts.pdf\"";
        if ($pdf_width) {
            $Rscript .= ", width=$pdf_width";
        }
        if ($pdf_height) {
            $Rscript .= ", height=$pdf_height";
        }
        $Rscript .= ")\n";
        

        $Rscript .= "op <- par(mar = c(10,10,10,10))\n"; 
        
        # raw frag conts
        $Rscript .= "barplot(colSums(data), las=2, main=paste(\"Sums of Frags\"), ylab='', cex.names=0.7)\n";
        
        $Rscript .= "dev.off()\n";
        $Rscript .= "par(op)\n";
   
    }
    
    if (defined $boxplot_log2_dist) {

        ## set up the pdf output
        $Rscript .= "pdf(\"$output_prefix.boxplot_log2_dist.pdf\"";
        if ($pdf_width) {
            $Rscript .= ", width=$pdf_width";
        }
        if ($pdf_height) {
            $Rscript .= ", height=$pdf_height";
        }
        $Rscript .= ")\n";


        ## get colors set up
        if ($samples_file) {
            $Rscript .= "# set up barplot colors:\n"
                .  "sample_cols = rainbow(nsamples)\n"
                .  "barplot_cols = c()\n"
                .  "for (i in 1:nsamples) {\n"
                . "    barplot_cols[ sample_factoring \%in% sample_types[i] ] = sample_cols[i]\n"
                . "}\n";
        }
        else {
            $Rscript .= "barplot_cols = rep('black', ncol(data))\n";
        }
        
        $Rscript .= "boxplot_data = data\n"
                 #.  "boxplot_data = apply(boxplot_data, 1:2, function(x) ifelse (x < $boxplot_log2_dist, NA, x))\n"
                 .  "boxplot_data[boxplot_data<$boxplot_log2_dist] = NA\n"
                 .  "boxplot_data = log2(boxplot_data+1)\n"
                 .  "num_data_points = apply(boxplot_data, 2, function(x) sum(! is.na(x)))\n"
                 .  "write.table(num_data_points, file=\"$output_prefix.feature_per_sample_count_min$boxplot_log2_dist.dat\", quote=F, sep=\"\t\")\n"
                 .  "num_features_per_boxplot = 100\n"
                 .  "for(i in 1:ceiling(ncol(boxplot_data)/num_features_per_boxplot)) {\n"
                 .  "    from = (i-1)*num_features_per_boxplot+1; to = min(from+num_features_per_boxplot-1, ncol(boxplot_data));\n"
                 .  "    op <- par(mar = c(0,4,2,2), mfrow=c(2,1))\n"
                 .  "    boxplot(boxplot_data[,from:to], outline=F, main=paste('boxplot log2 >', $boxplot_log2_dist, ', reps:', from, '-', to), xaxt='n')\n"
                 .  "    par(mar = c(7,4,2,2))\n"
                 .  "    barplot(num_data_points[from:to], las=2, main=paste('Count of features > ', $boxplot_log2_dist, ', reps:', from, '-', to), cex.names=0.7, col=barplot_cols[from:to])\n"
                 .  "    par(op)\n"
                 .  "}\n";
                     

        $Rscript .= "dev.off()\n";
    }
    

    if ($min_expressed_genes && $min_gene_expr_val) {
        ## remove columns (samples) having less than specified number of expressed genes.
        $Rscript .= "gene_count = apply(data, 2, function(x) sum(x>$min_gene_expr_val))\n";
        $Rscript .= "data = data[,gene_count>=$min_expressed_genes,drop=F]\n";
        $output_prefix .= ".min_${min_expressed_genes}_expr_genes";
        $Rscript .= "write.table(data, file=\"$output_prefix.dat\", quote=F, sep=\"\t\")\n" if $write_intermediate_data_tables_flag;
    }

    # remove genes that do not meet minimum expression threshold across all samples
    if ($min_across_ALL_samples_gene_expr_val) {
        $Rscript .= "min_gene_expr_per_row = apply(data, 1, function(x) min(x))\n";
        $Rscript .= "data = data[min_gene_expr_per_row >= $min_across_ALL_samples_gene_expr_val,,drop=F ]\n";
        $output_prefix .= ".min_gene_expr_${min_across_ALL_samples_gene_expr_val}_ALL_samples_required";
        
        $Rscript .= "write.table(data, file=\"$output_prefix.dat\", quote=F, sep=\"\t\")\n" if $write_intermediate_data_tables_flag;

    }
    
    # at least one sample must express the gene at this value.
    if ($min_across_ANY_samples_gene_expr_val) {
        $Rscript .= "max_gene_expr_per_row = apply(data, 1, max)\n";
        $Rscript .= "data = data[max_gene_expr_per_row >= $min_across_ANY_samples_gene_expr_val,,drop=F ]\n";
        $output_prefix .= ".min_gene_expr_${min_across_ANY_samples_gene_expr_val}_ANY_samples_required";
        
        $Rscript .= "write.table(data, file=\"$output_prefix.dat\", quote=F, sep=\"\t\")\n"; # if $write_intermediate_data_tables_flag;

    }
    


    if ($min_colSums > 0) {
        $Rscript .= "data = data\[,colSums\(data)>=" . $min_colSums . "]\n";
        $output_prefix .= ".minCol$min_colSums";
        $Rscript .= "write.table(data, file=\"$output_prefix.dat\", quote=F, sep=\"\t\")\n" if $write_intermediate_data_tables_flag;
    }
        
    if ($min_rowSums > 0) {
        $Rscript .= "data = data\[rowSums\(data)>=" . $min_rowSums . ",]\n";
        $output_prefix .= ".minRow$min_rowSums";
        $Rscript .= "write.table(data, file=\"$output_prefix.dat\", quote=F, sep=\"\t\")\n" if $write_intermediate_data_tables_flag;
    }

    if ($gene_grep) {
        $Rscript .= "data = data[grep(\"$gene_grep\", rownames(data)),,drop=F]\n";
    }
    

    if ($CPM) {

        $Rscript .= "cs = colSums(data)\n";
        $Rscript .= "data = t( t(data)/cs) * 1e6;\n";
        $output_prefix .= ".CPM";
        
    }
    
    if ($LOG2) {
        $Rscript .= "data = log2(data+1)\n";
        $output_prefix .= ".log2";
        $Rscript .= "write.table(data, file=\"$output_prefix.dat\", quote=F, sep=\"\t\")\n" if $write_intermediate_data_tables_flag;
    }
    

    if (defined $minValAltNA) {
        $Rscript .= "\n## any values below $minValAltNA are converted to NA\n";
        $Rscript .= "data[data<$minValAltNA] = NA\n\n";
    }
    

    if ($ZSCALE_ROWS) {
        $Rscript .= "# Z-scale the genes across all the samples for PCA\n";
        $Rscript .= "zscaled_data = data\n";
        
        $Rscript .= "for (i in 1:nrow(data)) {\n";
        $Rscript .= "    d = data[i,]\n";
        $Rscript .= "    d_mean = mean(d)\n";
        $Rscript .= "    d  = d - d_mean\n";
        $Rscript .= "    d = d / sd(d)\n";
        $Rscript .= "    zscaled_data[i,] = d\n";
        $Rscript .= "}\n\n";
        $Rscript .= "data = zscaled_data\n";
        
        $output_prefix .= ".ZscaleRows";
        $Rscript .= "write.table(data, file=\"$output_prefix.dat\", quote=F, sep=\"\t\")\n" if $write_intermediate_data_tables_flag;
        
    }
    
    ## Redo the sample factoring
    $Rscript .= "sample_factoring = colnames(data)\n";
    
    # sample factoring
    $Rscript .= "for (i in 1:nsamples) {\n"
        .  "    sample_type = sample_types[i]\n"
        .  "    replicates_want = sample_type_list[[sample_type]]\n"
        .  "    sample_factoring[ colnames(data) \%in% replicates_want ] = sample_type\n"
        .  "}\n";
    
    
    # generate the sample color-identification matrix
    $Rscript .= "sampleAnnotations = matrix(ncol=ncol(data),nrow=nsamples)\n";
    
    $Rscript .= "for (i in 1:nsamples) {\n"
        .  "  sampleAnnotations[i,] = colnames(data) %in% sample_type_list[[sample_types[i]]]\n"
        . "}\n";
    
    $Rscript .= "sampleAnnotations = apply(sampleAnnotations, 1:2, function(x) as.logical(x))\n";
    
    $Rscript .= "sampleAnnotations = sample_matrix_to_color_assignments(sampleAnnotations, col=sample_colors)\n";
    $Rscript .= "rownames(sampleAnnotations) = as.vector(sample_types)\n";
    $Rscript .= "colnames(sampleAnnotations) = colnames(data)\n";
    
    
    if ($top_genes) {
        
        $output_prefix .= ".top${top_genes}exprGenes";
        
        $Rscript .= "o = rev(order(apply(data, 1, max)))\n";
        $Rscript .= "o = o[1:min($top_genes,length(o))]\n";
        $Rscript .= "data = data[o,]\n";
        # some columns might now have zero sums, remove those
        $Rscript .= "data = data[,colSums(data)>0]\n";
        $Rscript .= "sampleAnnotations = sampleAnnotations[,colnames(data),drop=F]\n"; # when remove columns, adjust sample annotations
        
        $output_prefix .= ".top_${top_genes}";
        $Rscript .= "write.table(data, file=\"$output_prefix.dat\", quote=F, sep=\"\t\")\n" if $write_intermediate_data_tables_flag;
    }
    
    $Rscript .= "data = as.matrix(data) # convert to matrix\n";
        
        ;

    
    if ($top_variable_genes) {
        
        $output_prefix .= ".$var_gene_method.top${top_variable_genes}varGenes";
        
        $Rscript .= &get_top_most_variable_features($top_variable_genes, $output_prefix, $samples_file, $var_gene_method);
        # note 'data' gets subsetted by rows (features) found most variable across samples.
        
        # some columns might now have zero sums, remove those
        $Rscript .= "data = data[,colSums(data)>0]\n";
        $Rscript .= "sampleAnnotations = sampleAnnotations[,colnames(data)]\n"; # when remove columns, adjust sample annotations

        $output_prefix .= ".top_${top_variable_genes}_variable";
        $Rscript .= "write.table(data, file=\"$output_prefix.dat\", quote=F, sep=\"\t\")\n" if $write_intermediate_data_tables_flag;
        
    }
        

    if ($samples_file) {
        
        if ($compare_replicates_flag) {
            $Rscript .= &add_sample_QC_analysis_R();
        }
    }
    
        
    ## write modified data
    $Rscript .= "write.table(data, file=\"$output_prefix.dat\", quote=F, sep='\t')\n";
    
    
    
    if ($sample_cor_matrix_flag || $heatmap_flag || $sample_cor_subset_matrix) {

        if ($sample_cor_matrix_flag || $sample_cor_subset_matrix || $sample_dist =~ /sample_cor/) {

            $Rscript .= "sample_cor = cor(data, method=\'$sample_cor\', use='pairwise.complete.obs')\n";
            $Rscript .= "write.table(sample_cor,file=\"$output_prefix.result\", sep='\t', quote=FALSE,col.names=NA)\n";

        };
        
        ## cluster samples
        if ($sample_dist =~ /sample_cor/) {
                        
            $Rscript .= "sample_dist = as.dist(1-sample_cor)\n";
        }
        else {
            $Rscript .= "sample_dist = dist(t(data), method=\'$sample_dist\')\n";
        }
        
        $Rscript .= "hc_samples = hclust(sample_dist, method=\'$sample_clust\')\n";

    }


    if ($sample_cor_matrix_flag) {
        # sample correlation matrix
        
        ## set up the pdf output
        $Rscript .= "pdf(\"$output_prefix.sample_cor_matrix.pdf\"";
        if ($pdf_width) {
            $Rscript .= ", width=$pdf_width";
        }
        if ($pdf_height) {
            $Rscript .= ", height=$pdf_height";
        }
        $Rscript .= ")\n";
        
        if ($sample_cor_sum_gene_factor_expr) {
            unless ($gene_factors_file) {
                die "Error, if using --sample_cor_sum_gene_factor_expr, must specify --gene_factors ";
            }
            
            $Rscript .= "genes_w_factor = rownames(gene_factor_table)[gene_factor_table[,1] \%in% \'$sample_cor_sum_gene_factor_expr\']\n";
            $Rscript .= "genes_w_factor_data = data[rownames(data) \%in% genes_w_factor,]\n";
            $Rscript .= "genes_w_factor_sum_expr = apply(genes_w_factor_data, 2, sum)\n";
            
            ## make the sampleAnnotations corresond to the sum expression of this factor
            $Rscript .= "sampleAnnotations = matrix_to_color_assignments(as.matrix(genes_w_factor_sum_expr), col=colorpanel(256,'black','yellow'), by='col')\n";
            $Rscript .= "sampleAnnotations = t(sampleAnnotations)\n";
        }
        

        $Rscript .= "heatmap.3(sample_cor, dendrogram='both', Rowv=as.dendrogram(hc_samples), Colv=as.dendrogram(hc_samples), col = greenred(75), scale='none', symm=TRUE, key=TRUE,density.info='none', trace='none', symkey=FALSE, margins=c(10,10), cexCol=1, cexRow=1, cex.main=0.75 ";
    #      $Rscript .= "heatmap.3(sample_cor, dendrogram='both', Rowv=as.dendrogram(hc_samples), Colv=as.dendrogram(hc_samples), col = greenred(75), scale='none', symm=TRUE, key=TRUE,density.info='none', trace='none', symkey=FALSE, margins=c(10,10), cexCol=1, cexRow=1, cex.main=0.75, main=paste(\"sample correlation matrix\n\", \"$output_prefix\") ";
      
        if ($samples_file || $use_columns_as_samples || $sample_cor_sum_gene_factor_expr) {
            
            $Rscript .= ", ColSideColors=sampleAnnotations, RowSideColors=t(sampleAnnotations)";
        }
        
        if ($sample_cor_scale_limits) {
            my ($scaleRangeMin, $scaleRangeMax) = split(/,/, $sample_cor_scale_limits);
            unless (defined ($scaleRangeMin) && defined ($scaleRangeMax)) {
                die "Error, scale range not set correctly via --sample_cor_scale_limits \"$sample_cor_scale_limits\" ";
            }
            $Rscript .= ", scaleRangeMin=$scaleRangeMin, scaleRangeMax=$scaleRangeMax ";
        }
        
        $Rscript .= ")\n";

        $Rscript .= "dev.off()\n";
    }


    if ($sample_cor_subset_matrix) {
        # sample correlation matrix
        
        $Rscript .= "\n\n## generate plot of subsetted correlation matrix\n";
        $Rscript .= "subset_samples = read.table(\"$sample_cor_subset_matrix\", header=F)\n";
        $Rscript .= "colnames(subset_samples) = c('samples', 'reps')\n";
        
        $Rscript .= "subset_colnames = colnames(sample_cor)[ colnames(sample_cor) \%in% subset_samples\$reps ]\n";
        $Rscript .= "subset_rownames = colnames(sample_cor)[ ! colnames(sample_cor) \%in% subset_samples\$reps ]\n";
        $Rscript .= "sample_subset_cor_matrix = sample_cor[ subset_rownames, subset_colnames ]\n";
        
        $Rscript .= "subset_col_cor_matrix = sample_cor[subset_colnames, subset_colnames]\n";
        $Rscript .= "subset_row_cor_matrix = sample_cor[subset_rownames, subset_rownames]\n";
        
        if ($sample_dist =~ /sample_cor/) {
            
            $Rscript .= "hc_subset_col = hclust(as.dist(1-subset_col_cor_matrix), method=\"$sample_clust\")\n";
            $Rscript .= "hc_subset_row = hclust(as.dist(1-subset_row_cor_matrix), method=\"$sample_clust\")\n";
        }
        else {
            $Rscript .= "hc_subset_col = hclust(dist(subset_col_cor_matrix, method=\"$sample_dist\"), method=\"$sample_clust\")\n";
            $Rscript .= "hc_subset_row = hclust(dist(subset_row_cor_matrix, method=\"$sample_dist\"), method=\"$sample_clust\")\n";
        }
        

        ## set up the pdf output
        $Rscript .= "pdf(\"$output_prefix.sample_cor_matrix.subsetted.pdf\"";
        if ($pdf_width) {
            $Rscript .= ", width=$pdf_width";
        }
        if ($pdf_height) {
            $Rscript .= ", height=$pdf_height";
        }
        $Rscript .= ")\n";
        

        $Rscript .= "subset_colsamples = unique(samples_data[samples_data[,2] %in% subset_colnames,1])\n";
        $Rscript .= "subset_rowsamples = unique(samples_data[samples_data[,2] %in% subset_rownames,1])\n";
        
        
        
        $Rscript .= "sampleAnnotations_col_subset = sampleAnnotations[rownames(sampleAnnotations) \%in% subset_colsamples, subset_colnames]\n";
        $Rscript .= "sampleAnnotations_row_subset = sampleAnnotations[rownames(sampleAnnotations) \%in% subset_rowsamples, subset_rownames]\n";            
        

        $Rscript .= "heatmap.3(sample_subset_cor_matrix, dendrogram='both', Rowv=as.dendrogram(hc_subset_row), Colv=as.dendrogram(hc_subset_col), col = greenred(75), scale='none', key=TRUE,density.info='none', trace='none', symkey=FALSE, margins=c(10,10), cexCol=1, cexRow=1, cex.main=0.75, main=paste(\"sample correlation matrix\n\", \"$output_prefix\"), ColSideColors=sampleAnnotations_col_subset, RowSideColors=t(sampleAnnotations_row_subset) ";
        #$Rscript .= "heatmap.3(sample_cor, dendrogram='both', Rowv=as.dendrogram(hc_samples), Colv=as.dendrogram(hc_samples), col = greenred(75), scale='none', symm=TRUE, key=TRUE,density.info='none', trace='none', symkey=FALSE, margins=c(10,10), cexCol=1, cexRow=1, cex.main=0.75, main=paste(\"sample correlation matrix\n\", \"$output_prefix\") ";
        
        #if ($samples_file || $use_columns_as_samples) {

        #     $Rscript .= ", ColSideColors=sampleAnnotations, RowSideColors=t(sampleAnnotations)";
        #}

        if ($sample_cor_scale_limits) {
            my ($scaleRangeMin, $scaleRangeMax) = split(/,/, $sample_cor_scale_limits);
            unless (defined ($scaleRangeMin) && defined ($scaleRangeMax)) {
                die "Error, scale range not set correctly via --sample_cor_scale_limits \"$sample_cor_scale_limits\" ";
            }
            $Rscript .= ", scaleRangeMin=$scaleRangeMin, scaleRangeMax=$scaleRangeMax ";
        }
        
        $Rscript .= ")\n";

        $Rscript .= "dev.off()\n";
    }


    
    if ($prin_comp) {
        
        ## set up the pdf output
        $Rscript .= "pdf(\"$output_prefix.principal_components.pdf\"";
        if ($pdf_width) {
            $Rscript .= ", width=$pdf_width";
        }
        if ($pdf_height) {
            $Rscript .= ", height=$pdf_height";
        }
        $Rscript .= ")\n";


        $Rscript .= "data = as.matrix(data)\n";
        

        
        # Zscale the genes across samples for Prin Component analysis
        
        $Rscript .= "# Z-scale the genes across all the samples for PCA\n";
        $Rscript .= "prin_comp_data = data\n";
                    
        unless ($ZSCALE_ROWS) {
            $Rscript .= "for (i in 1:nrow(data)) {\n";
            $Rscript .= "    d = data[i,]\n";
            $Rscript .= "    d_mean = mean(d)\n";
            $Rscript .= "    d  = d - d_mean\n";
            $Rscript .= "    d = d / sd(d)\n";
            $Rscript .= "    prin_comp_data[i,] = d\n";
            $Rscript .= "}\n\n";
        }
        
        $Rscript .= "write.table(prin_comp_data, file=\"$output_prefix.ZscaleRows.dat\", quote=F, sep=\"\t\")\n" if $write_intermediate_data_tables_flag;
                
        $Rscript .= "pc = princomp(prin_comp_data, cor=TRUE)\n";
        $Rscript .= "pc_pct_variance = (pc\$sdev^2)/sum(pc\$sdev^2)\n";
        $Rscript .= "def.par <- par(no.readonly = TRUE) # save default, for resetting...\n"
            .  "gridlayout = matrix(c(1:4),nrow=2,ncol=2, byrow=TRUE);\n"
            .  "layout(gridlayout, widths=c(1,1));\n";
        
        if (1) {
            ## write out the PC info
            $Rscript .= "write.table(pc\$loadings, file=\"$output_prefix.ZscaleRows.PC.loadings\", quote=F, sep=\"\t\")\n";
            $Rscript .= "write.table(pc\$scores, file=\"$output_prefix.ZscaleRows.PC.scores\", quote=F, sep=\"\t\")\n";
            
        }
        
        

        $Rscript .= "for (i in 1:(max($prin_comp,2)-1)) {\n" # one plot for each n,n+1 component comparison.
            . "    xrange = range(pc\$loadings[,i])\n"
            . "    yrange = range(pc\$loadings[,i+1])\n"
            . "    samples_want = rownames(pc\$loadings) \%in\% sample_type_list[[sample_types[1]]]\n" # color according to sample
            . "    pc_i_pct_var = sprintf(\"(%.2f%%)\", pc_pct_variance[i]*100)\n"
            . "    pc_i_1_pct_var = sprintf(\"(%.2f%%)\", pc_pct_variance[i+1]*100)\n"
            . "    plot(pc\$loadings[samples_want,i], pc\$loadings[samples_want,i+1], xlab=paste('PC',i, pc_i_pct_var), ylab=paste('PC',i+1, pc_i_1_pct_var), xlim=xrange, ylim=yrange, col=sample_colors[1])\n"
            . "    for (j in 2:nsamples) {\n"
            . "        samples_want = rownames(pc\$loadings) \%in\% sample_type_list[[sample_types[j]]]\n"
            . "        points(pc\$loadings[samples_want,i], pc\$loadings[samples_want,i+1], col=sample_colors[j], pch=j)\n"
            . "    }\n"
            . "    plot.new()\n"
            . "    legend('topleft', as.vector(sample_types), col=sample_colors, pch=1:nsamples, ncol=2)\n"
            . "}\n\n";
        
                
        #else {
        #    $Rscript .= "for (i in 1:($prin_comp-1)) {\n"
        #              . "    pc_i_pct_var = sprintf(\"(%.2f%%)\", pc_pct_variance[i]*100)\n"
        #              . "    pc_i_1_pct_var = sprintf(\"(%.2f%%)\", pc_pct_variance[i+1]*100)\n"
        #              .  "   plot(pc\$loadings[,i], pc\$loadings[,i+1], xlab=paste('PC', i, pc_i_pct_var), ylab=paste('PC', i+1, pc_i_pct_var))\n"
        #              .  "   plot.new()\n"
        #              .  "}\n";
        #    
        #}
        
        $Rscript .= "par(def.par)\n"; # reset
        
        #$Rscript .= "dev.off();stop('debug')\n";
        
        $Rscript .= "pcscore_mat_vals = pc\$scores[,1:$prin_comp]\n";
        $Rscript .= "pcscore_mat = matrix_to_color_assignments(pcscore_mat_vals, col=colorpanel(256,'purple','black','yellow'), by='row')\n";
        $Rscript .= "colnames(pcscore_mat) = paste('PC', 1:ncol(pcscore_mat))\n"; 
        
        if ($prin_comp_heatmaps) {
            
            $Rscript .= &add_prin_comp_heatmaps($prin_comp_heatmaps, $output_prefix);
            
        }
        
        $Rscript .= "dev.off()\n";
        

        if ($top_loadings_pc_heatmap) {

            $Rscript .= &add_top_loadings_pc_heatmap($output_prefix, $top_loadings_pc_heatmap, $prin_comp);
            
        }
        
    }
    
    

    $Rscript .= "gene_cor = NULL\n";

    if ($gene_cor_matrix_flag || $heatmap_flag) {
        
        ## cluster genes
        if ($gene_dist =~ /gene_cor/) {
            
            $Rscript .= "if (is.null(gene_cor)) { gene_cor = cor(t(data), method=\'$gene_cor\', use='pairwise.complete.obs') }\n";
            
            $Rscript .= "gene_dist = as.dist(1-gene_cor)\n";
        }
        else {
            $Rscript .= "gene_dist = dist(data, method=\'$gene_dist\')\n";
        }
        
        $Rscript .= "if (nrow(data) <= 1) { message('Too few genes to generate heatmap'); quit(status=0); }\n";
        
        $Rscript .= "hc_genes = hclust(gene_dist, method=\'$gene_clust\')\n";
        
    }

    
    if ($gene_cor_matrix_flag) {
        # gene correlation matrix
        
        {
            $Rscript .= "if (is.null(gene_cor)) \n"
                     . "     gene_cor = cor(t(data), method=\'$gene_cor\', use='pairwise.complete.obs')\n";


            $Rscript .= "write.table(gene_cor, file=\"$output_prefix.gene_cor.dat\", quote=F, sep=\"\t\")\n";
            
            ## set up the pdf output
            $Rscript .= "pdf(\"$output_prefix.gene_cor_matrix.pdf\"";
            if ($pdf_width) {
                $Rscript .= ", width=$pdf_width";
            }
            if ($pdf_height) {
                $Rscript .= ", height=$pdf_height";
            }
            $Rscript .= ")\n";
            

            if ($gene_factors_file) {
                
                $Rscript .= "gene_factor_row_vals = as.factor(gene_factor_table[rownames(gene_cor),])\n";
                $Rscript .= "gene_factors_here = unique(gene_factor_row_vals)\n";
                $Rscript .= "geneFactorAnnotations = matrix(nrow=nrow(gene_cor), ncol=length(gene_factors_here))\n";
                $Rscript .= "for (i in 1:length(gene_factors_here)) {\n"
                         .  "    geneFactorAnnotations[,i] = gene_factor_row_vals \%in% gene_factors_here[i]\n"
                         .  "}\n";
                
                $Rscript .= "geneFactorAnnotations = apply(geneFactorAnnotations, 1:2, function(x) as.logical(x))\n";
          
                $Rscript .= "geneFactorColors = gene_factor_colors[gene_factors_here]\n";
                $Rscript .= "geneFactorAnnotations = t(sample_matrix_to_color_assignments(t(geneFactorAnnotations), col=geneFactorColors))\n";
                $Rscript .= "rownames(geneFactorAnnotations) = rownames(gene_cor)\n";
                $Rscript .= "colnames(geneFactorAnnotations) = gene_factors_here\n";
                
            }
            

            $Rscript .= "heatmap.3(gene_cor, dendrogram='both', Rowv=as.dendrogram(hc_genes), Colv=as.dendrogram(hc_genes), col=colorpanel(256,'purple','black','yellow'), scale='none', symm=TRUE, key=TRUE,density.info='none', trace='none', symkey=FALSE, margins=c(10,10), cexCol=1, cexRow=1, cex.main=0.75, main=paste(\"feature correlation matrix\n\", \"$output_prefix\" ) ";
            
            if ($gene_factors_file) {
                $Rscript .= ", RowSideColors=geneFactorAnnotations, ColSideColors=t(geneFactorAnnotations)";
                
            }

            elsif ($prin_comp) {
                
                $Rscript .= ", RowSideColors=pcscore_mat, ColSideColors=t(pcscore_mat)";
                
            }
            $Rscript .= ")\n";
            $Rscript .= "dev.off()\n";
        }
    }
    
    
    if ($indiv_gene_cor) {
        
        ## set up the pdf output
        $Rscript .= "pdf(\"$output_prefix.indiv_gene_cors.pdf\"";
        if ($pdf_width) {
            $Rscript .= ", width=$pdf_width";
        }
        if ($pdf_height) {
            $Rscript .= ", height=$pdf_height";
        }
        $Rscript .= ")\n";
        
        $Rscript .= "if (is.null(gene_cor)) \n"
            .  "     gene_cor = cor(t(data), method=\'$gene_cor\', use='pairwise.complete.obs')\n";
        
        $Rscript .= &write_study_individual_gene_correlations_function();

        if (!defined($top_cor_gene_count)) {
            $top_cor_gene_count = "NULL";
        }
        if (!defined($min_gene_cor_val)) {
            $min_gene_cor_val = "NULL";
        }

        my @indiv_genes = split(/,/, $indiv_gene_cor);
        foreach my $indiv_gene (@indiv_genes) {
            
            $Rscript .= "run_individual_gene_cor_analysis(\"$indiv_gene\", top_cor_genes=$top_cor_gene_count, min_gene_cor_val=$min_gene_cor_val)\n";
            
            #&study_individual_gene_correlations($indiv_gene, $top_cor_gene_count, $min_gene_cor_val);
            #last;
        }
        
        $Rscript .= "dev.off()\n";
    }
    
    
    
    if ($gene_heatmaps) {
    
        ## set up the pdf output
        $Rscript .= "pdf(\"$output_prefix.indiv_gene_heatmaps.pdf\"";
        if ($pdf_width) {
            $Rscript .= ", width=$pdf_width";
        }
        if ($pdf_height) {
            $Rscript .= ", height=$pdf_height";
        }
        $Rscript .= ")\n";
        
        my @indiv_genes = split(/,/, $gene_heatmaps);
        $Rscript .= &gene_heatmaps(@indiv_genes);
        
        if (scalar @indiv_genes > 1) {
            
            foreach my $indiv_gene (@indiv_genes) {
                $Rscript .= &gene_heatmaps($indiv_gene);
            }
        }
        $Rscript .= "dev.off()\n";
    }
    
    

    if ($heatmap_flag) {
        
        if ($CENTER) {
            $Rscript .= "myheatcol = greenred(75)\n";
            
            $Rscript .= "data = t(scale(t(data), scale=F)) # center rows, mean substracted\n";
            ;
            $output_prefix .= ".centered";
            
            $Rscript .= "write.table(data, file=\"$output_prefix.dat\", quote=F, sep='\t');\n";
            
            ##  Redo the distance calculations and clustering:

            ## //TODO: make this a subroutine 
            
            ## cluster samples
            if ($sample_dist !~ /sample_cor/) {
                $Rscript .= "# redo the sample clustering according to the centered distance values.\n";
                $Rscript .= "sample_dist = dist(t(data), method=\'$sample_dist\')\n";
                $Rscript .= "# redo the sample clustering\n";
                $Rscript .= "hc_samples = hclust(sample_dist, method=\'$sample_clust\')\n";
            }
            if ($gene_dist !~ /gene_cor/) {
                $Rscript .= "# redo the gene clustering according to centered distance values.\n";
                $Rscript .= "gene_dist = dist(data, method=\'$gene_dist\')\n";
                $Rscript .= "# redo the gene clustering\n";
                $Rscript .= "hc_genes = hclust(gene_dist, method=\'$gene_clust\')\n";
            }
            
        }
        else {
            if ($heatmap_colorscheme) {
                $Rscript .= "myheatcol = ${heatmap_colorscheme}(75)\n";
            } 
            else { 
                
                # default
                $Rscript .= "myheatcol = greenred(75)\n";
                ## use single gradient
                #$Rscript .= "myheatcol = colorpanel(75, 'black', 'red')\n";
            }
        }
        
        #$Rscript .= "hc_genes = hclust(gene_dist, method=\'$gene_clust\')\n";
		#capture.output(str(as.dendrogram(hc)),file = paste(c(opt$outfile,"hclust_eudience_complete.txt"),collapse =""))        
        # sample vs. gene heatmap
		$Rscript .= "capture.output(str(as.dendrogram(hc_genes)),file = paste(\"$output_prefix.genes_vs_samples_heatmap.txt\"))\n";
		#file=paste(\"$output_prefix.mean_vs_sd\", gtype, 'dat', sep='.')
        $Rscript .= "heatmap_data = data\n";
        
        ## set up the pdf output
        $Rscript .= "pdf(\"$output_prefix.genes_vs_samples_heatmap.pdf\"";
        if ($pdf_width) {
                $Rscript .= ", width=$pdf_width";
        }
        if ($pdf_height) {
            $Rscript .= ", height=$pdf_height";
        }
        $Rscript .= ")\n";
        
        if ($gene_factors_file) {

            $Rscript .= "gene_factor_row_vals = as.factor(gene_factor_table[rownames(heatmap_data),])\n";
            $Rscript .= "names(gene_factor_row_vals) = rownames(heatmap_data)\n";
            $Rscript .= "gene_factors_here = unique(gene_factor_row_vals)\n";
            $Rscript  .= "names(gene_factors_here) = gene_factors_here\n";
            $Rscript .= "num_gene_factors_here = length(gene_factors_here)\n";

            $Rscript .= "geneFactorColors = rainbow(num_gene_factors_here)\n";
            $Rscript .= "if (sum(gene_factors_here \%in% sample_types) == num_gene_factors_here) {\n"
                     .  "    geneFactorColors = sample_colors[names(gene_factors_here)]\n"
                     .  "}\n";


            if ($order_by_gene_factor) {
                ## reorder according to factors, and do clustering on a per-factor basis:
                $Rscript .= "gene_factor_ordering = c()\n";
                $Rscript .= "for (i in 1:num_gene_factors_here) {"
                         .  "    this_factor_data = heatmap_data[gene_factor_row_vals \%in% gene_factors_here[i],]\n"
                         .  "    this_factor_clust = hclust(dist(this_factor_data, method=\'$gene_dist\'), method=\'$gene_clust\')\n"
                         .  "    this_gene_order = order.dendrogram(as.dendrogram(this_factor_clust))\n"
                         .  "    this_ordered_gene_names = rownames(this_factor_data)[this_gene_order]\n"
                         .  "    gene_factor_ordering = c(gene_factor_ordering, this_ordered_gene_names)\n"
                         .  "}\n";
                $Rscript .= "heatmap_data = heatmap_data[gene_factor_ordering,]\n";
                $Rscript .= "gene_factor_row_vals = gene_factor_row_vals[gene_factor_ordering]\n";
               
            }
             
            $Rscript .= "geneFactorAnnotations = matrix(nrow=nrow(heatmap_data), ncol=num_gene_factors_here)\n";
            $Rscript .= "for (i in 1:num_gene_factors_here) {\n"
                .  "    geneFactorAnnotations[,i] = gene_factor_row_vals \%in% gene_factors_here[i]\n"
                .  "}\n";
            
            $Rscript .= "geneFactorAnnotations = apply(geneFactorAnnotations, 1:2, function(x) as.logical(x))\n";
            
            $Rscript .= "geneFactorAnnotations = t(sample_matrix_to_color_assignments(t(geneFactorAnnotations), col=geneFactorColors))\n";
            $Rscript .= "rownames(geneFactorAnnotations) = rownames(heatmap_data)\n";
            $Rscript .= "colnames(geneFactorAnnotations) = gene_factors_here\n";
        }
        
        

        if ($heatmap_scale_limits) {
            my ($low, $high) = @$heatmap_scale_limits;
            $Rscript .= "heatmap_data[heatmap_data < $low] = $low\n";
            $Rscript .= "heatmap_data[heatmap_data > $high] = $high\n";
        }
        
        my $dendrogram = 'both';
        my $Colv = "as.dendrogram(hc_samples)";
        if ($lexical_column_ordering) {
            $dendrogram = 'row';
            $Colv = "F";
            $Rscript .= "heatmap_data = heatmap_data[,order(colnames(heatmap_data))]\n";

        }
        my $Rowv = "as.dendrogram(hc_genes)";
        if ($gene_factors_file && $order_by_gene_factor) {
            if ($Colv eq 'F') {
                $dendrogram = 'none';
            }
            else {
                $dendrogram = 'col';
            }
            $Rowv = "F";
            
            
        }
        $Rscript .= "write.table(heatmap_data,file=\"$output_prefix.heatmap.result\", sep='\t', quote=FALSE,col.names=NA)\n";
      
        $Rscript .= "heatmap.3(heatmap_data, dendrogram=\'$dendrogram\', Rowv=$Rowv, Colv=$Colv, col=myheatcol, scale=\"none\", density.info=\"none\", trace=\"none\", key=TRUE, keysize=1.2, cexCol=1, margins=c(10,10), cex.main=0.75 ,labRow = $col_name_line";
 #       $Rscript .= "heatmap.3(heatmap_data, dendrogram=\'$dendrogram\', Rowv=$Rowv, Colv=$Colv, col=myheatcol, scale=\"none\", density.info=\"none\", trace=\"none\", key=TRUE, keysize=1.2, cexCol=1, margins=c(10,10), cex.main=0.75, main=paste(\"samples vs. features\n\", \"$output_prefix\" ) ";
        
        
        if ($gene_factors_file) {
            
            $Rscript .= ", RowSideColors = geneFactorAnnotations";
            
        }
        elsif ($prin_comp) {
            $Rscript .= ", RowSideColors=pcscore_mat";
        }
        
        if ($samples_file) {
            $Rscript .= ", ColSideColors=sampleAnnotations";
        }
        
        $Rscript .= ")\n";
    

        $Rscript .= "dev.off()\n";
        
    } # end of sample vs. genes heatmap
    
    
    if ($mean_vs_sd_plot) {
        
        $Rscript .= "pdf(\"$output_prefix.mean_vs_sd.pdf\")\n"
                 .  "data_mean = apply(data, 1, mean)\n"
                 .  "data_sd = apply(data, 1, sd)\n"
                 .  "data_mean_vs_sd_table = cbind(data_mean, data_sd)\n"
                 .  "data_mean_vs_sd_table = as.data.frame(data_mean_vs_sd_table)\n"
                 .  "write.table(data_mean_vs_sd_table, file=\"$output_prefix.mean_vs_sd.dat\", quote=F, sep=\"\t\")\n"
                 .  "plot(data_mean_vs_sd_table)\n";
        
        if ($gene_factors_file) {
            $Rscript .= "gene_pt_colors = rainbow(length(gene_factors))\n"
                     .  "for (i in 1:length(gene_factors)) {\n"
                     .  "    gtype = gene_factors[i]\n"
                     .  "    genes_w_factor = rownames(gene_factor_table)[gene_factor_table[,1] \%in% gtype]\n" 
                     .  "    points(data_mean_vs_sd_table[rownames(data_mean_vs_sd_table) \%in% genes_w_factor,], col=gene_pt_colors[i])\n"
                     .  "    write.table(data_mean_vs_sd_table[rownames(data_mean_vs_sd_table) \%in% genes_w_factor,], file=paste(\"$output_prefix.mean_vs_sd\", gtype, 'dat', sep='.'), quote=F, sep=\"\t\")\n"
                     
                     .  "}\n";
            $Rscript .= "legend('topright', legend=gene_factors, col=gene_pt_colors, pch=15)\n";
        }
        
        $Rscript .= "dev.off()\n";
        

    }

    if (my $var_method = $var_vs_count_hist_plot) {
        
        $Rscript .= "## var ($var_method) vs. count histogram plot\n";
        
        # $Rscript .= "data=data[1:1000,]\n"; ## DEBUGGING
        
        $Rscript .= "data_mean = apply(data, 1, mean)\n"
                 .  "data_sd = apply(data, 1, sd)\n"
                 .  "data_var = sqrt(data_sd)\n"
                 .  "data_cv = data_sd/data_mean\n"
                 .  "data_fano = (data_sd^2)/data_mean\n";



        $Rscript .= "data_stats_table = data.frame(data_mean=data_mean, data_var=data_var, data_sd=data_sd, data_cv=data_cv, data_fano=data_fano)\n"
                 .  "write.table(data_stats_table, file=\"$output_prefix.variance_info.dat\", quote=F, sep=\"\t\")\n";
        
        ## sorty by specific variation method
        $Rscript .= "data_var_use = data_${var_method}\n";

        ## reorder the data matrix according to the var method used
        $Rscript .= "data=data[rev(order(data_var_use)),]\n";
        
        if ($count_hist_max_expr) {
            $Rscript .= "data[data>$count_hist_max_expr] = $count_hist_max_expr\n";
        }

        # make histogram
        $Rscript .= "brks = seq(0,max(data),max(data)/$count_hist_num_bins)\n";
        if ($count_hist_convert_percentages) {
            $Rscript .= "count_hist_matrix = t(apply(data, 1, function(x) { h=hist(x, breaks=brks, plot=F, include.lowest=T, right=T); (h\$counts/sum(h\$counts)*100);}))\n";
        }
        else {
            $Rscript .= "count_hist_matrix = t(apply(data, 1, function(x) { h=hist(x, breaks=brks, plot=F, include.lowest=T, right=T); h\$counts;}))\n";
        }
        $Rscript .= "colnames(count_hist_matrix) = brks[2:length(brks)]\n";
        
        # set up the variation colorbar
        $Rscript .= "data_var_use = data_var_use[rev(order(data_var_use))]\n";
        $Rscript .= "data_var_use = as.matrix(data_var_use)\n";
        $Rscript .= "cv_colors = matrix_to_color_assignments(t(data_var_use), col=colorpanel(256,'purple','black','yellow'), by='row')\n";
        $Rscript .= "rownames(cv_colors) = c(\'$var_method\')\n";
        

        if ($heatmap_scale_limits) {
            my ($low, $high) = @$heatmap_scale_limits;
            $Rscript .= "count_hist_matrix[count_hist_matrix < $low] = $low\n";
            $Rscript .= "count_hist_matrix[count_hist_matrix > $high] = $high\n";
        }
        
        $Rscript .= "pdf(\"$output_prefix.${var_method}_vs_count_hist.pdf\")\n";
        $Rscript .= "heatmap.3(count_hist_matrix, Rowv=F, Colv=F, dendrogram='none', col=colorpanel(max(count_hist_matrix), low='black', high='yellow'), scale='none', symm=TRUE, key=TRUE,density.info='none', trace='none', symkey=FALSE, margins=c(10,10), cexCol=1, cexRow=1, cex.main=0.75, main=\"$var_method vs. count hist\", RowSideColors=t(cv_colors))\n";
        
        $Rscript .= "dev.off()\n";
    }
    
    if ($per_gene_plot_flag) {
      
        
        #    --per_gene_plot_width <float>     default: 2.5                                                                      
#    --per_gene_plot_height <float>    default: 2.5                                                                      
#    --per_gene_plots_per_row <int>   default: 1                                                                         
#    --per_gene_plots_per_col <int>   default: 2                                                                         
#
        $Rscript .= "# per gene plots\n";
        $Rscript .= "pdf(file=\"$output_prefix.per_gene_plots.pdf\")\n";
        $Rscript .= "par(mfrow=c($per_gene_plots_per_col, $per_gene_plots_per_row))\n";
        $Rscript .= "gene_names = rownames(data)\n";

        ## get colors set up
        if ($samples_file) {
            $Rscript .= "# set up barplot colors:\n"
                .  "sample_cols = rainbow(nsamples)\n"
                .  "barplot_cols = c()\n"
                .  "for (i in 1:nsamples) {\n"
                . "    barplot_cols[ sample_factoring \%in% sample_types[i] ] = sample_cols[i]\n"
                . "}\n";
        }
        else {
            $Rscript .= "barplot_cols = rep('black', ncol(data))\n";
        }

                
        $Rscript .= "for (i in 1:length(data[,1])) {\n";
        $Rscript .= "    gene_data = data[i,]\n";
        $Rscript .= "    ymin = min(gene_data); ymax = max(gene_data);\n";
        $Rscript .= "    barplot(as.numeric(gene_data), cex.names=0.5, names.arg=colnames(data), las=2, main=gene_names[i], col=barplot_cols)\n";
        #}
        #  else {
        #      print $ofh "    plot(as.numeric(data), type='l', ylim=c(ymin,ymax), main=gene_names[i], col='blue', xaxt='n', xlab='', ylab='')\n";
        #     print $ofh "    axis(side=1, at=1:length(data), labels=colnames(all_data), las=2)\n";
        
        #}
        $Rscript .= "}\n";
        $Rscript .= "dev.off()\n";
        
    }
    

    
    #############################
    ## END OF PLOTTING ##########
    #############################

    if ($SAVE_SESSION_FLAG) {
        $Rscript .= "save(list=ls(all=TRUE), file=\"$R_data_file\")\n";
    }
    
            
    open (my $ofh, ">$R_script_file") or die "Error, cannot write to $R_script_file";    
    print $ofh $Rscript;
    close $ofh;
    
    &process_cmd("R --vanilla -q < $R_script_file");

    exit(0);
    

}

   
####
sub process_cmd {
    my ($cmd) = @_;

    print STDERR "CMD: $cmd\n";
    my $ret = system($cmd);
    
    if ($ret) {
        die "Error, cmd: $cmd died with ret $ret";
    }

    return;
}

####
sub add_sample_QC_analysis_R {
    
    my $Rscript = "MA_plot = function(x, y, ...) {\n"
                #. "    print(x); print(y);\n"
                . "    M = log( (exp(x) + exp(y)) / 2)\n"
                . "    A = x - y;\n"
                . "    res = list(x=M, y=A)\n"
                . "    return(res)\n"
                . "}\n";
    
    $Rscript .= "MA_color_fun = function(x,y) {\n"
             .  "    col = sapply(y, function(y) ifelse(abs(y) >= 1, 'red', 'black')) # color 2-fold diffs\n" 
             .  "    return(col)\n"
             .  "}\n";

    $Rscript .= "Scatter_color_fun = function(x,y) {\n"
             .  "    col = sapply(abs(x-y), function(z) ifelse(z >= 1, 'red', 'black')) # color 2-fold diffs\n"
             #.  "    print(col)\n"
             .  "    return(col)\n"
             .  "}\n";


    $Rscript .= "for (i in 1:nsamples) {\n"     
        . "    sample_name = sample_types[[i]]\n"
        
        . "    cat('Processing replicate QC analysis for sample: ', sample_name, \"\n\")\n"

        #. "    print(sample_name)\n"
        . "    samples_want = sample_type_list[[sample_name]]\n"
        #. "    print(samples_want)\n"
        . "    samples_want = colnames(data) \%in% samples_want\n"
        #. "    print(samples_want)\n"
        
        . "    if (sum(samples_want) > 1) {\n"
        . "        pdf(file=paste(sample_name, '.rep_compare.pdf', sep='')";
    if ($pdf_width) {                                                                                                                                                                                          
        $Rscript .= ", width=$pdf_width";                                                                                                                                                                      
    }                                                                                                                                                                                                          
    if ($pdf_height) {                                                                                                                                                                                         
        $Rscript .= ", height=$pdf_height";                                                                                                                                                                    
    }                                                                                                                                                                                                          
    
    $Rscript .= ")\n";           
    
    
    $Rscript .= "        d = data[,samples_want]\n"
              . "        op <- par(mar = c(10,10,10,10))\n";
     
    if ($LOG2) {
        $Rscript .= "        barplot(colSums(2^(d-1)), las=2, main=paste(\"Sum of Frags for replicates of:\", sample_name), ylab='', cex.names=0.7)\n";
    }
    else {
        
        $Rscript .= "        barplot(colSums(d), las=2, main=paste(\"Sum of Frags for replicates of:\", sample_name), ylab='', cex.names=0.7)\n"
    }
    
    $Rscript  .= "        par(op)\n"
                . "        pairs3(d, pch='.', CustomColorFun=Scatter_color_fun, main=paste('Replicate Scatter:', sample_name)) # scatter plots\n"
                . "        pairs3(d, XY_convert_fun=MA_plot, CustomColorFun=MA_color_fun, pch='.', main=paste('Replicate MA:', sample_name)); # MA plots\n"
                # . "        pairs3(d, XY_convert_fun=function(x,y) qqplot(x,y,plot.it=F), main=paste('Replicate QQplots:', sample_name)) # QQ plots\n" 
                . "        reps_cor = cor(d, method=\"$sample_cor\", use='pairwise.complete.obs')\n"
                . "        hc_samples = hclust(as.dist(1-reps_cor), method=\"complete\")\n"
                . "        heatmap.3(reps_cor, dendrogram='both', Rowv=as.dendrogram(hc_samples), Colv=as.dendrogram(hc_samples), col = cm.colors(256), scale='none', symm=TRUE, key=TRUE,density.info='none', trace='none', symbreaks=F, margins=c(10,10), cexCol=1, cexRow=1, main=paste('Replicate Correlations:', sample_name) )\n"
                . "        dev.off()\n"
                . "    }\n"
                . "}\n";
    
    return($Rscript);
}

####
sub get_top_most_variable_features {
    my ($top_variable_genes, $output_prefix, $samples_file, $method) = @_;
    

    my $Rscript = "";
    
    if ($method eq "coeffvar") {
        $Rscript = &get_top_var_features_via_coeffvar($top_variable_genes, $output_prefix, $samples_file);
        
    }
    elsif ($method eq "anova") {
        $Rscript = &get_top_var_features_via_anova($top_variable_genes, $output_prefix, $samples_file);

    }
    else {
        confess "Error, get top var features for method: $method is not implemented";
    }
    

    return($Rscript);
}


####
sub get_top_var_features_via_anova {
    my ($top_variable_genes, $output_prefix, $samples_file) = @_;

    my $Rscript = "";
    
    if (! $samples_file) {
        $Rscript .= "print('WARNING: samples not grouped according to --samples_file, each column is treated as a different sample')\n";
    }
    

    $Rscript .= "    anova_pvals = c()\n";

    $Rscript .= "    for (j in 1:nrow(data)) {\n"
#             .  "        print(j);\n"  
             .  "        feature_vals = data[j,]\n"
             .  "        data_for_anova = data.frame(y=feature_vals, group=factor(sample_factoring))\n"
             .  "        fit = lm(y ~ group, data_for_anova)\n"
             .  "        a = anova(fit)\n"
             .  "        p = a\$\"Pr(>F)\"[1]\n"
             .  "        anova_pvals[j] = p\n"
             #.  "    print(a)\n"
             .  "    }\n";


    $Rscript .= "anova_ranking = order(anova_pvals)\n";
    
    # get FDR via Qvalues
    $Rscript .= "fdr = p.adjust(anova_pvals)\n"
             .  "anova_stats = data.frame(Pvals=anova_pvals, FDR=fdr)\n"
             .  "rownames(anova_stats) = rownames(data)\n";
    

    $Rscript .= "write.table(anova_stats[anova_ranking,], file=\"$output_prefix.anova\", quote=F, sep=\"\t\")\n";

    # retain only those that are significant according to Q-value cutoff.
    $Rscript .= "adj_data = cbind(data, anova_stats)\n"
        .  "adj_data = adj_data[order(adj_data\$Pvals),]\n";
    
    $Rscript .= "write.table(adj_data,file=\"$output_prefix.anova_with_data\", quote=F, sep=\"\t\")\n";
    
    if (defined $anova_maxP) {
        $Rscript .= "signif_indices = (adj_data\$Pvals<=$anova_maxP)\n";
    }
    else {
        $Rscript .= "signif_indices = (adj_data\$FDR<=$anova_maxFDR)\n";
    }
    
    $Rscript .= "if (sum(signif_indices)==0) stop('No significant variable features identified. Stopping.');\n"
             .  "adj_data = adj_data[signif_indices,]\n"
             .  "data = adj_data[,colnames(adj_data) %in% colnames(data)]\n";
        
    $Rscript .= "data = data[1:min(nrow(data),$top_variable_genes),] # restrict to $top_variable_genes with anova sig P-value ranking\n";
    
    return($Rscript);
}




####
sub get_top_var_features_via_coeffvar {
    my ($top_variable_genes, $output_prefix, $samples_file) = @_;
    

    my $Rscript = "";

    if ($samples_file) {
        $Rscript .= "sample_medians_df = data.frame(row.names=rownames(data))\n"
                 .  "print(paste('colnames of data frame:', colnames(data)))\n"
                 .  "for (i in 1:nsamples) {\n"
                 .  "    sample_type = sample_types[i]\n"
                 .  "    print(sample_type)\n"
                 .  "    replicates_want = sample_type_list[[sample_type]]\n"
                 #.  "    print(paste('replicates wanted: ' , replicates_want))\n"
                 .  "    data_subset = as.data.frame(data[, colnames(data) \%in% replicates_want])\n"
                 .  "    print(paste('ncol(data_subset):', ncol(data_subset)))\n"
                 .  "    if (ncol(data_subset) >= 1) {\n"
                 .  "        sample_median_vals = apply(data_subset, 1, median)\n"
                 .  "        print(paste('Sample name: ', sample_type))\n"
                 #.  "        print(sample_median_vals)\n"
                 .  "        sample_medians_df[,toString(sample_type)] = sample_median_vals\n"
                 .  "    }\n"
                 .  "}\n"
                 .  "write.table(sample_medians_df, file=\"$output_prefix.sample_medians.dat\", quote=F, sep=\"\t\")\n";
    }
    else {
        $Rscript .= "sample_medians_df = data\n";
    }

    $Rscript .= "coeff_of_var_fun = function(x) ( sd(x+0.1)/mean(x+0.1) ) # adding pseudocounts\n"
             .  "gene_coeff_of_var = apply(sample_medians_df, 1, coeff_of_var_fun)\n"
             .  "gene_order_by_coeff_of_var_desc = rev(order(gene_coeff_of_var))\n"
             .  "write.table(gene_coeff_of_var[gene_order_by_coeff_of_var_desc], file=\"$output_prefix.sample_medians.coeff_of_var\", quote=F, sep=\"\t\")\n"
             .  "data = data[gene_order_by_coeff_of_var_desc[1:min(nrow(data),$top_variable_genes)],]\n";
    
    
    return($Rscript);
}

####
sub add_prin_comp_heatmaps {
    my ($num_top_genes_PC_extreme, $output_prefix) = @_;

    my $Rscript = "## generate heatmaps for PC extreme vals\n"
        . "uniq_genes = c()\n"
                . "for (i in 1:$prin_comp) {\n"
                . "    ## get genes with extreme vals\n"
                . "    print(paste('range', range(pc\$scores[,i])))\n"
                . "    ordered_gene_indices = order(pc\$scores[,i])\n"
                . "    num_genes = length(ordered_gene_indices)\n"
                . "    extreme_ordered_gene_indices = unique(c(1:$num_top_genes_PC_extreme, (num_genes-$num_top_genes_PC_extreme):num_genes))\n"
                . "    print(extreme_ordered_gene_indices)\n"
                . "    selected_gene_indices = ordered_gene_indices[extreme_ordered_gene_indices]\n"
                . "    print('selected gene indices');print(selected_gene_indices);\n"
                . "    print('PC scores:');print(pc\$scores[selected_gene_indices,i])\n"
                . "    selected_genes_matrix = data[selected_gene_indices,]\n"
                #. "    print(selected_genes_matrix)\n"
                . "    pc_color_bar_vals = pcscore_mat_vals[selected_gene_indices,i]\n"
                . "    print(pc_color_bar_vals)\n"
                . "    pc_color_bar = as.matrix(pcscore_mat[selected_gene_indices,i])\n";

    $Rscript .= "uniq_genes = unique(c(uniq_genes, rownames(selected_genes_matrix)))\n";


    #if (! $LOG2) {
    #    $Rscript .= "    selected_genes_matrix = log2(selected_genes_matrix+1)\n";
    #}
    $Rscript .=     "    write.table(selected_genes_matrix, file=paste(\"$output_prefix\", '.PC',i,'_extreme',$num_top_genes_PC_extreme,'.matrix', sep=''), quote=F, sep=\"\t\")\n";
    
    if ($CENTER) {
        $Rscript .= "    selected_genes_matrix = t(scale(t(selected_genes_matrix), scale=F))\n";
    }
    
    
    $Rscript .= "    heatmap.3(selected_genes_matrix, col=greenred(256), scale='none', density.info=\"none\", trace=\"none\", key=TRUE, keysize=1.2, cexCol=1, margins=c(10,10), cex.main=0.75, RowSideColors=pc_color_bar, cexRow=0.5, main=paste('heatmap for', $num_top_genes_PC_extreme, ' extreme of PC', i)";

    if ($samples_file) {
        $Rscript .= ", ColSideColors=sampleAnnotations";
    }
    $Rscript .= ")\n";
    $Rscript .= "}\n";
    

    ##  Include a heatmap containing all selected genes across all PCs.

    $Rscript .= "all_selected_genes_matrix = data[uniq_genes,]\n";
    #if(! $LOG2) {
    #    $Rscript .= "all_selected_genes_matrix = log2(all_selected_genes_matrix + 1)\n";
    #}
    if ($CENTER) {
        $Rscript .= "all_selected_genes_matrix = t(scale(t(all_selected_genes_matrix), scale=F))\n";
    }
    
    $Rscript .= "write.table(all_selected_genes_matrix, file=paste(\"$output_prefix\", '.PC_all','_extreme',$num_top_genes_PC_extreme,'.matrix', sep=''), quote=F, sep=\"\t\")\n";
    $Rscript .= "heatmap.3(all_selected_genes_matrix, col=greenred(256), scale='none', density.info=\"none\", trace=\"none\", key=TRUE, keysize=1.2, cexCol=1, margins=c(10,10), cex.main=0.75, cexRow=0.5, main=paste('heatmap for ALL selected ', $num_top_genes_PC_extreme, ' extreme of all PCs')";
    
    if ($samples_file) {
        $Rscript .= ", ColSideColors=sampleAnnotations";
    }
    $Rscript .= ")\n";
    

    return($Rscript);
}


####
sub add_top_loadings_pc_heatmap {
    my ($out_prefix, $top_loadings_pc_heatmap, $prin_comp) = @_;

    #non-negative matrix factorization NMF   (decomposition into two matrices)
    #nmf consensus clustering

    #kruskal-wallis test

    # subtracting out PC 

    my $Rscript = "abs_loadings = abs(pc\$scores[,1:$prin_comp])\n"
                . "max_loadings = apply(abs_loadings, 1, max)\n"
                . "ordered_loadings = rev(order(max_loadings))\n"
                . "top_loadings_pc_matrix = data[ordered_loadings[1:$top_loadings_pc_heatmap],]\n";

    if (! $LOG2) {
        $Rscript .= "top_loadings_pc_matrix = log2(top_loadings_pc_matrix+1)\n";
    }
    
    

    $Rscript .=     "write.table(top_loadings_pc_matrix, file=paste(\"$output_prefix\", '.PC.top_', $top_loadings_pc_heatmap, '_loadings.matrix', sep=''), quote=F, sep=\"\t\")\n";
    $Rscript .=     "write.table(pc\$scores[ordered_loadings[1:$top_loadings_pc_heatmap],1:$prin_comp], file=paste(\"$output_prefix\", '.PC.top_', $top_loadings_pc_heatmap, '_loadings.dat', sep=''), quote=F, sep=\"\t\")\n";

    $Rscript .= "pdf(paste(\"$output_prefix\", '.PC.top_', $top_loadings_pc_heatmap, '_loadings.matrix.pdf', sep=''))\n";
    
    if ($CENTER) {
        $Rscript .= "    top_loadings_pc_matrix = t(scale(t(top_loadings_pc_matrix), scale=F))\n";
    }
    
    
    $Rscript .= "    heatmap.3(top_loadings_pc_matrix, col=greenred(256), scale='none', density.info=\"none\", trace=\"none\", key=TRUE, keysize=1.2, cexCol=1, margins=c(10,10), cex.main=0.75, cexRow=0.5, main=paste('heatmap for', $top_loadings_pc_heatmap, ' extreme all Prin. Comps.')";
    
    if ($samples_file) {
        $Rscript .= ", ColSideColors=sampleAnnotations";
    }
    $Rscript .= ")\n";
    
    $Rscript .= "dev.off()\n";


    return($Rscript);
}


####
sub print_pipeline_flowchart {
    
    print <<__EOTEXT__;

    Start.

    read data table
    read samples file (optional)

    ? plots: barplots for sum counts per replicate
    ? plots: boxplots for feature count distribution and barplots for number of features mapped.
    
    ? filter: restrict to specified samples (columns)
    ? filter: min expressed genes at min val
    ? filter: min column sums
    ? filter: min row sums

    
    ? data_transformation: CPM
    ? data_transformation: log2

    ? data_transformation: minValAltNA

    ? data_annotation: sample factoring
    ? data_annotation: sample coloring setup

    ? filter: top expressed genes
    ? filter: top variable genes (coeffvar|anova)

    ? plots: sample replicate comparisons

    ? output: resulting data table post-filtering and data transformations.

    ? plots: sample correlation matrix
    
    ? plots: principal components analysis  (note: rows (aka genes) are Z-scaled across samples before PCA)
    ?       plots: heatmaps for features assigned extreme values in PCA

    ? plots: feature/gene correlation matrix

    ? plots: individual gene correlation plots and heatmaps

    ? plots: samples vs. features matrix

    ? plots: mean expression vs. standard deviation

    End.

    
__EOTEXT__

    ;

    return;
}


####
sub write_study_individual_gene_correlations_function {

    my $Rscript  = "# individual gene correlation analysis\n";
    $Rscript .= "run_individual_gene_cor_analysis = function(gene_id, top_cor_genes=NULL, min_gene_cor_val=NULL) {\n";

    $Rscript .= "    if (! gene_id \%in% colnames(gene_cor)) {\n"
             .  "        print(paste(\"WARNING,\", gene_id, \" not included in correlation matrix, skipping...\"))\n"
             .  "        return();\n"
             .  "    }\n"
             .  "    this_gene_cor = as.vector(gene_cor[gene_id,])\n"
             .  "    names(this_gene_cor) = colnames(gene_cor)\n";
    
        
    $Rscript .=  "    if (! is.null(top_cor_genes)) {\n"
             .   "         top_cor_gene_indices = rev(order(this_gene_cor))\n"
             .   "         top_cor_gene_indices = top_cor_gene_indices[1:top_cor_genes]\n"
             .   "    } else {\n"
             .   "        top_cor_gene_indices = which(this_gene_cor>=min_gene_cor_val)\n"
             .   "        if (length(top_cor_gene_indices) < 2) { # count self here\n"
             .   "            print(paste(\"WARNING, no genes correlated >=\", min_gene_cor_val, \" to \", gene_id))\n"
             .   "            return();\n"
             .   "        }\n"
             .   "    }\n";

    $Rscript .=  "    this_gene_cor_matrix = gene_cor[top_cor_gene_indices, top_cor_gene_indices]\n";
    $Rscript .=  "    gene_expr_submatrix = data[top_cor_gene_indices,]\n";
    if (! $LOG2) {
        $Rscript .= "    gene_expr_submatrix = log2(gene_expr_submatrix+1)\n";
    }
    
    ## remove those samples summing to zero
    $Rscript .= "    gene_expr_submatrix = gene_expr_submatrix[,colSums(gene_expr_submatrix) > 0]\n";
    
    ## adjust for possibly having removed some columns
    $Rscript .= "    these_sample_annotations = sampleAnnotations[,colnames(gene_expr_submatrix)]\n";
    
    
    # gene correlation plot
    $Rscript .= "    this_gene_dist = as.dist(1-this_gene_cor_matrix)\n"
             .  "    this_hc_genes = hclust(this_gene_dist, method=\"$gene_clust\")\n";

    $Rscript .= "    this_sample_cor = cor(gene_expr_submatrix, method=\"$sample_cor\", use='pairwise.complete.obs')\n"
             .  "    this_hc_samples = hclust(as.dist(1-this_sample_cor), method=\"$sample_clust\")\n";

    $Rscript .= "    heatmap.3(this_gene_cor_matrix, dendrogram='both', Rowv=as.dendrogram(this_hc_genes), Colv=as.dendrogram(this_hc_genes), col=colorpanel(256,'purple','black','yellow'), scale='none', symm=TRUE, key=TRUE,density.info='none', trace='none', symkey=FALSE, margins=c(10,10), cexCol=1, cexRow=1, cex.main=0.75, main=paste(\"feature correlation matrix\n\", gene_id))\n";

    # gene vs. samples plot

    # center rows
    $Rscript .= "    gene_expr_submatrix = t(scale(t(gene_expr_submatrix), scale=F))\n";
    
    
    $Rscript .= "    heatmap.3(gene_expr_submatrix, col=greenred(256), Rowv=as.dendrogram(this_hc_genes), Colv=as.dendrogram(this_hc_samples), scale='none', density.info=\"none\", trace=\"none\", key=TRUE, keysize=1.2, cexCol=1, margins=c(10,10), cex.main=0.75, cexRow=0.5, main=paste('heatmap for most correlated to', gene_id)";

    if ($samples_file) {
        $Rscript .= ", ColSideColors=these_sample_annotations";
    }
    
    $Rscript .= ")\n";
    
    $Rscript .= "    return;\n";
    $Rscript .= "}\n\n";
    
    return($Rscript);
}

####
sub gene_heatmaps {
    my (@gene_ids) = @_;

    my $Rscript = "gene_list = c(\"" . join("\",\"", @gene_ids) . "\")\n";

    $Rscript .= "gene_submatrix = data[gene_list, ,drop=F]\n";

    if ($CENTER) {
        $Rscript .= "gene_submatrix = t(scale(t(gene_submatrix), scale=F))\n";
    }
    if ($samples_file) {
        $Rscript .= "gene_submatrix = gene_submatrix[,order(sample_factoring),drop=F]\n";
        $Rscript .= "coloring_by_sample = sampleAnnotations[,order(sample_factoring),drop=F]\n";
    }
    if (scalar(@gene_ids) == 1) {
        ## matrix must have multiple rows.  Just duplicate the last row
        $Rscript .= "gene_submatrix = rbind(gene_submatrix, gene_submatrix[1,])\n";
    }
    
    my $col = "greenred(75)";
    if ($CENTER) {
        $col = "colorpanel(75, 'black', 'red')";
    }

    
    $Rscript .= "heatmap.3(gene_submatrix, dendrogram='none', Rowv=F, Colv=F, col=$col, main='without clustering'";
    
    if ($samples_file) {
        $Rscript .= ", ColSideColors=coloring_by_sample";
    }
    
    $Rscript .= ")\n";

    { 
        ## Do it again and cluster too
    
        $Rscript .= "heatmap.3(gene_submatrix, col=$col, main='with clustering'";
        
        if ($samples_file) {
            $Rscript .= ", ColSideColors=coloring_by_sample";
        }
        
        $Rscript .= ")\n";
    }


    return($Rscript);
}
    
