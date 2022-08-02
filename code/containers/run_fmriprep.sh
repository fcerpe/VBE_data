#!/bin/bash

#update this to your participant label
participants="006"

code_dir=$(pwd)
bids_dir=$(pwd)/../../inputs/raw
derivatives_dir=$(pwd)/../../outputs/derivatives

docker run -it --rm \
    -v ~/Desktop/GitHub/VisualBraille_data/code:/code:ro \
    -v ~/Desktop/GitHub/VisualBraille_data/inputs/raw:/data:ro \
    -v ~/Desktop/GitHub/VisualBraille_data/outputs/derivatives/fmriprep:/out \
    -v ~/Desktop/GitHub/VisualBraille_data/code/containers/freesurfer_lic.txt:/license \
    nipreps/fmriprep:21.0.2 /data /out \
    participant --participant-label 004 \
    --fs-license-file /license \
    --output-spaces MNI152NLin2009cAsym
    --work-dir /out/temp
