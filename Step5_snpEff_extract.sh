BASE=`pwd`      # current folder
OUTPUT_DIR="${BASE}/snpeff"     #need modified
mkdir -p "${OUTPUT_DIR}" ## if exist, don't need to mkdir

perl Step5_extract_snpEff_from_vcf.pl

echo "-------------Step5 done!"

