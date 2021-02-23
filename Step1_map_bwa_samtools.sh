############### build reference kinds of index
#bwa index $ref
#samtools faidx $ref
#tmpname=${ref%.*} #去除扩展名
#java -jar /home/suofang/Software/picard_2.23.3.jar CreateSequenceDictionary REFERENCE=$ref OUTPUT=$tmpname.dict

# for current BOE project, only pombe reference is used. The index files are build in advance.

ref="../pombe_ASM294v1_18_toplevel.fasta"

# store all result for this step
if [ ! -d "mapping" ]
then
     mkdir mapping
fi

while read fastq1 fastq2 sample
do
    echo "------------$sample------------"
    ##################################################                 
    # bwa mem mapping

    ID=$sample
    LB=$ID
    PL=ILLUMINA
    SM=$ID

    readgroup="@RG\tID:"$ID"\tLB:"$LB"\tPL:"$PL"\tSM:"$SM
    bwa mem -t 6 -M -R $readgroup $ref $fastq1 $fastq2 > mapping/${sample}.bwa.sam

    echo "***Sam=>Bam=>Sorted=>Index"
    samtools view -@ 6 -bS -o mapping/${sample}.bwa.bam mapping/${sample}.bwa.sam
    samtools sort -@ 6 -O bam -o mapping/${sample}.bwa.sorted.bam mapping/${sample}.bwa.bam
    samtools index mapping/${sample}.bwa.sorted.bam
    rm mapping/${sample}.bwa.sam
    rm mapping/${sample}.bwa.bam

    #echo "***Samtools rmdup"
    samtools rmdup mapping/${sample}.bwa.sorted.bam mapping/${sample}.bwa_rmdup.sorted.bam 2>mapping/${sample}.bwa.rmdup
    samtools index mapping/${sample}.bwa_rmdup.sorted.bam


done < config.list

echo "Step1: mapping finished"
