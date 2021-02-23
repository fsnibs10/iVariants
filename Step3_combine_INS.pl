use strict;

my @snpfile = <variants/*.indel.allepre.Eff.vcf>;

my %allsite;

my %allsample;
my %allmethod;

foreach my $ifile (sort @snpfile){
    print "------------$ifile------------\n";
    open(IN,"<$ifile") || die;

    $ifile =~ s#.*/##;

    my ($sample) = $ifile =~ /^(\S+?)\./;
    print "$sample\n";
    $allsample{$sample} = 1;

    my ($method) = $ifile =~ /\.(\S+?)\./;
    print "$method\n";
    $allmethod{$method} = 1;

   
    while (<IN>){
        chomp;
        chop if(/\r$/);
        next if(/^\#/);
        my @line = split(/\t/);
        if(length($line[3]) < length($line[4])){   # insertion site
            $allsite{"$line[0]\t$line[1]\t$line[3]\t$line[4]"}{$sample}{$method} = 1;
        }
        
        
    }
    close IN;
}


open(OUT,">combine/INS.combine.txt") || die;
print OUT "chr\tpos\tref\talt\tmethod";
foreach my $isample (sort keys %allsample){
    print OUT "\t$isample";
}
print OUT "\ttype\n";

foreach my $isite (keys %allsite){
    print OUT "$isite";

    my $imark;
    my $snpline;
    foreach my $isample (sort keys %allsample){
        if(exists($allsite{$isite}{$isample}{"samtools"}) && exists($allsite{$isite}{$isample}{"deepvariant"})){
            $imark .= "B";
            $snpline .= "\t1";
        }elsif(exists($allsite{$isite}{$isample}{"samtools"})){
            $imark .= "S";
            $snpline .= "\t1";
        }elsif(exists($allsite{$isite}{$isample}{"deepvariant"})){
            $imark .= "D";
            $snpline .= "\t1";
        }else{
            $imark .= "N";
            $snpline .= "\t0";
        }
    }
    print OUT "\t$imark$snpline\tINS\n";
    

}

close OUT;

