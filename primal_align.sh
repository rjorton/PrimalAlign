#!/bin/bash

#hardcoded for use on alpa
#hardcoded for already bwa indexed ref
#hardcoded for ref MN908947.fasta
#hardcoded for V1 primer bed nCoV-2019.scheme.ivar.bed
#hardcoded for ten threads
#for flexible options -> use valvs

for fastq in *.fastq
do
	if [[ $fastq == *_R1_001.fastq ]]
		then
		samples=${fastq%_R1_001.fastq}
		sample=${samples%_S*}
		echo "Sample name = ${sample}"

		R1=$fastq
                echo "Raw read-1 file = $R1"
	fi

        if [[ $fastq == *_R2_001.fastq ]]
                then
                R2=$fastq
                echo "Raw read-2 file = $R2"
        fi
done

if [[ -z ${sample} ]];
then
	echo "No reads were found - are they in *_R1_001.fastq and *_R2_001.fastq format"
	echo "Exiting"
	exit 1
else
	echo ""
fi


primerV=${1}

if [[ -z ${primerV} ]];
then
	primerV=/home4/nCov/Richard/Ref/nCoV-2019-v1.bed
	echo "No primers defined so using V1 primers by default: ${primerV}"
elif [[ ${1} == "V1" || ${1} == "v1" || ${1} == "1" ]];
then
        primerV=/home4/nCov/Richard/Ref/nCoV-2019-v1.bed
        echo "Using V1 primers: ${primerV}"
elif [[ ${1} == "V2" || ${1} == "v2" || ${1} == "2" ]];
then
        primerV=/home4/nCov/Richard/Ref/nCoV-2019-v2.bed
        echo "Using V2 primers: ${primerV}"
elif [[ ${1} == "V3" || ${1} == "v3" || ${1} == "3" ]];
then
        primerV=/home4/nCov/Richard/Ref/nCoV-2019-v3.bed
        echo "Using V3 primers: ${primerV}"
else
	echo "Unrecognised primers: ${1}"
	echo "Exiting"
	exit 1
fi

log=${sample}_primal_log.txt
rm -f ${log}
touch ${log}

#Add check in to see if files have been found?

rawReads=$(expr `(wc -l ${R1} |cut -f1 -d " ")` / 4 \* 2)
echo "${rawReads} = number of raw reads" >> ${log}

#If MinION can create a consensus of Q10 data - why bother filtering so high?
trim_galore -q 20 --dont_gzip --length 50 --paired $R1 $R2 > trim_galore_out.txt 2>&1 

for fastq in *.fq
do
	if [[ $fastq == *R1_001_val_1.fq ]]
		then
		T1=$fastq
		echo "Trim read-1 file = $T1"
	fi

        if [[ $fastq == *R2_001_val_2.fq ]]
                then
                T2=$fastq
                echo "Trim read-2 file = $T2"
        fi
done

trimReads=$(expr `(wc -l ${T1} |cut -f1 -d " ")` / 4 \* 2)
trimProp=`echo "$trimReads $rawReads" | awk '{printf "%.2f", $1/$2*100}'`
echo "${trimProp}% = ${trimReads} = trimmed reads" >> ${log}

#bwa index $1
bwa mem -t 10 /home4/nCov/Richard/Ref/MN908947.fasta $T1 $T2 > ${sample}.sam

samtools view -F4 -bS ${sample}.sam > ${sample}.bam
samtools sort -@10 ${sample}.bam -o ${sample}_sort.bam
mv ${sample}_sort.bam ${sample}.bam
samtools index ${sample}.bam
rm -f ${sample}.sam

mappedReads=$(samtools view -c -F4 -F256 -F2048 ${sample}.bam)
mapProp=`echo "$mappedReads $rawReads" | awk '{printf "%.2f", $1/$2*100}'`
echo "${mapProp}% = ${mappedReads} = mapped reads [primer untrimmed BAM]" >> ${log}

ivar trim -i ${sample}.bam -p ${sample}_trim -b ${primerV} 
samtools sort -@10 ${sample}_trim.bam -o ${sample}_trim_sort.bam
mv ${sample}_trim_sort.bam ${sample}_trim.bam
samtools index ${sample}_trim.bam

trimMappedReads=$(samtools view -c -F4 -F256 -F2048 ${sample}_trim.bam)
trimMapProp=`echo "$trimMappedReads $rawReads" | awk '{printf "%.2f", $1/$2*100}'`
echo "${trimMapProp}% = ${trimMappedReads} = mapped reads [primer trimmed BAM]" >> ${log}

#alpha default not the latest weeSAM?
#issue using it through screen as well
~orto01r/programs/weeSAM/weeSAM --bam ${sample}_trim.bam --out ${sample}_trim_weesam.txt --html ${sample}_trim --overwrite
avcov=`(tail -n1 ${sample}_trim_weesam.txt | cut -f 8)`
echo "${avcov} = average coverage [primer trimmed BAM]" >> ${log}

samtools mpileup -B -A -aa -d 1000000 -Q 0 ${sample}_trim.bam | ivar consensus -p ${sample}_trim_ivar_consensus -n N -t 0.6 -m 10
echo "${sample}_trim_ivar_consensus.fa = ivar consensus sequence" >> ${log}

