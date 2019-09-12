#!/bin/bash

now=$(date +"%m_%d_%Y_%s")
kernel=/home/jprestwo/kernels/bzImage-net-next-mac

jobdir=$(pwd)/jobs/job_$now

echo $jobdir

mkdir -p $jobdir

cd $jobdir

mkdir environment
cd environment

git clone https://git.kernel.org/pub/scm/libs/ell/ell.git >> $jobdir/build.log

git clone https://git.kernel.org/pub/scm/network/wireless/iwd.git >> $jobdir/build.log
cd iwd
./bootstrap-configure >> $jobdir/build.log
make -j8 >> $jobdir/build.log

echo "Run under $(git rev-parse HEAD)" >> $jobdir/results.log

cd tools

for t in $(find ../autotests/ -type d -name "test*"); do
        name=$(basename $t)
        echo "Running test $name"
        if ! ./test-runner -A $name -v iwd,pytests,hwsim -k $kernel --valgrind >> $jobdir/$name.log; then
                printf 'Test %-25s FAILED\n' $name >> $jobdir/results.log
        else
                printf 'Test %-25s PASSED\n' $name >> $jobdir/results.log
        fi
done

cd ../../../

rm -rf environment
