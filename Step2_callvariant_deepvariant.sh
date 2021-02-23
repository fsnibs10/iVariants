BASE=`pwd`      # current folder
INPUT_DIR="${BASE}/mapping"     # need modified
OUTPUT_DIR="${BASE}/variants"     #need modified
mkdir -p "${OUTPUT_DIR}" ## if exist, don't need to mkdir

REF="pombe_ASM294v1_18_toplevel.fasta"

if [ ! -f "$INPUT_DIR/pombe_ASM294v1_18_toplevel.fasta.bwt" ]
then
    cp /data/suofang/CBOE2/pombe_ASM294v1_18_toplevel.* $INPUT_DIR
fi


while read fastq1 fastq2 outname
do 
     echo "============="
     echo "$outname"
     echo "============="

     BAM="${outname}.bwa_rmdup.sorted.bam"

     #############################################
     # deepvariant

     echo "Start deepvariant ..."
     date
     BIN_VERSION="0.10.0"
     OUTPUT_VCF="${outname}.deepvariant.vcf.gz"
     OUTPUT_GVCF="${outname}.deepvariant.g.vcf.gz"

     # I amd docker user, I don't need sudo
     docker run \
     -v "${INPUT_DIR}":"/input" \
     -v "${OUTPUT_DIR}:/output" \
     google/deepvariant:"${BIN_VERSION}" \
     /opt/deepvariant/bin/run_deepvariant \
     --model_type=WGS \
     --ref=/input/$REF \
     --reads=/input/$BAM \
     --output_vcf=/output/$OUTPUT_VCF \
     --output_gvcf=/output/$OUTPUT_GVCF \
     --num_shards=8

     # --model_type=WGS \ **Replace this string with exactly one of the following [WGS,WES,PACBIO]**
     # --num_shards=1  **How many cores the `make_examples` step uses. Change it to the number of CPU cores you have.**
     #  --regions "chr20:10,000,000-10,010,000" \
     gzip -d $OUTPUT_DIR/${outname}.deepvariant.vcf.gz
     
     
     perl Step2_callvariant_deepvariant_filter.pl $OUTPUT_DIR/${outname}.deepvariant.vcf $OUTPUT_DIR/${outname}.deepvariant.filter.snp.vcf $OUTPUT_DIR/${outname}.deepvariant.filter.indel.vcf
     vcfallelicprimitives $OUTPUT_DIR/${outname}.deepvariant.filter.indel.vcf > $OUTPUT_DIR/${outname}.deepvariant.filter.indel.allepre.vcf
     
     # Run snpEff
     snpEff_root="/home/suofang/Software/snpEff_v4_3t/snpEff"
     java -jar $snpEff_root/snpEff.jar ann -no-utr -no-downstream -no-upstream -no-intergenic SpombeV248 $OUTPUT_DIR/${outname}.deepvariant.filter.snp.vcf > $OUTPUT_DIR/${outname}.deepvariant.filter.snp.Eff.vcf
     java -jar $snpEff_root/snpEff.jar ann -no-utr -no-downstream -no-upstream -no-intergenic SpombeV248 $OUTPUT_DIR/${outname}.deepvariant.filter.indel.allepre.vcf > $OUTPUT_DIR/${outname}.deepvariant.filter.indel.allepre.Eff.vcf

     date

done < config.list

echo "Step2 deepvariant finished"

