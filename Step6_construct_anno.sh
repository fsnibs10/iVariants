BASE=`pwd`      # current folder
OUTPUT_DIR="${BASE}/gene"     #need modified
mkdir -p "${OUTPUT_DIR}" ## if exist, don't need to mkdir

anno="/data/suofang/CBOE2/annotation_file"
evfile=${anno}/f_haylesE_V_info.txt
nameanno=${anno}/f_sysID2product_20200805.tidy.txt
cdstxt=${anno}/f_Spombe_20200804_cds.txt
cdsbed=${anno}/f_Spombe_20200804_cds.sort.noRNA.bed

# (1) which gene is variant located
intersectBed -a combine/allsite.bed -b $cdsbed -wao > gene/variants_intersect_gene.txt
perl Step6_parse_variant_intersect_gene.pl -a $nameanno -i gene/variants_intersect_gene.txt -o gene/variants_gene_determination.txt

# (2) add other annotation based on gene
perl Step6_add_CDS_info.pl -i gene/variants_gene_determination.txt -o gene/variants_gene_CDS_ev_info.txt -c ../annotation_file/f_Spombe_20200804_cds.txt -e ../annotation_file/f_haylesE_V_info.txt

echo "------------Step6 done!"
