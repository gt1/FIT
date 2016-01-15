#! /bin/bash
source tools.sh

export PATH=${BIOBAMBAM2DIR}/bin:$PATH

export TYPES="improper samestrand split unmapped"

# create makefile for histograms
function mk
{
ALL=""
printf "all: files\n"
for j in ${TYPES} ; do
	for k in $* ; do
		i="${k%.bam}_${j}.bam"
		if [ -e "${i}" ] ; then
			# replace # by x for makefile
			QUOTED=`echo $i | tr '#' 'x'`
			# collate, intervalcommenthist, keep first four columns, extract (run:lane#tag)
			printf "${QUOTED}.hist:\n\tbamcollate2 verbose=0 mapqthres=${MAPQTHRES} level=0 < \"${i}\" | bamintervalcommenthist verbose=0 | awk -F '\\\t' '{print \$\$1 \"\\\t\"  \$\$2 \"\\\t\" \$\$3 \"\\\t\" \$\$4  }' | perl -p -e \"s/HS([0-9])+_([0-9]+):([0-9]+):([0-9]+):([0-9]+):([0-9]+)#([0-9]+)/\\\$\$2:\\\$\$3\\\#\\\$\$7/\" > \"${QUOTED}.hist\"\n"
			ALL="${ALL} ${QUOTED}.hist"
		fi
	done
done
printf "files: ${ALL}\n"
}

# loop over mapping quality thresholds
for MQT in 0 5 10 15 20 25 ; do

	# threshold for this run
	export MAPQTHRES=${MQT}

	# create histograms Makefile
	mk $* > Makefile.hist

	# generate histograms
	make -j ${NUMTHREADS} -k -f Makefile.hist

	# restore names (replace x by #)
	for i in *.bam.hist ; do
		NAME=`echo "$i" | perl -p -e "s/^(\\d+)_(\\d+)x(\\d+)/\\$1_\\$2#\\$3/"`
		mv "$i" "$NAME"
	done

	for i in *.bam.hist ; do
		# remove run_lane#tag_ from name
		# e.g. turn 10713_7#43_smalt_rmdup_commented_no_clipped_improper.bam.hist
		# into                 smalt_rmdup_commented_no_clipped_improper.bam.hist
		QNAME=`echo $i | perl -p -e "s/\d+_\d+\#\d+_//"`
		# remove .bam.hist from name
		# e.g. turn smalt_rmdup_commented_no_clipped_improper.bam.hist
		# into      smalt_rmdup_commented_no_clipped_improper
		QNAME="${QNAME%.bam.hist}"
		# replace end of line by _${QNAME} (add type of anomaly)
		cat ${i} | perl -p -e "s/$/_$QNAME/" > ${i}.tmp
		mv ${i}.tmp ${i}
	done

	for i in *.bam.hist ; do
		# grep for KMT2A
		grep "KMT2A" < "${i}" > "${i}.KMT2A"
		
		# remove file if not present
		if [ ! -s "${i}.KMT2A" ] ; then
			rm -f "${i}.KMT2A"
		fi
	done

	# generate files for certain genes
	for GENE in AFF1 ELL MLLT4 EPS15 SEPT9 SEPT6 MLLT6 AFF3 TET1 PICALM ABI1 CASC5 MYO1F ACTN4 FOXO3 CEP170B MAML2 SEPT11 TNRC18 \
		ABI2 ACACA AFF4 AKAP13 AP2A2 ARHGEF12 ARHGEF17 BCL9L BUD13 C2CD3 CASP8AP2 CBL CEP164 CREBBP DCP1A DCPS FNBP1 GAS7 GMPS \
		KIAA1524 LAMC3 BTBD18 ME2 MYH11 NEBL NRIP3 PDS5A PRPF19 RUNDC3B EEFSEC SEPT2 SMAP1 TOP3A VAV1 MLLT3 MLLT1 MLLT10 MLLT11 SEPT5 FLNA ; do
		if [ -z "${GENELIST}" ] ; then
			GENELIST="${i}"
		else
			GENELIST="${GENELIST}|${GENE}"
		fi
		
		cat *.hist | grep KMT2A | egrep "\(${GENE}|,${GENE}" > gene_${GENE}.stat

		if [ ! -s gene_${GENE}.stat ] ; then
			rm -f gene_${GENE}.stat
		fi
	done

	# KMT2A combined with gene list above
	cat *.hist | grep KMT2A | egrep -i "${GENELIST}" | perl -p -e "s/.bam.hist:/\t/" | sort -r -s -n -k 1,1 > KMT2A_gene_subset.stat
	# KMT2A with any gene
	cat *.hist | grep KMT2A |                          perl -p -e "s/.bam.hist:/\t/" | sort -r -s -n -k 1,1 > KMT2A_all.stat
	# any combination
	cat *.bam.hist | sort -k 1,1 -n -r > all.stat

	rm -f Makefile.hist

	rm -fR stats_${MQT}
	mkdir -p stats_${MQT} 
	# move all of the .hist and .stat files into MQT directory
	mv *.hist *.hist.KMT2A *.stat stats_${MQT}/

	function histsort
	{
		# sort by (maxsupport,number of samples,sum over support)
		awk -F '\t' '{print $2 "\t" $3 "\t" $4 "," $1 }' \
			| ${TRANSLOCATIONSDIR}/bin/pairhist \
			| sort -k 5,5 -s -n -r \
			| sort -k 1,1 -s -n -r \
			| sort -k 4,4 -s -n -r
	}

	pushd stats_${MQT}
	cat KMT2A_all.stat | histsort > KMT2A_all.stat.hist
	cat KMT2A_gene_subset.stat | histsort > KMT2A_gene_subset.stat.hist
	cat all.stat | histsort > all.stat.hist
	popd

done
