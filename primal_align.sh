#!/bin/bash

for fastq in *.fastq
do
	if [[ $fastq == *_R1_001.fastq ]]

		then
		R1=$fastq
		echo "Read1 file = $R1"
	fi

        if [[ $fastq == *_R2_001.fastq ]]
                then
                R2=$fastq
                echo "Read2 file = $R2"
        fi
done

trim_galore -q 25 --dont_gzip --length 50 --paired $R1 $R2 > trim_galore_out.txt 2>&1 

for fastq in *.fq
do
	if [[ $fastq == *R1_001_val_1.fq ]]
		then
		T1=$fastq
		echo "Read1 file = $T1"
	fi

        if [[ $fastq == *R2_001_val_2.fq ]]
                then
                T2=$fastq
                echo "Read2 file = $T2"
        fi
done

bwa index $1
bwa mem -t 10 $1 $T1 $T2 > $2.sam 2> bwa_mem_out.txt

#get rid of unmapped and secondary/supplementary alignments
#filter low mapping qulaity reads q25
samtools view -F4 -F256 -F2048 -q 25 -bS $2.sam > $2.bam

samtools sort -@ 10 $2.bam -o $2_sort.bam
mv $2_sort.bam $2.bam
samtools index $2.bam
rm -f $2.sam

#by default -u=1 and -d=5, these should be tweaked to capture incomplete primers in the read
#the -d considers incomplete primers i.e. if primer is 1->20, and the read start at 10, would be ignored by default as 10>d=5
#so if primers are say 30bp (and amplicons not close) then try -d=30 or even -d=40
#the -u captures reads that go past the primer, say primer is 50->70 and read starts at 40 - can get rid if the 40-50 section with -u=10
#play with -u and -d, ensure no chance of confusing amplicons
~orto01r/alicTest/bamclipper-master/bamclipper.sh -u 1 -d 5 -b ${2}.bam -p $3 -s ~orto01r/alicTest/samtools-1.3.1/samtools -n 10
