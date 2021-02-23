BASE=`pwd`      # current folder
OUTPUT_DIR="${BASE}/bamreadcount"     #need modified
mkdir -p "${OUTPUT_DIR}" ## if exist, don't need to mkdir

ref="${BASE}/mapping/pombe_ASM294v1_18_toplevel.fasta"

while read fastq1 fastq2 sample
do
	echo $sample;

    ibam="${BASE}/mapping/${sample}.bwa_rmdup.sorted.bam"

    # for SNP,INS,DEL
	bam-readcount -f $ref -q 60 -b 20 -l combine/SNP.combine.site.txt $ibam > bamreadcount/${sample}.SNP.bamreadcount
    bam-readcount -f $ref  -q 60 -i -b 20 -l combine/INS.combine.site.txt $ibam > bamreadcount/${sample}.INS.bamreadcount
    bam-readcount -f $ref  -q 60 -b 20 -l combine/DEL.combine.site.txt $ibam > bamreadcount/${sample}.DEL.bamreadcount


done < config.list


# tidy SNP,INS,DEL
echo "tidy SNP bamreadcount"
perl Step4_bamreadcount_tidy_SNP.pl

echo "tidy INS bamreadcount"
perl Step4_bamreadcount_tidy_INS.pl

echo "tidy DEL bamreadcount"
perl Step4_bamreadcount_tidy_DEL.pl

echo "---------------Step4 done!"

