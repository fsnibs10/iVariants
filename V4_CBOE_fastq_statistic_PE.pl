use strict;

my $querygene = $ARGV[0];


my @allsamples;
my %total_reads;
#my %total_reads=(
#	'E161_1' => 5987171,
#	'E161_2' => 7802572,
#	'E161_3' => 8269647
#);
#
#foreach my $isample (sort keys %total_reads){
#	print "$isample\t$total_reads{$isample}\n";
#	push(@allsamples,$isample);
#}



my %total_mapped;
my %total_mapped_frac;
my %total_aln;
my %total_aln_mapped;

my %mt_mapped;
my %mt_mapped_frac;
my %chr_mapped;
my %chr_mapped_frac;
	
my %nondup_reads;
my %nondup_reads_frac;

my %avg_chr1_depth;
my %avg_orf_depth;

my %npos_dplow3;
my %npos_dplow3_frac;

my %avg_querydp;
my %npos_querylow3_frac;

my @fqfiles = <*_1.fastq.gz>;
foreach my $ifq (sort @fqfiles) {
	my ($sample) = $ifq =~ /(\S+)\_1\.fastq/;
	print "$ifq\t$sample\n";
	push(@allsamples,$sample);

	my $tmptotal = `zcat $ifq | wc -l | cut -f 1 -d ' ' | sed 's/ //g'`;
	chomp $tmptotal;
	chop $tmptotal if($tmptotal =~ /\r$/);
	$total_reads{$sample} = `expr $tmptotal / 2 | tr '\n' ' ' | sed 's/ //g'`;
	
	$total_reads{$sample} = $total_reads{$sample} ;	

	print "$sample\t$total_reads{$sample}\n";
}



