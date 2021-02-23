use strict;

my $coor1=5097113;
my $coor2=5097439;


my @files = <mapping/*.bwa_rmdup.sorted.bam>;

foreach my $ifile (sort @files) {
	print "$ifile\n";
	my ($sample) = $ifile =~ /(\S+)\.bwa/;
	system("perl compute_everybin_metircs.pl $ifile $sample.bin_avg_depth.xls");
	print "perl compute_everybin_metircs.pl $ifile $sample.bin_avg_depth.xls\n";
}


system("Rscript scatterplot_bin_avg_depth_Rscript.R $coor1 $coor2");
print "Rscript scatterplot_bin_avg_depth_Rscript.R $coor1 $coor2\n";

