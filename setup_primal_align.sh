#!/bin/bash

for fq in *_R1_001.fastq
do
	samples=${fq%_R1_001.fastq}
	sample=${samples%_S*}
	echo ${sample}
	
	mkdir ${sample}
	mv ${sample}*.fastq ${sample}
done
