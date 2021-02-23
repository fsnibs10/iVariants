use strict;

my @allsample;
my %total;

my @files = <bamreadcount/*.SNP.bamreadcount>;
foreach my $ifile (@files) {
	print "$ifile\n";

	open(IN,"<$ifile") || die;
    $ifile =~ s#.*/##;

	my ($sample) = $ifile =~ /(\S+)\.SNP/;
	push(@allsample,$sample);
	
	while (<IN>) {
		chomp;
		chop if(/\r$/);
		my @line = split(/\t/);

		for (my $i=5;$i<=8 ;$i++) {
			my @tmp = split(/:/,$line[$i]);
			if ($tmp[0] eq $line[2]) {
				
				my $freq;
				my $depth;
				if($line[3] ne 0 && ($line[3] ne "")){
					$freq = sprintf("%.3f",$tmp[1]/$line[3]);
					$depth = $line[3];
				}else{
					$freq = "NA";
					$depth = "NA";
				}
				$total{"$line[0]\t$line[1]\t$line[2]"}{$sample} = "$freq\t$depth";
				last;
			}
		}
	}
	close IN;

}


open(OUT,">bamreadcount/SNP.bamreadcount.txt") || die;
print OUT "chr\tpos\tref";
foreach my $isample (sort @allsample) {
	print OUT "\t$isample.freq\t$isample.depth";
}
print OUT "\n";

foreach my $isite (keys %total) {
	print OUT "$isite";
	foreach my $isample (sort @allsample) {
		if (exists($total{$isite}{$isample})) {
			print OUT "\t$total{$isite}{$isample}";
		}else{
			print OUT "\tNA\tNA";
		}
		
	}
	print OUT "\n";
}
close OUT;
