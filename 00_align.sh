#! /bin/bash
source tools.sh

if [ $# -lt 3 ] ; then
	echo "usage: $0 <aligner> <input.bam> <indexprefix> [<numthreads>=2] [<tmpdir>=.]"
	exit 1
fi

VARIANT="smalt"
INPUTFILE="${2}"
export OUTPUTFILE="${INPUTFILE%.bam}_${VARIANT}.bam"
export METFILE="${INPUTFILE%.bam}_${VARIANT}.met"
export INDEXPREFIX="${3}"

if [ "${VARIANT}" = "smalt" ]  ; then
	if [ ! -f ${INDEXPREFIX}.sma ] ; then
		echo "Cannot locate smalt index, file ${INDEXPREFIX}.sma does not exist."
		exit 1
	fi
else
	echo "Unsupported aligner ${VARIANT}, supported are: smalt"
	exit 1
fi

export NUMTHREADS=2
if [ $# -ge 4 ] ; then
	export NUMTHREADS="${4}"
fi

TEMPDIR=.
if [ $# -ge 5 ] ; then
	export TEMPDIR="${5}"
fi

export NUMTHREADS2=`echo ${NUMTHREADS} / 2 | bc`

if [ $NUMTHREADS2 -eq 0 ] ; then
	export NUMTHREADS2=1
fi

export HOST=`uname -n`
export ADPFILE="${TEMPDIR}/${HOST}_$$_adp.bam"
export ADPFILEFQ="${TEMPDIR}/${ADPFILE}.fq"
export ADPFILE2FQ="${TEMPDIR}/${ADPFILE}_2.fq"

function cleanup
{
	rm -f "${ADPFILE}" "${ADPFILEFQ}" "${ADPFILE2FQ}"
}

trap "cleanup" SIGINT SIGTERM SIGHUP

function produceadpbam
{
	COL1TMP=${TEMPDIR}/${HOST}_$$_collate1_tmp

	set -x

	# Steps:
	# 1. reset file, add original rank, collate read pairs, add rank pairs
	# 2. find and clip adapters
	# 3. compress file
	
	${BIOBAMBAM2DIR}/bin/bamcollate2 T=${COL1TMP} collate=3 level=0 |\
		${BIOBAMBAM2DIR}/bin/bamfilteraux keep=RG level=0 |\
		${BIOBAMBAM2DIR}/bin/bamadapterfind level=0 clip=1 |\
		${BIOBAMBAM2DIR}/bin/bamrecompress numthreads=${NUMTHREADS}
		
	set +x
}

function alignpostprocess
{
	SORT1TMP=${TEMPDIR}/${HOST}_$$_sort1_tmp
	SORT2TMP=${TEMPDIR}/${HOST}_$$_sort2_tmp

	# 1. convert SAM to BAM
	# 2. sort by query name (not necessary if aligner keeps order)
	# 3. merge header and aux fields in original BAM file back into aligner output
	# 4. sort by name to restore the original order
	# 5. strip ranks off names
	# 6. compress output file

	${SCRAMBLE} -I sam -O bam |\
		${BIOBAMBAM2DIR}/bin/bamsort tmpfile=${SORT1TMP} SO=queryname level=0 |\
		${BIOBAMBAM2DIR}/bin/bam12auxmerge level=0 ${ADPFILE} |\
		${BIOBAMBAM2DIR}/bin/bamsort tmpfile=${SORT2TMP} SO=queryname level=0 |\
		${BIOBAMBAM2DIR}/bin/bam12strip level=0 |\
		${BIOBAMBAM2DIR}/bin/bamsort SO=coordinate fixmates=1 adddupmarksupport=1 level=0 calmdnm=1 calmdnmreference=${INDEXPREFIX}.fa |\
		${BIOBAMBAM2DIR}/bin/bamstreamingmarkduplicates M=$1 level=0 |\
		${BIOBAMBAM2DIR}/bin/bamrecompress numthreads=${NUMTHREADS}
}

# mark adapters and insert ranks into names
produceadpbam <"${INPUTFILE}" >"${ADPFILE}"
# produceadpbam >"${ADPFILE}"

if [ "${VARIANT}" = "smalt" ] ; then

	set -x

	ls -l "${ADPFILE}" >/dev/stderr

	# align and postprocess	
	${SMALT} map -n ${NUMTHREADS} -F bam -f samsoft "${INDEXPREFIX}" "${ADPFILE}" | alignpostprocess ${METFILE} >${OUTPUTFILE}
	
	ls -l "${ADPFILE}" >/dev/stderr

else
	echo "Unknown aligner ${VARIANT}, please choose one of bwa,mem,smalt,bowtie2"
fi

cleanup

exit 0
