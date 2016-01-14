#! /bin/bash

# cleanup filter not restricting to known partner gene subset

( zcat stats_25/KMT2A_all.stat.nooverlap.hist.breakpoints_filtered_2.gz ) | \
	perl -p -e "s/_smalt[^\s]*//g" | \
	awk '/^[0-9]/ {print $1 "\t" $2 "\t" $3 } !/^[0-9]/ { printf "\t" $1 ; for (i=3; i<= NF; ++i) printf "\t" $i; printf "\n" }' | \
	perl -p -e "s/MappedPair//"