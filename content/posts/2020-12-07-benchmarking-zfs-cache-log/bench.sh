#! /usr/bin/env bash

set -xeuo pipefail

source "$(cd $(dirname "${0}") && pwd)/data.sh"

# Set this to whatever combination of disk you are benchmarking
benchName="${benchName:-}"
outputDir="${outputDir:-/root/bench}"

mkdir -p "${outputDir}"

FIO="${FIO:-fio}"
NB_THREAD="${NB_THREADS:-8}"

fioBaseOpts="--direct=1 --ioengine=libaio --size=100G --runtime=180 --iodepth=64"
fioOutputOpts="--output-format=terse,json"
fioOpts="${fioBaseOpts} ${fioOutputOpts}"

fioAsyncOpts="--numjobs=${NB_THREADS} --group_reporting"

date
for rw in "${fioReadWrite[@]}"; do
    echo "##### rw: ${rw}"
    for bs in "${fioBlockSizes[@]}"; do
        echo "### bs: ${bs}"

        echo "# sync"
        "${FIO}" --name=bench \
            ${fioOpts} \
            --bs=${bs} \
            --readwrite=${rw} \
            > "${outputDir}/${benchName}-${rw}-${bs}-async.out"
        date

        echo "# async"
        "${FIO}" --name=bench \
            ${fioOpts} ${fioAsyncOpts} \
            --bs=${bs} \
            --readwrite=${rw} \
            > "${outputDir}/${benchName}-${rw}-${bs}-async.out"
        date
    done
done
