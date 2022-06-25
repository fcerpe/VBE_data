#!/bin/bash

bids_dir=$(pwd)/../../inputs/raw
derivatives_dir=$(pwd)/../../outputs/derivatives

docker run -it --rm \
    -v $bids_dir:/data:ro \
    -v $derivatives_dir:/out \
    nipreps/mriqc:0.16.1 /data /out \
    participant --participant-label 002 \
    --verbose-reports
