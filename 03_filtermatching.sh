#! /bin/bash
source tools.sh

function createmk
{
ALL=
CNT=0
printf "all: files\n"
for i in $* ; do
	o=${i%.bam}_no_clipped.bam
	printf "${CNT}:\n\t${TRANSLOCATIONSDIR}/bin/minreflenfilter minreflen=40 level=0 <${i} | ${BIOBAMBAM2DIR}/bin/bamcollate2 classes=F,F2 level=0 | ${BIOBAMBAM2DIR}/bin/bamsort >${o}\n"
	ALL="${ALL} ${CNT}"
	CNT=$((CNT + 1))
done

printf "files: ${ALL}\n"
}

createmk $* >Makefile.minreflenfilter
nice -n 20 make -f Makefile.minreflenfilter
