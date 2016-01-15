# FIT

This repository contains the scripts comprising the FIT analysis system described in the supplementary material of the paper entitled
**Development of a Comprehensive Genomic Diagnostic Tool for Myeloid Malignancies**.

## Licensing
The scripts in this repository are distributed under version 3 of the GNU General Public License. A copy of this license can be found in the file GPLv3 in this repository.

## Author
The scripts in this repository were written by German Tischler while at the Wellcome Trust Sanger Institute, Hinxton, Cambridge, UK and the Max Planck Insitute for Molecular Cell
Biology and Genetics, Dresden and are

Copyright (C) 2004-2016 German Tischler  
Copyright (C) 2014-2015 Genome Research Limited

## System requirements

FIT requires a x86_64 GNU/Linux platform and sufficient space to map short reads to a human genome using smalt (see http://www.sanger.ac.uk/science/tools/smalt-0).

## Running it

As input the package requires one or more files with short sequencing reads in the BAM format. The file names must follow the scheme
<run_id>_<lane_id>#<tag>.bam where <run_id>, <lane_id> and <tag> are numbers. A valid example is 13811_5#31.bam. The analysis is then started by calling

```
bash FIT.sh in_1.bam in_2.bam ... in_n.bam
```

where in_1.bam etc. need to be valid names according to the schemes described above.

## Output
The system produces lists of break points supported by a sufficient number of read pairs

Summary files can be found at

- stats_25/KMT2A_gene_subset.stat.nooverlap.hist.breakpoints_filtered_2_postfiltered.txt
- stats_25/KMT2A_all.stat.nooverlap.hist.breakpoints_filtered_2_postfiltered.txt
- stats_25/all.stat.nooverlap.hist.breakpoints_filtered_2_postfiltered.txt

after the analysis has finished. These files report suspected translocations between

- KMT2A and the partner genes mentioned in the paper
- KMT2A and all other genes
- translocations between all genes

respectively.
