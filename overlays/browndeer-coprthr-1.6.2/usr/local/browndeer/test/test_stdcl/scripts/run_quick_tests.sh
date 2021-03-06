#!/bin/bash

run_test() {

	./getndev.x --dev >& /dev/null
	ndev=$?
	for (( i=0; i<$ndev; i++ ))
	do 
		printf "%-68s" "$1 $2 $3 (stddev $i)"
		$1 --size $2 --blocksize $3 --dev $i >>log.stddev.$i 2>&1
		if [ $? -eq 0 ]; then
			printf "%10s\n" "[pass]"
		else 
			printf "%10s\n" "[failed]"
		fi;
	done

	./getndev.x --cpu >& /dev/null
	ndev=$?
	for (( i=0; i<$ndev; i++ ))
	do 
		printf "%-68s" "$1 $2 $3 (stdcpu $i)"
		$1 --size $2 --blocksize $3 --cpu $i >>log.stdcpu.$i 2>&1
		if [ $? -eq 0 ]; then
			printf "%10s\n" "[pass]"
		else 
			printf "%10s\n" "[failed]"
		fi;
	done

	./getndev.x --gpu >& /dev/null
	ndev=$?
	for (( i=0; i<$ndev; i++ ))
	do
		printf "%-68s" "$1 $2 $3 (stdgpu $i)"
		$1 --size $2 --blocksize $3 --gpu $i >>log.stdgpu.$i 2>&1
		if [ $? -eq 0 ]; then
			printf "%10s\n" "[pass]"
		else 
			printf "%10s\n" "[failed]"
		fi;
	done

	./getndev.x --acc >& /dev/null
	ndev=$?
	for (( i=0; i<$ndev; i++ ))
	do
		printf "%-68s" "$1 $2 $3 (stdacc $i)"
		$1 --size $2 --blocksize $3 --acc $i >>log.stdacc.$i 2>&1
		if [ $? -eq 0 ]; then
			printf "%10s\n" "[pass]"
		else 
			printf "%10s\n" "[failed]"
		fi;
	done

}

echo -e "\nCHECK ENVIRONMENT ...";

test_lib_opencl=`ldd ./getndev.x | grep 'libOpenCL.so' | grep -o 'not found'`
test_lib_stdcl=`ldd ./getndev.x | grep 'libstdcl.so' | grep -o 'not found'`

if test "x$test_lib_opencl" = "xnot found"; then
   echo "libOpenCL.so not found, check LD_LIBRARY_PATH";
   exit -1;
fi;
if test "x$test_lib_stdcl" = "xnot found"; then
   echo "libstdcl.so not found, check LD_LIBRARY_PATH";
   exit -1;
fi;


if [ ${EPIPHANY_PLATFORM}x = "EMEKx" ]; then
   TEST_SIZE=1024
else
   TEST_SIZE=65536
fi

#export COPRTHR_CLMESG_LEVEL=5

echo -e "\nRUNNING TESTS ...";

for t in $*; do

run_test ./$t  ${TEST_SIZE}  16

done

echo -e "... TESTS COMPLETE.";

