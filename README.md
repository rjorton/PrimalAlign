# PrimalAlign
Simple script to trim (trim_galore), align (bwa), primer trim (ivar) and conseus call (ivar) a sample. This is a basically a hard coded adaptation of [valvs](https://github.com/ZackBoyd123/valvs) for covid19.

If starting from a folder of (unzipped) FASTQs from multiple samples i.e. an Illumina run, with the reads in the format:

```
CVR01_S1_R1_0001.fastq
CVR01_S1_R2_0001.fastq
CVR02_S1_R1_0001.fastq
CVR02_S1_R2_0001.fastq
```

First run setup_primal_align.sh to create a folder for each sample and move each samples corresponding FASTQs into it's folder:

```
setup_primal_align.sh
```

Then to run Primal Align over each sample it's folder, run loop_primal_align.sh:

```
loop_primal_align.sh
```

This will run primal align on each sample. To run primal align on a single sample, move into a folder which has paired end FASTQs in the format _R1_0001.fastq and _R2_0001.fastq and type:

```
primal_align.sh
```

This will run:
* trim_galore: quality 20 and length 50
* bwa mem
* remove primers using ivar
* create a consensus using ivar: quality 20 depth 10

It will create:
* SampleName.bam - no primer trimming/clipping
* SampleName_trim.bam - with ivar primer trimming/clipping
* SampleName_trim_ivar_consensus - ivar consensus sequence

There will also be a log file called
```
SampleName_primal_log.txt
```
Which has the following info:
* Number of raw reads (reads not pairs)
* Number of trimmed reads (reads not pairs) - number and as a % of raw
* Number of reads mapping to BAM - number and as a % of raw
* Number of reads mapping to primer trimmed/clipped BAM - number and as a % of raw
* Average coverage extracted from [weeSAM](https://github.com/centre-for-virus-research/weeSAM) output

This is hard coded to run on alpha and hard coded for the covid-19 ref MN908947.fasta and artic v1 primers nCoV-2019-v1.bed to keep it minimal, will add an option to change to V2/V3 primers in a second.

# Old PrimalAlign

Very very simple script to trim reads with trim_galore, align with bwa, sam to bam filtering out supplementary and additional alignments and primer-clip reads post alignment using [bamclipper](https://github.com/tommyau/bamclipper). NB: it is hardcoded to point to the bamclipper in my home directory on alpha. The -d and -i options should be tweaked

Within a folder with two fastqs in the format \*\_R1_001.fastq and \*\_R2_001.fastq (it will find those fatsq's automatically) provide the reference path/name, the stub for output names, and the bed file of primer locations with respect to the reference.

```
primal_align.sh ref.fasta output_name ref.bed
```

This will create a raw and primer clipped bam file (plus indexes):

```
output_name.bam

output_name.primerclipped.bam
```

I have included the nCoV reference and primer BEDPE file based on [V1 of artic nCoV-2019 primers](https://github.com/artic-network/artic-ncov2019/tree/master/primer_schemes/nCoV-2019/V1)

```
bash primal_align.sh MN908947.fasta output_name MN908947_bed.txt
```


