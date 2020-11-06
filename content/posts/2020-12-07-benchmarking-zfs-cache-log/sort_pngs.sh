#! /usr/bin/env bash

set -euo pipefail

source "$(cd $(dirname "${0}") && pwd)/data.sh"

for syncMode in "${syncModes[@]}"; do
    for rw in "${fioReadWrite[@]}"; do
        mkdir -p "${syncMode}/${rw}"
        mv "${rw}-${syncMode}"-*.png "${syncMode}/${rw}"
    done
done
