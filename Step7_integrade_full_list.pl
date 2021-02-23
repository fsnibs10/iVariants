use strict;

# variants="combine/all.combine.sort.txt";
# snpcount="bamreadcount/SNP.bamreadcount.txt"
# delcount="bamreadcount/DEL.bamreadcount.txt"
# inscount="bamreadcount/INS.bamreadcount.txt"
# snpeff="snpeff/all_variant_snpEff.txt"
# geneinfo="gene/variants_gene_CDS_ev_info.txt"

my $variants = $ARGV[0];
my $snpcount = $ARGV[1];
my $delcount = $ARGV[2];
my $inscount = $ARGV[3];
my $snpeff = $ARGV[4];
my $geneinfo = $ARGV[5];
my $n_sample = $ARGV[6];

##########################gene info
my $title_geneinfo= "gene\tname\tanno\tessentiality\tCDS start\tCDS end\tstrand\tCDS length exclude intorn\tCDS length exclude exon";

my %h_geneinfo;
open(IN,"<$geneinfo") || die;
while (<IN>){
    chomp;
    chop if(/\r$/);
    my @line = split(/\t/);
    my $tmp = join("\t",@line[2..$#line]);
    $h_geneinfo{"$line[0]\t$line[1]"} = $tmp;

}
close IN;

##########################snpEff
my %h_snpeff;
open(IN,"<$snpeff") || die;

my $ititle = <IN>;
chomp $ititle;
chop $ititle if($ititle =~ /\r$/);
my @ititle = split(/\t/,$ititle);
my $title_snpeff=join("\t",@ititle[4..$#ititle]); 

while (<IN>){
    chomp;
    chop if(/\r$/);
    my @line = split(/\t/);
    my $tmp = join("\t",@line[4..$#line]);
    $h_snpeff{"$line[0]\t$line[1]\t$line[2]\t$line[3]"} = $tmp;

}
close IN;

##########################snpcount
my %h_snpcount;
open(IN,"<$snpcount") || die;

my $ititle = <IN>;
chomp $ititle;
chop $ititle if($ititle =~ /\r$/);
my @ititle = split(/\t/,$ititle);
my $title_count=join("\t",@ititle[3..$#ititle]); 

while (<IN>){
    chomp;
    chop if(/\r$/);
    my @line = split(/\t/);
    my $tmp = join("\t",@line[3..$#line]);
    if($tmp eq ""){  # avoid case :I^I10859^IGTT^I^I^I^I^I^I^I^I^I^I^I^I^I^I^I^I$
        for(my $n=1;$n<=2*$n_sample-1;$n++){
            $tmp .= "\t";
        }        
    }
    $h_snpcount{"$line[0]\t$line[1]"} = $tmp;

}
close IN;

##########################inscount
my %h_inscount;
open(IN,"<$inscount") || die;
<IN>;
while (<IN>){
    chomp;
    chop if(/\r$/);
    my @line = split(/\t/);
    my $tmp = join("\t",@line[3..$#line]);

    if($tmp eq ""){
        for(my $n=1;$n<=2*$n_sample-1;$n++){
            $tmp .= "\t";
        }        
    }

    $h_inscount{"$line[0]\t$line[1]"} = $tmp;

}
close IN;

##########################del count
my %h_delcount;
open(IN,"<$delcount") || die;
<IN>;
while (<IN>){
    chomp;
    chop if(/\r$/);
    my @line = split(/\t/);
    my $tmp = join("\t",@line[3..$#line]);

    if($tmp eq ""){
        for(my $n=1;$n<=2*$n_sample-1;$n++){
            $tmp .= "\t";
        }        
    }
    
    $h_delcount{"$line[0]\t$line[1]"} = $tmp;

}
close IN;

open(OUT,">integrade/integrade1_counts_variants_snpeff.txt") || die;
open(IN,"<$variants") || die;

my $title_variants = <IN>;
chomp $title_variants;
chop $title_variants if($title_variants =~ /\r$/);
print OUT "$title_count\t$title_variants\t$title_geneinfo\t$title_snpeff\n";

while (<IN>){
    chomp;
    chop if(/\r$/);
    my @line = split(/\t/);

    my $icount;
    if($line[$#line] eq "SNP"){
        if(exists($h_snpcount{"$line[0]\t$line[1]"})){
            $icount = $h_snpcount{"$line[0]\t$line[1]"};
        }else{
            for(my $n=1;$n<=$n_sample;$n++){
                $icount .= "\t";
            } 
        }
        
    }elsif($line[$#line] eq "INS"){
        if(exists($h_inscount{"$line[0]\t$line[1]"})){
            $icount = $h_inscount{"$line[0]\t$line[1]"};
        }else{
            for(my $n=1;$n<=$n_sample;$n++){
                $icount .= "\t";
            }
        }
        
    }elsif($line[$#line] eq "DEL"){
        if(exists($h_delcount{"$line[0]\t$line[1]"})){
            $icount = $h_delcount{"$line[0]\t$line[1]"};
        }else{
            for(my $n=1;$n<=$n_sample;$n++){
                $icount .= "\t";
            }
        }
        
    }

    my $igeneinfo;
    if($h_geneinfo{"$line[0]\t$line[1]"} =~/SP/){
        $igeneinfo = $h_geneinfo{"$line[0]\t$line[1]"};
        #print "$igeneinfo\n";
    }else{
        $igeneinfo = "\t\t\t\t\t\t\t\t";
    }

    my $isnpeff = $h_snpeff{"$line[0]\t$line[1]\t$line[2]\t$line[3]"};

    print OUT "$icount\t$_\t$igeneinfo\t$isnpeff\n";
}

close IN;
close OUT;

