%% VISual BRAille PPI analysis 
%
% Main script of a pipeline that includes:
% - concatenation of runs and GLM estiamtion
% - extraction of VOIs 
% - PPI
% - visualization of interaction between areas 
%
% All the steps are taken from 
% * SPM 12 Manual - chapter 37 "Psychophysiological Interactions (PPI)"
%   https://www.fil.ion.ucl.ac.uk/spm/doc/manual.pdf
%   
% * Andy's Brain Book - Appendix B: Psychophysiological Interactions (PPI) in SPM
%   https://andysbrainbook.readthedocs.io/en/latest/SPM/SPM_Short_Course/SPM_PPI.html
%
% (C) Copyright 2023 bidspm developers

clear;
clc;

% add and load bidspm
addpath '../lib/bidspm'
addpath(genpath(pwd))
bidspm;

% get options
opt = ppi_option();


%% Step by step, follow the manual instructions

for iSub = 1:numel(opt.subList)

    % bidspm runs each tep for all the subjects. Assign one subject at the
    % time to the decidated variable to run the whole PPI pipeline on one
    % subject after the other (useful to check for errors)
    opt.subjects = opt.subList(iSub);

    % 1. Concatenate runs, onsets, durations, motion regressors
    %    and save all the outputs in opt.
    %    Then, run GLM on the concatenated run
    ppi_concatenatedGLM;

    % 2. Extract the first VOI to compute interactions
    %    First time it only does so in the first area (VWFA)
    %    and for the whole contrast (e.g. FW-SFW)
    ppi_extractVOIs;

    % 3. Based on the VOI extracted, perform and visualize the interactions
    %    within the seed region, to extract parameters for the second level
    %    GLM
    ppi_doPPI;

    % 4. Run GLM using the PPI values of the first seed region. It will
    %    show which areas show activation relative to the psycho-physiological
    %    interaction of the first seed area, meaning areas that are
    %    co-activated
    ppi_interactionGLM;

    % 5. Extract VOIs for each seed and contrasts we are interested in
    ppi_extractVOIs;

    % 6. Compute interactions with all the areas: 
    %    seed and targets identified by the interaction GLM, for all
    %    stimuli conditions
    ppi_doPPI;

end

% After all analyses have been done, extract values for each data point and 
% slopes from all the results. To be visualized in R
% ppi_extractInteractions;

