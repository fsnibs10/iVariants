use strict;
use Statistics::Descriptive;


my $bamfile = $ARGV[0];
my $output = $ARGV[1];

my @allbinavg;
my %allbin_avg;
my %allbin_zscore;


open(IN,"<../BinSize1000bp_step500bp.bed") || die;
while (<IN>) {
	chomp;
	chop if(/\r$/);
	my @line = split(/\t/);
	my $chr = $line[0];
	my $leftcoor = $line[1]+1;
	my $rightcoor = $line[2];
	my $distance = $line[2]-$line[1];
	my $tmpstr = $chr.":".$leftcoor."-".$rightcoor;
	#print "$tmpstr\n";
	my $depthsum = `samtools depth -r $tmpstr $bamfile | awk '{sum+=\$3}END{print sum}' | tr -d "\n"`;
	#print $depthsum,"\n";

	if ($depthsum ne "" && $depthsum =~ /\d+/) {
		$allbin_avg{$tmpstr} = $depthsum/$distance;
		push(@allbinavg,$allbin_avg{$tmpstr});
	}else{
		$allbin_avg{$tmpstr} = 0;
		print "$_\n";
		push(@allbinavg,0)
	}	
}
close IN;



print scalar(@allbinavg);

my $bin_statistic = Statistics::Descriptive::Full->new();

$bin_statistic->add_data(@allbinavg);
my $bin_median = $bin_statistic->median();

my $bin_Q1 = $bin_statistic->percentile(25);
my $bin_Q3 = $bin_statistic->percentile(75);
my $niqr = ($bin_Q3-$bin_Q1)/1.349;


my $bin_per0 = $bin_statistic->min();
my $bin_per50 = $bin_statistic->percentile(50);
my $bin_per100 = $bin_statistic->percentile(100);

open(OUT,">$output.bin_avg_depth.xls") || die;
print OUT "abs coor\tmin:$bin_per0\tQ1:$bin_Q1\tQ2:$bin_per50\tQ3:$bin_Q3\tmax:$bin_per100\n";
foreach my $ibin (sort keys %allbin_avg) {
	my ($chr) = $ibin =~ /(\S+):/;
	my ($left) = $ibin =~ /:(\d+)\-/;
	my ($right) = $ibin =~ /\-(\d+)/;
	$allbin_zscore{$ibin} = ($allbin_avg{$ibin} - $bin_median)/$niqr;
	my $abscoor;
	if ($chr eq "I") {
		$abscoor = $left;
	}elsif($chr eq "II"){
		$abscoor = $left+5579133;
	}elsif($chr eq "III"){
		$abscoor = $left+5579133+4539804; 
	}
	print OUT "$abscoor\t$chr\t$left\t$right\t$allbin_avg{$ibin}\t$allbin_zscore{$ibin}\n";
	
}
close OUT;