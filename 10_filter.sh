#!/bin/bash
source tools.sh

INSTTHRES=3
BPTHRESLOW=2
BPTHRESHIGH=10
${TRANSLOCATIONSDIR}/bin/falsepositivefilter instthres=${INSTTHRES} bpthreslow=${BPTHRESLOW} bpthres=${BPTHRESHIGH} <stats_25/KMT2A_all.stat.nooverlap.hist.breakpoints_filtered_2.gz \
	> stats_25/KMT2A_all.stat.nooverlap.hist.breakpoints_filtered_2_postfiltered.txt

INSTTHRES=3
BPTHRESLOW=2
BPTHRESHIGH=4
${TRANSLOCATIONSDIR}/bin/falsepositivefilter instthres=${INSTTHRES} bpthreslow=${BPTHRESLOW} bpthres=${BPTHRESHIGH} <stats_25/KMT2A_gene_subset.stat.nooverlap.hist.breakpoints_filtered_2.gz \
	> stats_25/KMT2A_gene_subset.stat.nooverlap.hist.breakpoints_filtered_2_postfiltered.txt

INSTTHRES=3
BPTHRESLOW=2
BPTHRESHIGH=10
${TRANSLOCATIONSDIR}/bin/falsepositivefilter instthres=${INSTTHRES} bpthreslow=${BPTHRESLOW} bpthres=${BPTHRESHIGH} <stats_25/all.stat.nooverlap.hist.breakpoints_filtered_2.gz \
	> stats_25/all.stat.nooverlap.hist.breakpoints_filtered_2_postfiltered.txt

INSTTHRES=3
BPTHRESLOW=2
BPTHRESHIGH=5
${TRANSLOCATIONSDIR}/bin/falsepositivefilter instthres=${INSTTHRES} bpthreslow=${BPTHRESLOW} bpthres=${BPTHRESHIGH} <stats_25/all.stat.nooverlap.hist.breakpoints_filtered_2.gz
