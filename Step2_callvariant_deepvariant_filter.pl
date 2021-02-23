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

        next if($line[6] ne "PASS");  # filter on-PASS sites
        next if($line[3] =~ /\,/ || $line[4] =~ /\,/);   # filter multi allele
        my @tmp = split(/:/,$line[9]);
        my $depth = $tmp[2];
        next if($depth < 5); # filter depth < 5

        if(length($line[3]) == length($line[4]) && length($line[3]) == 1){
            print SNP "$_\n";
        }else{
            print IND "$_\n";
        }
        

    }
}
close IN;
close SNP;
close IND;
