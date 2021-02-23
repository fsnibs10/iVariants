BASE=`pwd`      # current folder
OUTPUT_DIR="${BASE}/integrade"     #need modified
mkdir -p "${OUTPUT_DIR}" ## if exist, don't need to mkdir

# sample number
n_sample=`wc -l config.list | cut -f 1 -d ' ' | tr -d '\n'`

# integrae bamreadcount,snpeff, gene annotation by combined variants
variants="combine/all.combine.sort.txt";
snpcount="bamreadcount/SNP.bamreadcount.txt"
delcount="bamreadcount/DEL.bamreadcount.txt"
inscount="bamreadcount/INS.bamreadcount.txt"
snpeff="snpeff/all_variant_snpEff.txt"
geneinfo="gene/variants_gene_CDS_ev_info.txt"

perl Step7_integrade_full_list.pl $variants $snpcount $delcount $inscount $snpeff $geneinfo $n_sample
perl Step7_integrade_add_candidate.pl
perl Step7_integrade_add_backgound_mark.pl

echo "--------Step7 done!"
