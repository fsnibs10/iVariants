use strict;
use Getopt::Long;

my $anno;
my $input;
my $output;
GetOptions ("anno|a=s" => \$anno,    # sys2producct: 3 columns
            "input|i=s"   => \$input,      # variant intersectBed gene CDS 
            "output|o=s"  => \$output)     # variant to gene information
or die("Usage: $0\n");

print "gene annotation: $anno\n";
print "input: $input\n";
print "output: $output\n";

my %name;
my %product;
open(IN,"<$anno") || die;
while (<IN>){
    chomp;
    chop if(/\r$/);
    my @line = split(/\t/);
    $name{$line[0]} = $line[1];
    $product{$line[0]} = $line[2];
}
close IN;

my %allname;
my %allanno;
my %allgene;
open(IN,"<$input") || die;
while(<IN>){
    chomp;
    chop if(/\r$/);
    my @line = split(/\t/);
    if($line[6] eq "."){
        $allname{"$line[0]\t$line[2]"} = "";
        $allgene{"$line[0]\t$line[2]"} = "";
        $allanno{"$line[0]\t$line[2]"} = "";
    }else{
        my $igene = $line[6];
        if(exists($allname{"$line[0]\t$line[2]"})){
            $allname{"$line[0]\t$line[2]"} .= "|$name{$igene}";
            $allgene{"$line[0]\t$line[2]"} .= "|$igene";
            $allanno{"$line[0]\t$line[2]"} .= "|$product{$igene}";
        }else{
            $allname{"$line[0]\t$line[2]"} = "$name{$igene}";
            $allgene{"$line[0]\t$line[2]"} = "$igene";
            $allanno{"$line[0]\t$line[2]"} = "$product{$igene}";
        }

    }

}
close IN;

open(OUT,">$output") || die;
foreach my $i (keys %allgene){
    print OUT "$i\t$allgene{$i}\t$allname{$i}\t$allanno{$i}\n";
}

close OUT;



