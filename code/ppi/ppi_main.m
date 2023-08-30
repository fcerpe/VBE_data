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

% GET PATHS, BIDSSPM, OPTIONS

% add bidspm and init it
addpath '../lib/bidspm'
addpath(genpath(pwd))
bidspm;

% get options
opt = ppi_option();

%% Step by step, follow the manual instructions

for thisSub = 1:numel(opt.totalSubs)

    opt.subjects = opt.totalSubs(thisSub);

    % Concatenate runs, onsets, durations, motion regressors
    % and save all the outputs in opt.
    % Then, run GLM on the concatenated run
    ppi_concatRunsAndRunGLM;

    % Extract the first VOI to compute interactions
    % First time it only does so in the first area (VWFA)
    % and for the whole contrast (e.g. FW-SFW)
    ppi_extractVOIs;

    % Based on the VOI extracted, perform and visualize the interactions
    ppi_doPPI;

    % Run GLM using the PPI-interaction
    ppi_interactionGLM;

    % Extract VOIs for each area we are interested in
    ppi_extractVOIs;

    % Compute interactions with all the areas: old and new for both stimuli type
    % Example:
    % - if computing FW-SFW, now get the PPI in each area for both FW and SFW
    ppi_doPPI;

    % Visualize the results (on matlab)
    ppi_visualizeInteractions;

end



