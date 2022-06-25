#!/bin/bash

#update this to your participant label
participants="001 002"

code_dir=$(pwd)
bids_dir=$(pwd)/../inputs/raw
derivatives_dir=$(pwd)/../outputs/derivatives

docker run -it --rm \
    -v $code:/code:ro \
    -v $bids_dir:/data:ro \
    -v $derivatives_dir:/out \
    nipreps/fmriprep:20.2.0 /data /out \
    participant --participant_label ${participants} \
    --fs-license-file /code/license.txt \
    --output-spaces T1w:res-native MNI152NLin2009cAsym:res-native
