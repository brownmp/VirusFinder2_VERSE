#!/bin/tcsh
# by ygu@sanger.ac.uk
# 24/06/2008
#

set prog=/nfs/team81/tdo/bin/pileup_v0.4/ssaha_pileup # set ssaha_pileupProgramPath
set ssaha2Path=/nfs/team81/tdo/bin/pileup_v0.4/ssaha2 # set ssaha2ProgramPath

set kmer=13
set skip=2
set trans=0
set rtype="abi"
set insertSize=800
set ilow=640
set ihigh=960
set std=0.2
set paired=1
set dbg=1
set cigar=0
set pairend=0

if($#argv < 3) then
	echo "Usage:    $0 [options] reads.fastq ref.fasta result"
	echo "		options:"
	echo "			-kmer <kmer size> defult: 13"
	echo "			-skip <ssaha skip setting> defult: 2"
	echo "			-trans <0|1> defult setting: 0"
	echo "			-rtype <abi|solexa|454> defult: abi"
	echo "			-insertSizeRange <low,high> default: 640,860"
	echo "			-paired <0|1> default setting: 1"
	echo "			-cigar <0|1> default setting: 0"
	echo "			-pairend <low,high> eg: 20,800"
        exit
endif

@ n = 1
while ( $n <= $#argv - 3 ) 
	switch ($argv[$n])
            case -kmer:
		@ n = $n + 1
                set kmer=$argv[$n]
		@ n = $n + 1
                continue
            case -skip:
		@ n = $n + 1
		set skip=$argv[$n]
		@ n = $n + 1
                continue
            case -trans:
		@ n = $n + 1
		set trans=$argv[$n]
		@ n = $n + 1
                continue
	    case -rtype:
		@ n = $n + 1
		set rtype=$argv[$n]
		@ n = $n + 1
		continue
	    case -pairend:
		@ n = $n + 1
		set pairend=1
		set pairedLow=`echo $argv[$n] | sed 's/\,/ /' | awk '{print $1}'`
		set pairedHigh=`echo $argv[$n] | sed 's/\,/ /' | awk '{print $2}'`
		@ n = $n + 1
		continue
	    case -insertSizeRange:
		@ n = $n + 1
		set ilow=`echo $argv[$n] | sed 's/\,/ /' | awk '{print $1}'`
		set ihigh=`echo $argv[$n] | sed 's/\,/ /' | awk '{print $2}'`
		set insertSize=`echo $argv[$n] | sed 's/\,/ /' | awk '{print ($2+$1)/2}'`
		set std=`echo $argv[$n] | sed 's/\,/ /' | awk '{print 1.0*($2-$1)/($2+$1)}'`
		@ n = $n + 1
		continue
	    case -paired:
		@ n = $n + 1
		set paired=$argv[$n]
		@ n = $n + 1
		continue
	    case -dbg:
		@ n = $n + 1
		set dbg=$argv[$n]
		@ n = $n + 1
		continue
	    case -cigar:
		@ n = $n + 1
		set cigar=$argv[$n]
		@ n = $n + 1
		continue
	    default:
		echo unknown $argv[$n]
		exit
      endsw
end

set reads=$argv[$n]
@ n = $n + 1
set ref=$argv[$n]
@ n = $n + 1
set result=$argv[$n]

set solexa=0
if($rtype == "solexa") then 
	set solexa=1
endif

#set memory=200
set memory=800
#set cut=10000
set cut=5000000
set score=30
set seeds=5
set diff=-1

# echo $kmer $skip $trans $rtype $insertSize $std $paired $solexa

if($rtype == "solexa") then 
	set seeds=2
	set diff=0
#	set skip=1
	if($trans == 1) then
		set score=12
	else 
		set score=20
	endif
endif
if($rtype == "abi") then
	if($skip != 12) then
		echo "Warning: skip value 12 is used for abi reads!"
		set skip=12
	endif
	set score=250
	set seeds=15
	set diff=15
	set memory=300
	set cut=5000
endif
if($rtype == "454") then
	if($skip != 4) then 
		echo "Warning: skip value 4 is used for 454 reads!"
		set skip=4
	endif
	set seeds=5
	set score=30
	set diff=0
endif


echo "--------------------------------------------"
echo "settings to run the pipeline:"
echo "--------------------------------------------"
echo "\t" "readFile: $reads" 
echo "\t" referenceFile: $ref 
echo "\t" "resultFile: $result.{cns|snp|ins|del|cigar}"
echo "\t" kmer: $kmer
echo "\t" skip: $skip
echo "\t" trans: $trans
echo "\t" rtype: $rtype
echo "\t" std: $std
echo "\t" paired: $paired
echo "\t" memory: $memory
echo "\t" cut: $cut
echo "\t" score: $score
echo "\t" seeds: $seeds
echo "\t" diff: $diff
if($pairend == 1) then 
	echo "\t" pairend: $pairedLow,$pairedHigh
else 
	echo "\t" insertSizeRange: $ilow,$ihigh
	echo "\t" insertSize: $insertSize
	echo "\t" std: $std
endif
echo "the pipeline is running ..."
echo 

set arch=`uname -m`
if(! -f $ssaha2Path/ssaha2_v2.1.2_$arch/ssaha2) then
	echo "Error: can not find ssaha2 program for $arch"
	exit
endif

if($pairend == 1) then
	$ssaha2Path/ssaha2_v2.1.2_$arch/ssaha2 -rtype $rtype -kmer $kmer -score $score -seeds $seeds -skip $skip -diff $diff -memory $memory -cut $cut -pair $pairedLow,$pairedHigh -output cigar $ref $reads > tmp.cigar1.$$
else
	$ssaha2Path/ssaha2_v2.1.2_$arch/ssaha2 -rtype $rtype -kmer $kmer -score $score -seeds $seeds -skip $skip -diff $diff -memory $memory -cut $cut -output cigar $ref $reads > tmp.cigar1.$$
endif

egrep ^cigar tmp.cigar1.$$ > tmp.cigar2.$$
if($cigar == 1) then
	\mv tmp.cigar1.$$ $result.cigar
else 
	if($dbg == 0) \rm tmp.cigar1.$$
endif

if($pairend == 1) then
	cp tmp.cigar2.$$ tmp.$result.cigar3.$$
#	sed 's/\.F /.p1k /' tmp.cigar2.$$ | sed 's/\.R /.q1k /' > tmp.$result.cigar3.$$
	$prog/ssaha_pileup/ssaha_reads $reads tmp.fastq1.$$
	awk '{print $2}' tmp.$result.cigar3.$$ > tmp.$result.name.$$
	$prog/other_codes/get_seqreads/get_seqreads tmp.$result.name.$$ tmp.fastq1.$$ tmp.$result.fastq.$$
	\rm tmp.fastq1.$$
	if($dbg == 0) \rm tmp.name.$$
else 
	if($paired == 1) then 
		$prog/ssaha_pileup/ssaha_pairs -insert $insertSize -std $std tmp.cigar2.$$ tmp.cigar2c.$$
		if($rtype == "solexa") then
			$prog/ssaha_pileup/ssaha_clean -insert $insertSize tmp.cigar2c.$$ tmp.$result.cigar3.$$
			if($dbg == 0) \rm tmp.cigar2c.$$
		else 
			mv tmp.cigar2c.$$ tmp.$result.cigar3.$$
		endif
	else 
		$prog/ssaha_pileup/ssaha_cigar tmp.cigar2.$$ tmp.$result.cigar3.$$
	endif

#	awk '{print $2}' tmp.$result.cigar3.$$ > tmp.name.$$
#	$prog/other_codes/get_seqreads/get_seqreads tmp.name.$$ $reads tmp.fastq.$$ 
	if($dbg == 0) \rm tmp.name.$$
endif
if($dbg == 0) \rm tmp.cigar2.$$

#$prog/ssaha_pileup/ssaha_pileup -cons 1 -solexa $solexa -trans $trans tmp.$result.cigar3.$$ $ref tmp.fastq.$$ > tmp.$result.pileup.$$

#$prog/ssaha_pileup/ssaha_pileup -solexa $solexa -trans $trans tmp.$result.cigar3.$$ $ref tmp.fastq.$$ > $result.snp
if($dbg == 0) \rm tmp.fastq.$$
#$prog/ssaha_pileup/ssaha_indel -insertion 1 tmp.$result.cigar3.$$ $ref tmp.$result.pileup.$$ > $result.ins
#$prog/ssaha_pileup/ssaha_indel -deletion 1 tmp.$result.cigar3.$$ $ref tmp.$result.pileup.$$ > $result.del
#\mv -f tmp.pileup.$$ $result.cns

if($dbg == 0) then
	\rm -f tmp.*.$$
endif
