BASE=`pwd`      # current folder
OUTPUT_DIR="${BASE}/combine"     #need modified
mkdir -p "${OUTPUT_DIR}" ## if exist, don't need to mkdir

########### combine all SNP #############

# input: variant all filter SNP; output is combine/SNP.combine.txt
perl Step3_combine_SNP.pl 

# sort with title keep 
awk 'NR==1; NR > 1 {print $0 | "sort -k1,1 -k2,2n"}' ${OUTPUT_DIR}/SNP.combine.txt > ${OUTPUT_DIR}/SNP.combine.sort.txt

# only extract the first two column for the bamreadcount input
awk 'NR>1 {OFS="\t";print $1,$2,$2}' ${OUTPUT_DIR}/SNP.combine.sort.txt > ${OUTPUT_DIR}/SNP.combine.site.txt

############# combine all deletion ############
perl Step3_combine_DEL.pl
awk 'NR==1; NR > 1 {print $0 | "sort -k1,1 -k2,2n"}' ${OUTPUT_DIR}/DEL.combine.txt > ${OUTPUT_DIR}/DEL.combine.sort.txt
awk 'NR>1 {OFS="\t";print $1,$2,$2+1}' ${OUTPUT_DIR}/DEL.combine.sort.txt > ${OUTPUT_DIR}/DEL.combine.site.txt


############# combine all insertion #############
perl Step3_combine_INS.pl
awk 'NR==1; NR > 1 {print $0 | "sort -k1,1 -k2,2n"}' ${OUTPUT_DIR}/INS.combine.txt > ${OUTPUT_DIR}/INS.combine.sort.txt
awk 'NR>1 {OFS="\t";print $1,$2,$2}' ${OUTPUT_DIR}/INS.combine.sort.txt > ${OUTPUT_DIR}/INS.combine.site.txt


############# combine all variant ###########
cat combine/SNP.combine.site.txt combine/INS.combine.site.txt combine/DEL.combine.site.txt | sort -k1,1 -k2,2n | awk '{OFS="\t";print $1,$2-1,$2}' | uniq -u > combine/allsite.bed

head -n 1 combine/SNP.combine.txt > header
tail -n +2 combine/SNP.combine.txt >> combine/all.combine.txt  # +2 exclude title line
tail -n +2 combine/INS.combine.txt >> combine/all.combine.txt
tail -n +2 combine/DEL.combine.txt >> combine/all.combine.txt
sort -k1,1 -k2,2n combine/all.combine.txt | cat header - > combine/all.combine.sort.txt

echo "---------Step3 done!"



