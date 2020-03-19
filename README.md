# PrimalAlign

Very very simple script to trim reads with trim_galore, align with bwa, sam to bam filtering out supplementary and additional alignents and primer clip reads post alignment using [bamclipper](https://github.com/tommyau/bamclipper). NB: it point to the bamclipper in my home directory on alpha.

Within a folder with two fastqs in the format \*\_R1_001.fastq and \*\_R2_001.fastq (it will find those fatsq's automatically) provide the reference path/name, the stub for output namees, and the bed file of primer locations with respect to the reference.

```
primal_align.sh ref.fasta output_name ref.bed
```

This will create a raw and primer clipped bam file:

```
output_name.bam

output.primerclipped.bam
```

Uploaded the nCoV reference and primer bed file based on [V1 of artic nCoV-2019 primers](https://github.com/artic-network/artic-ncov2019/tree/master/primer_schemes/nCoV-2019/V1)
