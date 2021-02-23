use strict;


my $markcol;  # which column is the mark of nosilent 
my $typecol;  # which column is SNP or indel

my @freqcol;
my @freqname;


open(IN,"<integrade/integrade1_counts_variants_snpeff.txt") || die;
my $title = <IN>;
chomp $title;
chop $title if($title =~ /\r$/);
my @title = split(/\t/,$title);
for(my $n=0;$n<=$#title; $n++){
    if($title[$n] =~ /\.freq$/){
        push(@freqcol,$n);
        push(@freqname,$title[$n]);
    }
    if($title[$n] eq "mark_nosilent"){
        $markcol = $n;  
    }
    if($title[$n] eq "type"){
        $typecol = $n;  
    }
}

print "mark_nosilent column: $markcol\n";
print "column of freq: ",@freqcol,"\n";

open(OUT,">integrade/integrade2_candidate_added.txt") || die;
for (my $i=0;$i<=$#freqname; $i++){
    print OUT "$freqname[$i].candidate\t";
}
print OUT "$title\n";

while (<IN>){
    chomp;
    chop if(/\r$/);
    my @line = split(/\t/);
    my $candiate;
    for(my $j = 0 ; $j <= $#freqcol; $j++){
        if($line[$typecol] eq "SNP"){  # snp case
            if($line[$freqcol[$j]] < 0.15 && ($line[$markcol] eq "nosilent") && ($line[$freqcol[$j]] ne "NA")){
                $candiate .= "candidate\t";
            }else{
                $candiate .= "\t";
            }
        }else{  # indel case
            if($line[$freqcol[$j]] < 0.25 && ($line[$markcol] eq "nosilent") && ($line[$freqcol[$j]] ne "NA")){
                $candiate .= "candidate\t";
            }else{
                $candiate .= "\t";
            }            

        }
    }
    print OUT "$candiate$_\n";
}
close IN;
close OUT;