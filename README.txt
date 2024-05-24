# Project: Visual Braille Expertise 
# Manuscript: "Widespread neural pattern reorganization related to expertise in reading visual Braille"
# Authors: Cerpelloni Filippo, Van Audenhaege Alice, Matuszewski Jacek, Gau Remi, Battal Ceren, Falagiarda Federica, Op de Beeck Hans*, Collignon Olivier*

**Repository tree**
```
.
├── code
│   ├── cfg
│   ├── containers
│   ├── lib
│   │   ├── CPP_BIDS
│   │   ├── bidsMReye
│   │   └── bidspm
│   ├── models
│   ├── mvpa
│   │   contains scripts necessary to perfom MVPA on the 4D maps extracted from stats
│   ├── ppi
│   │   contains all the code to run Psycho-physiological interaction
│   ├── preproc
│   │   contains code to pre-proecess nifti files in inputs/raw. based on bidspm
│   ├── rois
│   │   contains code to extract the regions of interest following the methods described in the manuscript
│   ├── src
│   ├── stats
│   │   contains code to run first level analyses. based on bidspm
│   └── visualization
│       contains code to plot results of MVPA and perform necessary statistical tests
├── inputs
│   └── raw
│       contains raw data in the bids format for all the participants       
└── outputs
    ├── derivatives
    │   ├── CoSMoMVPA
    │   │   Results of MVPA analyses
    │   │  
    │   ├── bidsMReye
    │   │   Results of bidsMReye. Estimation of eye movements for each participant and run
    │   │  
    │   ├── bidspm-preproc
    │   │   Preprocessed data for each participant and run
    │   │  
    │   ├── bidspm-stats
    │   │   Multiple first level GLMs for each participant 
    │   │   - localizer and mvpa experiment from two precprocessing pipelines
    │   │   - localzier for PPI analysis
    │   │   - GLM with eye movements as regressor
    │   │  
    │   ├── cpp_spm-rois
    │   │   ROIs extracted for each participant
    │   │   
    │   ├── figures
    │   │   plotting of results 
    │   │  
    │   ├── fmriprep
    │   │   Preprocessing of each participant using fmriprep
    │   ├── results
    │   │   Statistical tests
    │   │ 
    │   └── spm-PPI
    │   │   contains results of Psychophysiological interaction analysis
    │   │
    ├── error_logs
    └── options
```

**Requirements** (and relative submodules / packages used)

  - MATLAB (analyses were performed on version 2021b)
    - bidspm version 3.1.0 (forked to https://github.com/fcerpe/bidspm) and relative dependencies (for more information: https://bidspm.readthedocs.io/)
    - SPM12 version 7771
    - Anatomy toolbox (https://github.com/inm7/jubrain-anatomy-toolbox)
    - CoSMoMVPA (https://www.cosmomvpa.org)


  - Python (version 3.1)
    - bidsMReye (https://github.com/cpp-lln-lab/bidsMReye)

  - R (version 4.3.1)
    - packages: readxl, tidyverse, reshape2, gridExtra, pracma, dplyr, data.table, ez, lsr, effsize
 
**Installation**

Clone the repository following your preferred method, either by downloading the zipped folder or via terminal. 

If the installation of submodules fails, please note that is not a technical issue but a temporary choice. More information in the next section 

**Data availability** 

For participants' privacy, the raw data is momentarily set to private and will not be cloned as a submodule. Access is possible upon request. 

`Outputs/derivatives/results` and `/figures` are publicly available. 

We are working on anonymizing the participants raw data and will provide that as soon as possible. 


**Analyses steps**

For information about stimuli creation and experimental testing, please refer to the following repositories:
- stimuli creation: https://github.com/fcerpe/VisualBraille_backstage
- experimental testing: https://github.com/fcerpe/VBE_experiment

(preprocessing, univariate, and multivariate analyses cannot be replicated at the moment. See above for explanation)

We performed preprocessing, and first level analyses through bidspm. Please refer to its documentation for more information (https://bidspm.readthedocs.io/).

The following steps should (if data is available and present in `inputs/raw`) replicate the full analysis pipeline and should be performed in the indicated order:

- Preprocessing pipeline can be fully executed by running `code/preproc/preproc_main.m`. Outputs can be found in `outputs/derivatives/bidspm-preproc` 

- First level GLM can be fully executed by running `code/stats/stats_main.m`. Outputs can be found in `outputs/derivatives/bidspm-stats` 

- ROI extraction can be fully executed by running `code/rois/roi_main.m`. Outputs can be found in `outputs/derivatives/cpp-spm_rois` 

- Multivariate analyses can be fully executed by running `code/mvpa/mvpa_main.m`. Outputs can be found in `outputs/derivatives/CoSMoMVPA` 

- All plots can be reproduced from MVPA outputs by running `code/visualization/viz_main.R`. Outputs can be found in `outputs/derivatives/figures` and `outputs/derivatives/results`


**Contact**

For any question or request, don't hesitate to send me an email at: filippo.cerpelloni@gmail.com



