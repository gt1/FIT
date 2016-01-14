#!/bin/bash
export NUMTHREADS=1

function FIT_process
{
	INPUT="$1"
	
	ALIGNED=${INPUT%.bam}_smalt.bam
	RMDUPED=${ALIGNED%.bam}_rmdup.bam
	COMMENTED=${RMDUPED%.bam}_commented.bam
	NOCLIPPED=${COMMENTED%.bam}_no_clipped.bam
	SPLIT=${NOCLIPPED%.bam}_split.bam
	
	# remove adapters and align
	if [ ! -e ${INPUT%.bam}_smalt.bam ] ; then
		${SHELL} 00_align.sh smalt ${INPUT} reference/hg19/hg19 ${NUMTHREADS} 1>&2
	fi
	
	# remove duplicates
	if [ ! -e ${RMDUPED} ] ; then
		${SHELL} 01_rmdup.sh ${ALIGNED} 1>&2
	fi
		
	# add gene interval comments
	if [ ! -e ${COMMENTED} ] ; then
		${SHELL} 02_comment.sh ${RMDUPED} 1>&2
	fi
		
	# remove heavily clipped alignments
	if [ ! -e ${NOCLIPPED} ] ; then
		${SHELL} 03_filtermatching.sh ${COMMENTED} 1>&2
	fi
	
	# split
	if [ ! -e ${SPLIT} ] ; then
		${SHELL} 04_split.sh ${NOCLIPPED}
	fi
	
	echo ${NOCLIPPED}
}

c=0
for i in $* ; do
	proc[$c]=`FIT_process $i`
	c=$((c+1))
done

while [ $c -gt 1 ] ; do
	o=0
	nproc=()
	for i in `seq 0 2 $((c-1))` ; do
		if [ $((i+1)) -lt $c ] ; then
			nproc[$o]="${proc[$i]} ${proc[$((i+1))]}"
		else
			nproc[$o]="${proc[$i]}"
		fi
		o=$((o+1))
	done
	
	c=$o
	proc=("${nproc[@]}")
done

if [ $c -gt 0 ] ; then
	${SHELL} 05_hist.sh ${proc[0]}
fi

${SHELL} 06_breakpoints.sh
${SHELL} 07_filterbreakpoints.sh
${SHELL} 08_filter.sh
${SHELL} 09_filter_all.sh
${SHELL} 10_filter.sh
