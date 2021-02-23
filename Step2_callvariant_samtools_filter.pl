use strict;

my $input = $ARGV[0];
my $snpout = $ARGV[1];
my $indelout = $ARGV[2];

open(IN,"<$input") || die;
open(SNP,">$snpout") || die;
open(IND,">$indelout") || die;
while (<IN>){
    chomp;
    chop if(/\r$/);
    if(/^\#/){
        print SNP "$_\n";
        print IND "$_\n";
    }else{
        my @line = split(/\t/);

        next if($line[3] =~ /\,/ || $line[4] =~ /\,/);   # filter multi allele

        my $depth;
        if($line[7] =~ /DP=(\d+)/){
            $depth = $1;
        }
        next if($depth < 5); # filter depth < 5;

        if($line[7] =~ /INDEL/){
            print IND "$_\n";
        }else{
            print SNP "$_\n";
        }
        
    }
}
close IN;
close SNP;
close IND;
