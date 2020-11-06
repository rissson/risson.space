#! /usr/bin/env bash

set -euo pipefail

source "$(cd $(dirname "${0}") && pwd)/data.sh"

doPlot() {
    tmpFile="/tmp/gnuplot"
    rw="${1}"
    syncMode="${2}"
    rwType="${3}"
    metric="${4}"

    dataFile="${rw}-${syncMode}.dat"

    case "${metric}" in
        "iops")
            readColumn=3
            writeColumn=4
        ;;
        "bandwidth-megabytes")
            readColumn=5
            writeColumn=6
        ;;
    esac

    case "${rwType}" in
        "read")
            column="${readColumn}"
        ;;
        "write")
            column="${writeColumn}"
        ;;
    esac

    cat > "${tmpFile}" <<EOF
set terminal pngcairo
set title "${rw} ${syncMode} ${metric} ${rwType}"
plot \\
EOF

    for benchConfig in "${benchConfigs[@]}"; do
        cat >> "${tmpFile}" <<EOF
    "<(sed -n '/^${benchConfig}\t/p' ${dataFile})" using ${column}:xticlabels(2) with linespoints title '${benchConfig}', \\
EOF
    done

    echo ";" >> "${tmpFile}"

    gnuplot "${tmpFile}" > "${rw}-${syncMode}-${metric}-${rwType}.png"
}

for syncMode in "${syncModes[@]}"; do
    for metric in "${metrics[@]}"; do
        for rw in "${fioRwRead[@]}"; do
            doPlot "${rw}" "${syncMode}" "read" "${metric}"
        done
        for rw in "${fioRwWrite[@]}"; do
            doPlot "${rw}" "${syncMode}" "write" "${metric}"
        done
    done
done
