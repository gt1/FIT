#! /bin/bash
source tools.sh

# remove make file
rm -f Makefile.breakpoints

# create make file
printf "all: files\n" >>Makefile.breakpoints
# loop over .stat.hist files for KMT2A
for i in stats_*/KMT2A_all.stat.hist stats_*/KMT2A_gene_subset.stat.hist ; do
	# if break points file does not exist
	if [ ! -f ${i}.breakpoints.gz ] ; then
		echo $i
		printf "${i}.breakpoints.gz:\n\t${TRANSLOCATIONSDIR}/bin/breakpoints < ${i} | gzip -9 > ${i}.breakpoints.gz\n" >>Makefile.breakpoints
		BP="${BP} ${i}.breakpoints.gz"
	fi
	
	# if break points file with no overlaps does not exist (gene pair regions do not overlap)
	if [ ! -f ${i%.hist}.nooverlap.hist.breakpoints.gz ] ; then
		echo ${i%.hist}.nooverlap.hist
		${TRANSLOCATIONSDIR}/bin/instancefilter keepoverlap=0 < ${i} > ${i%.hist}.nooverlap.hist
		printf "${i%.hist}.nooverlap.hist.breakpoints.gz:\n\t${TRANSLOCATIONSDIR}/bin/breakpoints < ${i%.hist}.nooverlap.hist | gzip -9 > ${i%.hist}.nooverlap.hist.breakpoints.gz\n" >>Makefile.breakpoints
		BP="${BP} ${i%.hist}.nooverlap.hist.breakpoints.gz"
	fi
	
	# loop over type
	for mtype in split samestrand improper ; do
		subhist=${i%.hist}.${mtype}.hist
		
		# if type break points file does not exist
		if [ ! -f ${subhist}.breakpoints.gz ] ; then
			echo ${subhist}
			${TRANSLOCATIONSDIR}/bin/instancefilter keepoverlap=0 type=${mtype} < ${i} > ${subhist}
			printf "${subhist}.breakpoints.gz:\n\t${TRANSLOCATIONSDIR}/bin/breakpoints < ${subhist} | gzip -9 > ${subhist}.breakpoints.gz\n" >>Makefile.breakpoints
			BP="${BP} ${subhist}.breakpoints.gz"
		fi
	done
done

# type=

# loop over all pairs
for i in stats_*/all.stat.hist ; do
	# if break points file does not exit
	if [ ! -f ${i}.breakpoints.gz ] ; then
		echo $i
		printf "${i}.breakpoints.gz:\n\t${TRANSLOCATIONSDIR}/bin/breakpoints < ${i} | gzip -9 > ${i}.breakpoints.gz\n" >>Makefile.breakpoints
		BP="${BP} ${i}.breakpoints.gz"
	fi

	# if no overlaps (see above) break points file does not exist
	if [ ! -f ${i%.hist}.nooverlap.hist.breakpoints.gz ] ; then
		echo ${i%.hist}.nooverlap.hist
		${TRANSLOCATIONSDIR}/bin/instancefilter keepoverlap=0 < ${i} > ${i%.hist}.nooverlap.hist
		printf "${i%.hist}.nooverlap.hist.breakpoints.gz:\n\t${TRANSLOCATIONSDIR}/bin/breakpoints < ${i%.hist}.nooverlap.hist | gzip -9 > ${i%.hist}.nooverlap.hist.breakpoints.gz\n" >>Makefile.breakpoints
		BP="${BP} ${i%.hist}.nooverlap.hist.breakpoints.gz"
	fi
done

# print list of all break point files to be create
printf "files: ${BP}\n" >>Makefile.breakpoints

# create files
nice -n 20 make -j16 -f Makefile.breakpoints

#for i in stats_*/*.breakpoints.gz ; do
#	echo $i
#done
