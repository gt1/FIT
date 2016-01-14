#! /bin/bash
source tools.sh

for i in $* ; do
	o=${i%.bam}_commented.bam
	if [ ! -f ${o} ] ; then
		${BIOBAMBAM2DIR}/bin/bamintervalcomment chromregex="chr([0-9]+|X|Y)$" unifytranscripts=1 \
			coord=1 intervals=reference/hg19/refFlat.txt.gz outputthreads=32 <"${i}" >"${o}"
	fi
done
