use strict;
use Getopt::Long;

my ($input,$output,$cds,$ev);

GetOptions(
"input|i=s" => \$input,  # input file
"output|o=s" => \$output, # output file
"cds|c=s" => \$cds,  # cds txt file
"ev|e=s" => \$ev # hayles_E_or_V
) or die("usage: $0");

my %allev;    # essential gene annotation
open(IN,"<$ev") || die;
<IN>;
while (<IN>){
    chomp;
    chop if(/\r$/);
    my @line = split(/\t/);
    $allev{$line[0]} = $line[1];
}
close IN;

my %start;   # cds range and strand
my %end;
my %strand;
my %exonlong;
my %cdslong;
open(IN,"<$cds") || die;
while (<IN>){
    chomp;
    chop if(/\r$/);
    my @line = split(/\t/);

    $start{$line[4]} = $line[1];
    $end{$line[4]} = $line[2];
    $strand{$line[4]} = $line[3];
    $exonlong{$line[4]} = $line[6];
    $cdslong{$line[4]} = $line[5];
}
close IN;

open(IN,"<$input") || die;
open(OUT,">$output") || die;
while (<IN>){
    chomp;
    chop if(/\r$/);
    my @line = split(/\t/);
    print OUT "$_";
    if($line[2] eq ""){
        print OUT "\t\t\t\t\t\t";
    }else{  

        if($line[2] !~ /\|/){
            print OUT "\t$allev{$line[2]}";
            print OUT "\t$start{$line[2]}";
            print OUT "\t$end{$line[2]}";
            print OUT "\t$strand{$line[2]}";
            print OUT "\t$exonlong{$line[2]}";
            print OUT "\t$cdslong{$line[2]}";
        }else{
            my @gene = split(/\|/,$line[2]);
            #my ($iev,$istart,$iend,$istrand,$iexon,$icds);
            my $iev;
            my $istart;
            my $iend;
            my $istrand;
            my $iexon;
            my $icds;
            for(my $n=0; $n<=$#gene; $n++){
                $iev .= $allev{$gene[$n]}."|";
                $istart .= $start{$gene[$n]}."|";
                $iend .= $end{$gene[$n]}."|";
                $istrand .= $strand{$gene[$n]}."|";
                $iexon .= $exonlong{$gene[$n]}."|";
                $icds .= $cdslong{$gene[$n]}."|";

            }
            print OUT "\t$iev";
            print OUT "\t$istart";
            print OUT "\t$iend";
            print OUT "\t$istrand";
            print OUT "\t$iexon";
            print OUT "\t$icds";
        }


    }

    print OUT "\n";    
}
close IN;
close OUT;





