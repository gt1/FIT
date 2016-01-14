#! /bin/bash
source tools.sh

for i in $* ; do
	echo $i
	OUT=${i%.bam}_rmdup.bam
	${SAMTOOLS} view -F 1024 -b -u ${i} | \
		${BIOBAMBAM2DIR}/bin/bamcollate2 classes=F,F2 level=0 |\
		${BIOBAMBAM2DIR}/bin/bamsort outputthreads=32 > ${OUT}
	echo $i $OUT
done
