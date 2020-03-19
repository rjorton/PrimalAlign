# PrimalAlign

Very very simple script to trim reads with trim_galore, align with bwa, sam to bam filtering out supplementary and additional alignents and primer clip reads post alignment using bamclipper.

```
primal_align.sh ref.fasta output_name
```

wil create

```
output_name.bam
```

and

```
output.primerclipped.bam
```

configured to point to bamclipper installed in my home directory on alpha
