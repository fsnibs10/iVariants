use strict;

my @files = <variants/*.Eff.vcf>;

my %allsite;

foreach my $ifile (sort @files){
    open(IN,"<$ifile") || die;
    while (<IN>){
        chomp;
        chop if(/\r$/);
        next if(/^\#/);
        my @line = split(/\t/);
        next if($line[7] eq ".");  # in deepvariant, no info field
        
        my ($tmpanno) = $line[7] =~ /ANN\=(.*)/;
        $allsite{"$line[0]\t$line[1]\t$line[3]\t$line[4]"} = $tmpanno;
    }

    close IN;
}

open(OUT,">snpeff/all_variant_snpEff.txt") || die;
print OUT "chr\tcoor\tref\talt\tmark_lof\tmark_nosilent";
print OUT "\tAllele\tAnnotation\tPutative_impact\tGene Name\tGene ID\tFeature type\tFeature ID";
print OUT "\tTranscript biotype\tRank(total)\tHGVS.c\tHGVS.p\tcDNA_position \/ cDNA_len";
print OUT "\tCDS_position \/ CDS_len";
print OUT "\tProtein_position \/ Protein_len";
print OUT "\tDistance to feature";
print OUT "\tErrors, Warnings or Information messages\n";

foreach my $isite (keys %allsite){
    print OUT "$isite";

        my $lof_mark;
        my $nosilent_mark;
        my $ann;

        my @tmpanno = split(/\,/,$allsite{$isite});

        for(my $n=0; $n<=$#tmpanno; $n++){
            my @cc = split(/\|/,$tmpanno[$n]);

            if ($cc[1] eq "missense_variant"){
                $nosilent_mark = "nosilent";
            }
            if($cc[1] =~ /frameshift/ || $cc[1] =~ /lost/ || $cc[1] =~ /splice/ || $cc[1] =~ /inframe/ || $cc[1] =~ /stop/){
                $nosilent_mark = "nosilent";
                $lof_mark = "lof";
            }

            for(my $j = 0; $j<=15; $j++){
                $ann .= "\t$cc[$j]";
            }
        }
    print OUT "\t$lof_mark\t$nosilent_mark$ann\n";
}


close OUT;