my @bamfiles = <mapping/*.bwa.sorted.bam>;
foreach my $ibam (sort @bamfiles) {
	my ($sample) = $ibam =~ /mapping\/(\S+)\.bwa/;
	print "$ibam\t$sample\n";
	# total mapped(7)
	my $tmp_unmapped = `samtools view -c -f 4 $ibam | tr '\n' ' ' | sed 's/ //g'`;
	$total_mapped{$sample} = $total_reads{$sample} - $tmp_unmapped;
	
	# total mapped fraction(8)
	$total_mapped_frac{$sample} = sprintf("%.3f",$total_mapped{$sample}/$total_reads{$sample});
	print "$sample\t$total_mapped{$sample}\t$total_mapped_frac{$sample}\ttotal mapped\n";
	
	# total alignment (self defined)
	my $tmp_aln = `samtools view -c -F 4 $ibam | tr '\n' ' ' | sed 's/ //g'`;
	$total_aln{$sample} = $tmp_aln;
	$total_aln_mapped{$sample} = $total_aln{$sample} - $total_mapped{$sample};
	

	# MT mapped(9)
	my $tmp_mtmapped = `samtools view -F 4 $ibam | awk '\$3=="MT"' | wc -l | tr '\n' ' ' | sed 's/ //g'`;
	$mt_mapped{$sample} = $tmp_mtmapped;
	
	# MT mapped fraction (10)
	$mt_mapped_frac{$sample} = sprintf("%.3f",$mt_mapped{$sample}/$total_mapped{$sample});
	print "$sample\t$mt_mapped{$sample}\t$mt_mapped_frac{$sample}\tMT mapped\n";

	# chromosome mapped (11)
	my $tmp_chrmapped = `samtools view -F 4 $ibam | awk '\$3=="I"||\$3=="II"||\$3=="III"' | wc -l | tr '\n' ' ' | sed 's/ //g'`;
	$chr_mapped{$sample} = $tmp_chrmapped;

	# chromosome mapped fraction (12)
	$chr_mapped_frac{$sample} = sprintf("%.3f",$chr_mapped{$sample}/$total_mapped{$sample});
	print "$sample\t$chr_mapped{$sample}\t$chr_mapped_frac{$sample}\tchr mapped\n";

}


my @rmdup = <mapping/*.bwa_rmdup.sorted.bam>;
foreach my $ibam (sort @rmdup) {
	my ($sample) = $ibam =~ /mapping\/(\S+)\.bwa/;

	# non-duplicated reads (13)
	my $tmp_nondupreads = `samtools view -c -F 4 $ibam | tr '\n' ' ' | sed 's/ //g'`;
	$nondup_reads{$sample} = $tmp_nondupreads;

	# non-duplicated reads fraction (14)
	$nondup_reads_frac{$sample} = sprintf("%.3f",$nondup_reads{$sample}/$total_mapped{$sample});
	print "$sample\t$nondup_reads{$sample}\t$nondup_reads_frac{$sample}\tnon-duplicated reads\n";

	
	# samtools depth can output each position depth
	system("samtools depth $ibam > $ibam.readdepth.txt");
	# avg read depth of chromosome1 (15)
	my $tmp_avgchr1depth = `awk '\$1=="I"' $ibam.readdepth.txt  | awk '{sum+=\$3}END{print sum}' | tr '\n' ' ' | sed 's/ //g'`;
	$avg_chr1_depth{$sample} = sprintf("%.2f",$tmp_avgchr1depth/5579133);
	print "$sample\t$avg_chr1_depth{$sample}\tchr1 ave depth\n";
	

	# samtools depth output ORF depth by bed file
	system("samtools depth -b ../FYPO_1312_essential_ORF.bed $ibam > $ibam.EORFreaddepth.txt");
	# avg read depth of ORF (16)
	my $tmp_avgorfdepth = `awk '{sum+=\$3}END{print sum}' $ibam.EORFreaddepth.txt | tr '\n' ' ' | sed 's/ //g'`;
	$avg_orf_depth{$sample} = sprintf("%.2f",$tmp_avgorfdepth/2119766);
	print "$sample\t$avg_orf_depth{$sample}\tessential gene orf ave depth\n";

	# Number of positions in essential gene ORF with dp<3 (17)
	my $tmp_nposdplow3 = `awk '\$3>=3' $ibam.EORFreaddepth.txt | wc -l | tr '\n' ' ' | sed 's/ //g'`;
	$npos_dplow3{$sample} = 2119766 - $tmp_nposdplow3;
	print "$sample\t$npos_dplow3{$sample}\tNpos<3 in essential gene ORF\n";	

	# fraction of postion in essential gene ORF with dp<3 (18)
	$npos_dplow3_frac{$sample} = sprintf("%.3f",$npos_dplow3{$sample}/2119766);
	print "$sample\t$npos_dplow3_frac{$sample}\tfraction of pos in E orf with dp<3\n";


	# output query gene bed file
	my @tmpquery = split(/\-/,$querygene);
	foreach my $i (@tmpquery) {
		system("awk '\$4==\"$i\"' ../gtf_pombe_ASM294v1_18_noSPBC3F6.03_ORF.bed >> $ibam.querygene.bed");
	}
	
	my $tmp_querylength = `awk '{a+=\$3-\$2}END{print a}' $ibam.querygene.bed | tr '\n' ' ' | sed 's/ //g'`;	
	print "total query CDS length\t$tmp_querylength\n";
	system("samtools depth -b $ibam.querygene.bed $ibam > $ibam.querygene_dpeth.txt");
	my $tmp_totalquerydepth = `awk '{sum+=\$3}END{print sum}' $ibam.querygene_dpeth.txt | tr '\n' ' ' | sed 's/ //g'`;
	
	# avg read depth of the query gene (19)
	$avg_querydp{$sample} = sprintf("%.2f",$tmp_totalquerydepth/$tmp_querylength);
	print "$sample\t$avg_querydp{$sample}\t$querygene avg depth\n";

	# percentage of positions in the query gene with dp<3 (20)
	my $tmp_nposquerylow3 = `awk '\$3>=3' $ibam.querygene_dpeth.txt | wc -l | tr '\n' ' ' | sed 's/ //g'`;
	$npos_querylow3_frac{$sample} = sprintf("%.3f",($tmp_querylength-$tmp_nposquerylow3)/$tmp_querylength);
	print "$sample\t$npos_querylow3_frac{$sample}\tpercentage of pos in query with dp<3\n";

}

my %mnng_strain;
my %other_strain;
my %phenotype;
my %loci;

my %frac_del; # new added from Bioneer junction information

open(IN,"<../CBOE_strain_information.txt") || die;
<IN>;
while (<IN>) {
	chomp;
	chop if(/\r$/);
	my @line = split(/\t/);
	$mnng_strain{$line[0]} = $line[1];
	$other_strain{$line[0]} = $line[2];
	$phenotype{$line[0]} = $line[3];
	$loci{$line[0]} = "$line[4]\t$line[5]";
	$frac_del{$line[0]} = $line[9];
}

close IN;




open(OUT,">V2_sequencing_statistic.xls") || die;
print OUT "Sample\t";
print OUT "MNNG-mutagenesized parental strain\t";
print OUT "the other parental strain\t";
print OUT "phenotype selected\t";
print OUT "additional loci selected\t\t";
print OUT "total reads\t";
print OUT "mapped reads\t";
print OUT "fraction of mapped reads\t";
print OUT "total alignment\t";
print OUT "alignment - mapped\t";
print OUT "MT alignment\t";
print OUT "fraction of MT alignment\t";
print OUT "chr alignment\t";
print OUT "fraction of chr alignment\t";
print OUT "non-duplicated reads\t";
print OUT "fraction of non-duplicated reads\t";
print OUT "avg of chr1 after rmdup\t";
print OUT "avg of essential gene ORF after rmdup\t";
print OUT "#. of positon in essential gene ORFs with dp<3\t";
print OUT "fraction of of positon in essential gene ORFs with dp<3\t";
print OUT "avg query gene depth after rmdup\t";
print OUT "fraction of positions in the query gene with dp<3\t";

print OUT "fraction of deleted from Bioneer junction\n";



foreach my $isample (sort @allsamples) {
	print OUT "$isample\t";
	print OUT "$mnng_strain{$isample}\t";
	print OUT "$other_strain{$isample}\t";
	print OUT "$phenotype{$isample}\t";
	print OUT "$loci{$isample}\t";
	print OUT "$total_reads{$isample}\t";
	print OUT "$total_mapped{$isample}\t";
	print OUT "$total_mapped_frac{$isample}\t";
	print OUT "$total_aln{$isample}\t";
	print OUT "$total_aln_mapped{$isample}\t";
	print OUT "$mt_mapped{$isample}\t";
	print OUT "$mt_mapped_frac{$isample}\t";
	print OUT "$chr_mapped{$isample}\t";
	print OUT "$chr_mapped_frac{$isample}\t";
	print OUT "$nondup_reads{$isample}\t";
	print OUT "$nondup_reads_frac{$isample}\t";
	print OUT "$avg_chr1_depth{$isample}\t";
	print OUT "$avg_orf_depth{$isample}\t";
	print OUT "$npos_dplow3{$isample}\t";
	print OUT "$npos_dplow3_frac{$isample}\t";
	print OUT "$avg_querydp{$isample}\t";
	print OUT "$npos_querylow3_frac{$isample}\t";

	print OUT "$frac_del{$isample}\n";
}

close OUT;
