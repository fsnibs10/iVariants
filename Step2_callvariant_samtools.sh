BASE=`pwd`      # current folder
INPUT_DIR="${BASE}/mapping"     # need modified
OUTPUT_DIR="${BASE}/variants"     #need modified
mkdir -p "${OUTPUT_DIR}" ## if exist, don't need to mkdir

bcftools_root="/home/suofang/Software/bcftools-1.9"
snpEff_root="/home/suofang/Software/snpEff_v4_3t/snpEff"

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

     ############################################
     # Samtools

     echo "Start Samtools ..."
     date
     
     $bcftools_root/bcftools mpileup -a FORMAT/DP4 -Ou -f ${INPUT_DIR}/${REF} ${INPUT_DIR}/${BAM} | $bcftools_root/bcftools call -f GQ -mv -Ov -o ${OUTPUT_DIR}/${outname}.samtools.vcf
    
     # only reomve depth < 5 or multiallelic sites
     perl Step2_callvariant_samtools_filter.pl ${OUTPUT_DIR}/${outname}.samtools.vcf ${OUTPUT_DIR}/${outname}.samtools.filter.snp.vcf ${OUTPUT_DIR}/${outname}.samtools.filter.indel.vcf
     vcfallelicprimitives ${OUTPUT_DIR}/${outname}.samtools.filter.indel.vcf > ${OUTPUT_DIR}/${outname}.samtools.filter.indel.allepre.vcf

     # Run snpEff
     java -jar $snpEff_root/snpEff.jar ann -no-utr -no-downstream -no-upstream -no-intergenic SpombeV248 ${OUTPUT_DIR}/${outname}.samtools.filter.snp.vcf > ${OUTPUT_DIR}/${outname}.samtools.filter.snp.Eff.vcf
     java -jar $snpEff_root/snpEff.jar ann -no-utr -no-downstream -no-upstream -no-intergenic SpombeV248 ${OUTPUT_DIR}/${outname}.samtools.filter.indel.allepre.vcf > ${OUTPUT_DIR}/${outname}.samtools.filter.indel.allepre.Eff.vcf

     date

done < config.list

echo "Step2 samtools finished"

