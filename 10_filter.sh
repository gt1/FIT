#!/bin/bash

INSTTHRES=3
BPTHRESLOW=2
BPTHRESHIGH=10
${HOME}/src/translocations/src/falsepositivefilter instthres=${INSTTHRES} bpthreslow=${BPTHRESLOW} bpthres=${BPTHRESHIGH} <stats_25/KMT2A_all.stat.nooverlap.hist.breakpoints_filtered_2.gz \
	> stats_25/KMT2A_all.stat.nooverlap.hist.breakpoints_filtered_2_postfiltered.txt

INSTTHRES=3
BPTHRESLOW=2
BPTHRESHIGH=4
${HOME}/src/translocations/src/falsepositivefilter instthres=${INSTTHRES} bpthreslow=${BPTHRESLOW} bpthres=${BPTHRESHIGH} <stats_25/KMT2A_gene_subset.stat.nooverlap.hist.breakpoints_filtered_2.gz \
	> stats_25/KMT2A_gene_subset.stat.nooverlap.hist.breakpoints_filtered_2_postfiltered.txt

INSTTHRES=3
BPTHRESLOW=2
BPTHRESHIGH=10
${HOME}/src/translocations/src/falsepositivefilter instthres=${INSTTHRES} bpthreslow=${BPTHRESLOW} bpthres=${BPTHRESHIGH} <stats_25/all.stat.nooverlap.hist.breakpoints_filtered_2.gz \
	> stats_25/all.stat.nooverlap.hist.breakpoints_filtered_2_postfiltered.txt

INSTTHRES=3
BPTHRESLOW=2
BPTHRESHIGH=5
${HOME}/src/translocations/src/falsepositivefilter instthres=${INSTTHRES} bpthreslow=${BPTHRESLOW} bpthres=${BPTHRESHIGH} <stats_25/all.stat.nooverlap.hist.breakpoints_filtered_2.gz
