#!/bin/bash
export BIOBAMBAM2VERSION=2.0.26-release-20160112195720
export BIOBAMBAM2ARCH=biobambam2-${BIOBAMBAM2VERSION}-x86_64-etch-linux-gnu.tar.gz
export BIOBAMBAM2URL=https://github.com/gt1/biobambam2/releases/download/${BIOBAMBAM2VERSION}/${BIOBAMBAM2ARCH}
export BIOBAMBAM2DIR=${PWD}/${BIOBAMBAM2ARCH%.tar.gz}
export SMALTINSTDIR=${PWD}/smalt
export SMALT=${SMALTINSTDIR}/bin/smalt
export SAMTOOLSDIR=$PWD/samtools
# export SMALT="smalt-0.7.6.2"
export SCRAMBLE=${BIOBAMBAM2DIR}/bin/scramble
export SAMTOOLS=${SAMTOOLSDIR}/bin/samtools
export TRANSLOCATIONSVERSION=0.0.1-release-20160114112323
export TRANSLOCATIONSARCHIVE=translocations-${TRANSLOCATIONSVERSION}-x86_64-etch-linux-gnu.tar.gz
export TRANSLOCATIONSDIR=${PWD}/${TRANSLOCATIONSARCHIVE%.tar.gz}

if [ ! -e ${TRANSLOCATIONSARCHIVE} ] ; then
	curl --location -o ${TRANSLOCATIONSARCHIVE} \
		https://github.com/gt1/translocations/releases/download/${TRANSLOCATIONSVERSION}/${TRANSLOCATIONSARCHIVE}
fi

if [ ! -e ${TRANSLOCATIONSDIR}/bin/minreflenfilter ] ; then
	tar xzf ${TRANSLOCATIONSARCHIVE}
fi

if [ ! -e ${SAMTOOLSDIR}/bin/samtools ] ; then
	curl --location -o samtools-1.3.tar.bz2 https://github.com/samtools/samtools/releases/download/1.3/samtools-1.3.tar.bz2
	tar xjvf samtools-1.3.tar.bz2
	
	pushd samtools-1.3
	make
	make prefix=${SAMTOOLSDIR} install
	popd
fi

if [ ! -e ${BIOBAMBAM2DIR}/bin/bamsort ] ; then
	if [ ! -e ${BIOBAMBAM2ARCH} ] ; then
		curl --location -o ${BIOBAMBAM2ARCH} \
			https://github.com/gt1/biobambam2/releases/download/${BIOBAMBAM2VERSION}/${BIOBAMBAM2ARCH}
	fi

	tar xzf ${BIOBAMBAM2ARCH}
fi

if [ ! -e ${SMALTINSTDIR}/bin/smalt ] ; then
	if [ ! -e smalt-0.7.6-static.tar.gz ] ; then
		curl --location -o smalt-0.7.6-static.tar.gz http://downloads.sourceforge.net/project/smalt/smalt-0.7.6-static.tar.gz
	fi

	if [ ! -e bambamc-0.0.50-release-20140430085950.tar.gz ] ; then
		curl --location -o bambamc-0.0.50-release-20140430085950.tar.gz https://github.com/gt1/bambamc/archive/0.0.50-release-20140430085950.tar.gz
	fi
	
	tar xzvf bambamc-0.0.50-release-20140430085950.tar.gz
	pushd bambamc-0.0.50-release-20140430085950
	./configure --prefix=${SMALTINSTDIR} --enable-static --disable-shared
	make install
	popd
	rm -fR bambamc-0.0.50-release-20140430085950
	
	tar xzvf smalt-0.7.6-static.tar.gz
	pushd smalt-0.7.6
	PKG_CONFIG_PATH=${SMALTINSTDIR}/lib/pkgconfig LDFLAGS="-Wl,-rpath=${SMALTINSTDIR}/lib" ./configure --prefix=${SMALTINSTDIR} --with-bambamc
	make
	make install
	popd
	rm -fR smalt-0.7.6
fi

if [ ! -e reference/hg19/hg19.fa ] ; then
	if [ ! -e chromFa.tar.gz ] ; then
		curl --location -o chromFa.tar.gz ftp://hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/chromFa.tar.gz
	fi

	tar xzf chromFa.tar.gz
	for i in `seq 1 9` ; do
		mv chr${i}.fa chr0${i}.fa
	done

	for i in `seq 1 9` ; do
		L=`ls chr${i}_* 2>/dev/null`
		if [ ! -z "${L}" ] ; then
			for j in chr${i}_* ; do
				SUF=`echo $j | sed "s|chr${i}_||"`
				REW=chr0${i}_${SUF}
				mv $j $REW
			done
		fi
	done

	mkdir -p reference/hg19
	cat chr[0-9][0-9].fa chrX.fa chrY.fa chr[0-9][0-9]_*.fa chrM.fa chrUn*.fa | ${BIOBAMBAM2DIR}/bin/normalisefasta >reference/hg19/hg19.fa 2>reference/hg19/hg19.fa.fai
	rm -f chr[0-9][0-9].fa chrX.fa chrY.fa chr[0-9][0-9]_*.fa chrM.fa chrUn*.fa

	HG19CHKSUM=`md5sum reference/hg19/hg19.fa | awk '{print $1}'`

	if [ "${HG19CHKSUM}" != "6a6d35e713dbd96c6e5b4a3efb51a5ce" ] ; then
		echo "Failed to obtain hg19.fa"
		exit 1
	fi
fi


if [ ! -e reference/hg19/hg19.sma ] ; then
	${SMALT} index -k 13 -s 6 reference/hg19/hg19 reference/hg19/hg19.fa
fi

if [ ! -e reference/hg19/refFlat.txt.gz ] ; then
	mkdir -p reference/hg19
	curl --location -o reference/hg19/refFlat.txt.gz http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/refFlat.txt.gz
fi
