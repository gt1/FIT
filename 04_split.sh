#! /bin/bash
source tools.sh

function createmk
{
CNT=0
printf "all: files\n"
for i in $* ; do
	PREFIX=${i%.bam}

	if [ ! -f ${PREFIX}_split.bam ] ; then	
		printf "${CNT}:\n\t${BIOBAMBAM2DIR}/bin/bamcollate2 < ${i} level=0 | ${BIOBAMBAM2DIR}/bin/bamflagsplit level=0 unmapped=${PREFIX}_unmapped.bam supplementary=${PREFIX}_supplementary.bam orphan=${PREFIX}_orphan.bam single=${PREFIX}_single.bam split=${PREFIX}_split.bam improper=${PREFIX}_improper.bam samestrand=${PREFIX}_samestrand.bam proper=/dev/null\n"
		ALL="${ALL} ${CNT}"
		CNT=$((CNT+1))
	fi
done
printf "files: ${ALL}\n"
}

createmk $* >Makefile.split
nice -n 20 make -j ${NUMTHREADS} -f Makefile.split 1>&2

# exit 0

for i in $* ; do
	PREFIX=${i%.bam}
	
	for j in unmapped supplementary orphan single split improper samestrand ; do
		L=`samtools view ${PREFIX}_${j}.bam | head -n 1 | wc -l`
		if [ $L -eq 0 ] ; then
			rm -f ${PREFIX}_${j}.bam
		else
			${BIOBAMBAM2DIR}/bin/bamsort index=1 indexfilename=${PREFIX}_${j}.bam.bai < ${PREFIX}_${j}.bam > ${PREFIX}_${j}.bam.tmp
			mv ${PREFIX}_${j}.bam.tmp ${PREFIX}_${j}.bam
			# echo ${PREFIX}_${j}.bam
		fi		
	done
done
