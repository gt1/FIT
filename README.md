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

## Running it
As input the package requires one or more files with short sequencing reads in the BAM format. The file names must follow the scheme
<run_id>_<lane_id>#<tag>.bam where <run_id>, <lane_id> and <tag> are numbers. A valid example is 13811_5#31.bam. The analysis is then started by calling

```
bash FIT.sh in_1.bam in_2.bam ... in_n.bam
```

where in_1.bam etc. need to be valid names according to the schemes described above.
