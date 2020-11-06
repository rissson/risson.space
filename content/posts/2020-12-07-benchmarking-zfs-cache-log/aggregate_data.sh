#! /usr/bin/env bash

set -euo pipefail

source "$(cd $(dirname "${0}") && pwd)/data.sh"

for rw in "${fioReadWrite[@]}"; do
    for syncMode in "${syncModes[@]}"; do
        echo -e "# config\tbs\tread-iops\twrite-iops\tread-bw_MB\twrite_bw_MB" \
            > "${rw}-${syncMode}.dat"

        for benchConfig in "${benchConfigs[@]}"; do
            echo
            for bs in "${fioBlockSizes[@]}"; do
                echo -n -e "${benchConfig}\t${bs}\t"
                cat "${benchConfig}-${rw}-${bs}-${syncMode}.json" | \
                    jq -r '.jobs[0] | [.read.iops, .write.iops, .read.bw_bytes / 1024 / 1024, .write.bw_bytes / 1024 / 1024] | @tsv'
            done
        done >> "${rw}-${syncMode}.dat"
    done
done
