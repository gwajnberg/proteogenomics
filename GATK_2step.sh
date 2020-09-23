/home/iarc/bin/STAR/STAR-2.7.0f/bin/Linux_x86_64/STAR --runThreadN 20   --genomeDir /References_data/References_genome/storage_back/ensemblGRCh37/star/   --readFilesIn TCGA-H6-A45N-01_1.fastq TCGA-H6-A45N-01_2.fastq
/home/iarc/bin/STAR/STAR-2.7.0f/bin/Linux_x86_64/STAR --runMode genomeGenerate --genomeDir star_2pass/ --genomeFastaFiles /References_data/References_genome/storage_back/ensemblGRCh37/merged.fa --sjdbFileChrStartEnd SJ.out.tab --sjdbOverhang 75 --runThreadN 40

/home/iarc/bin/STAR/STAR-2.7.0f/bin/Linux_x86_64/STAR --genomeDir star_2pass/ --readFilesIn TCGA-H6-A45N-01_1.fastq TCGA-H6-A45N-01_2.fastq  --outSAMmapqUnique 60 --runThreadN 20; samtools sort -o TCGA-H6-A45N-01_sortedN.bam Aligned.out.sam

java -jar ~/Downloads/picard-tools-2.5.0/picard.jar AddOrReplaceReadGroups I=TCGA-H6-A45N-01_sortedN.bam O=rg_added_sorted.bam SO=coordinate RGID=TCGA-H6-A45N-01 RGLB=TCGA-H6-A45N-01 RGPL=ILLUMINA RGPU=TCGA-H6-A45N-01 RGSM=TCGA-H6-A45N-01
java -jar ~/Downloads/picard-tools-2.5.0/picard.jar MarkDuplicates I=rg_added_sorted.bam O=dedupped.bam  CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT M=output.metrics

java -jar ~/bin/GATK/gatk-4.1.2.0/gatk-4.1.2.0/gatk-package-4.1.2.0-local.jar SplitNCigarReads -R /References_data/References_genome/storage_back/ensemblGRCh37/merged.fa -I dedupped.bam -O split.bam

#GATK calling
java -jar ~/bin/GATK/gatk-4.1.2.0/gatk-4.1.2.0/gatk-package-4.1.2.0-local.jar Mutect2 -R /References_data/References_genome/storage_back/ensemblGRCh37/merged.fa -I split.bam -I ../07c1c896-d4bc-473a-ac0f-f0569cc93087/split.bam -tumor TCGA-H6-A45N-01  -normal TCGA-H6-A45N-11 --disable-read-filter MateOnSameContigOrNoMappedMateReadFilter -O somatic.vcf -bamout 2_tumor_normal_m2.bam
bcftools view -s TCGA-H6-A45N-01 somatic.vcf > somatic_ex.vcf
