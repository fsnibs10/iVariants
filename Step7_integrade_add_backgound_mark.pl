use strict;

my %mark;
open(IN,"<../annotation_file/background_total.txt") || die;
while (<IN>){
    chomp;
    chop if(/\r$/);
    my @line = split(/\t/);
    $mark{"$line[0]\t$line[1]"} .= $line[4]."|" ;
}
close IN;

open(IN,"<integrade/integrade2_candidate_added.txt") || die;
open(OUT,">integrade/integrade3_background_added.txt") || die;
my $title = <IN>;
print OUT "background\t$title";
chomp $title;
chop $title if($title =~ /\r$/);
my @title = split(/\t/,$title);
my $chrcol;
my $sitecol;


for(my $n=0; $n<=$#title; $n++){
    if($title[$n] eq "chr"){
        $chrcol = $n;
    }
    if($title[$n] eq "pos"){
        $sitecol = $n;
    }
}
while (<IN>){
    chomp;
    chop if(/\r$/);
    my @line = split(/\t/);
    my $ichr = $line[$chrcol];
    my $ipos = $line[$sitecol];
    my $tmp = "$ichr\t$ipos";
    if(exists($mark{$tmp})){
        print OUT "$mark{$tmp}\t$_\n";
    }else{
        print OUT "new\t$_\n";
    }

}
close IN;
close OUT;
