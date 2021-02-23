use strict;

my %total;

my @insert_file = <bamreadcount/*.INS.bamreadcount>;

my @allstrain;

foreach my $ifile (sort @insert_file){
	open(IN,"<$ifile") || die;
	
	print "$ifile\n";

    $ifile =~ s#.*/##;
	
	my ($sample) = $ifile =~ /(\S+)\.INS/;
	push(@allstrain,$sample);
	
	while (<IN>){
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
				$total{"$line[0]\t$line[1]"}{$sample} = "$freq\t$depth";
				last;
			}
		}



		
	}
	
	close IN;
}


open(OUT,">bamreadcount/INS.bamreadcount.txt") || die;
print OUT "chr\tpos\tref";
foreach my $i (sort @allstrain){
	print OUT "\t$i.freq\t$i.depth";
}
print OUT "\n";

open(IN,"<combine/INS.combine.sort.txt") || die;
<IN>;

while (<IN>){
	chomp;
	chop if(/\r$/);
	my @line = split(/\t/);
	
	my $tmp = "$line[0]\t$line[1]";
	print OUT "$line[0]\t$line[1]\t$line[2]";
	foreach my $i (sort @allstrain){
	
		if (exists($total{$tmp}{$i})){
			print OUT "\t$total{$tmp}{$i}";
		}else{
			print OUT "\tNA\tNA";
		}
	
	}
	
	print OUT "\n";
	
	
}
close IN;
close OUT;
