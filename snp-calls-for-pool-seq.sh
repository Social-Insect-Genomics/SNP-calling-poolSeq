Firstly, you will need to index your reference genome (.fasta) using BWA & samtools.

bwa index pbdagcon_relaxed_quiver.fasta

samtools faidx pbdagcon_relaxed_quiver.fasta

Next, we need to align your raw reads (.fastq OR .fq files) to the reference genome (.fasta) using BWA. This will create
a SAM file that we need to convert to BAM. We use samtools to do this conversion.

We use the -M	flag for compatability with picard (see picard steps below (AddOrReplaceReadGroups & MarkDuplicates))
What does -M do in BWA?
-M Marks shorter split hits as secondary (for Picard compatibility).
We also have -t in this BWA command. What does it do?
It specifies the number of threads to use.
-t Number of threads

You will notice that there is an -S and a -b in the samtools command.
-S lets samtools know we are using a SAM file as input (sample.sam). We need to
convert the SAM to BAM. The -b lets samtools know that we want a BAM file as output.

bwa mem -M -t 12 pbdagcon_relaxed_quiver.fasta sample_1.fq.gz sample_2.fq.gz | samtools view -S -b sample.sam > sample.bam

Next we need to sort our BAM file. This creates lots and lots of temporary files so 
we need to store all these files in a specific directory. 

You will notice that there is an -o and a -T in the samtools command. -o specifies
the name of the sorted bam file once the command is complete. -T specifies the directory
to place all the temporary files. The sample.bam file comes from the command directly above.

samtools sort -o sample_sort.bam -T /path/to/temp/file sample.bam

java -jar picard.jar AddOrReplaceReadGroups I=sample.bam_sort.bam O=sample.bam_sort_add_rg.bam RGID=sample1 RGPL=illumina RGSM=sample1 RGLB=lib1 RGPU=unit1

java -jar picard.jar MarkDuplicates I=sample.bam_sort_add_rg.bam O=sample.bam_sort_add_rg_markdup.bam METRICS_FILE=sample.bam_sort_add_rg_markdup.txt

samtools index sample.bam_sort_add_rg_markdup.bam

/30days/GROUPS/chenoase/nick_yiguan/bamUtil-master/insNick/bam clipOverlap --in ABrelax_woRG.bam_sort_add_rg_markdup.bam --out ABrelax_woRG.bam_sort_add_rg_markdup_clipOverlap.bam

/30days/GROUPS/chenoase/nick_yiguan/freebayes/bin/freebayes -f pbdagcon_relaxed_quiver.fasta --pooled-continuous ABrelax_woRG.bam_sort_add_rg_markdup_clipOverlap.bam > ABrelaxclipOverlap.vcf

