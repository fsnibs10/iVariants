use strict;

my %total;

my @delete_file = <bamreadcount/*.DEL.bamreadcount>;

my @allstrain;

foreach my $ifile (sort @delete_file){
	open(IN,"<$ifile") || die;
	
	print "$ifile\n";
	$ifile =~ s#.*/##;

	my ($sample) = $ifile =~ /(\S+)\.DEL/;
	push(@allstrain,$sample);
	
	while (<IN>){
		chomp;
		chop if(/\r$/);
		my @line = split(/\t/);
		
		
		for (my $i=5;$i<=8 ;$i++) {
			my @tmp = split(/:/,$line[$i]);
			if ($tmp[0] eq $line[2]) {
				
				$total{"$line[0]\t$line[1]"}{$sample} = "$tmp[1]\t$line[3]";
				last;
			}
		}
		
	}
	
	close IN;
}




open(OUT,">bamreadcount/DEL.bamreadcount.txt") || die;
open(IN,"<combine/DEL.combine.sort.txt") || die;
<IN>;
print OUT "chr\tpos\tref";

foreach my $i (sort @allstrain){
	print OUT "\t$i.freq\t$i.depth";
}

print OUT "\n";


while (<IN>){
	chomp;
	chop if(/\r$/);
	my @line = split(/\t/);
	
	my $tmp = "$line[0]\t$line[1]";
	print OUT "$line[0]\t$line[1]\t$line[2]";
	
	my $nextcoor = $line[1]+1;
	my $tmpnext = "$line[0]\t$nextcoor";
	
	foreach my $i (sort @allstrain){
	
		my @current = split(/\t/,$total{$tmp}{$i});
		my @next = split(/\t/,$total{$tmpnext}{$i});
		
		
	
		if (exists($total{$tmp}{$i}) && $current[1] != 0){
			my $depth = $current[1];
			my $freq = sprintf("%.3f",$next[0]/$depth);
			
			print OUT "\t$freq\t$depth";
		}else{
			print OUT "\tNA\tNA";
		}
	
	}
	
	print OUT "\n";
	
	
}
close IN;
close OUT;
