#! /usr/bin/env bash

set -euo pipefail

for f in *.out; do
    head -n1 "${f}" > "${f%.*}.terse"
    tail -n+2 "${f}" > "${f%.*}.json"
done
