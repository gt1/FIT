#! /bin/bash
source tools.sh

# this script filters out break points with less than 2 supporting read pairs

# create make file
function createmk
{
ALL=
printf "all: files\n"
for i in `ls stats_*/*.breakpoints.gz | grep -v filtered` ; do
	THRES=2
	OUT=${i%.gz}_filtered_${THRES}.gz
	printf "${OUT}:\n\t${TRANSLOCATIONSDIR}/bin/evidencefilter gz=1 thres=${THRES} <${i} >${OUT}\n"
	ALL="${ALL} ${OUT}"
done
printf "files: ${ALL}\n"
}

# run filter
createmk >Makefile.filter
nice -n 20 make -j${NUMTHREADS} -f Makefile.filter
