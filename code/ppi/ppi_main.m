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

%% GET PATHS, BIDSSPM, OPTIONS

% add bidspm and init it
addpath '../lib/bidspm'
addpath(genpath(pwd))
bidspm;

% get options
opt = ppi_option();

%% Step by step, follow the manual instructions

% Concatenate runs, onsets, durations, motion regressors
% and save all the outputs in opt.
% Then, run GLM on the concatenated run
ppi_concatRunsAndRunGLM;

% Extract the first VOI to compute interactions 
opt.voiList = {'VWFAfr'};
ppi_extractVOIs;
 
% Based on the VOI extracted, perform and visualize the interactions
ppi_doPPI;
 
% Run GLM using the PPI-interaction 
ppi_interactionGLM;

% Extract VOIs for each area we are interested in
opt.voiList = {'LH_IFGorb', 'LH_IFG', 'LH_MFG', 'LH_AntTemp', 'LH_PosTemp', 'LH_AngG'};
ppi_extractVOIs;

% Compute interactions with alle the new areas 

% Visualize the results (on matlab)
ppi_visualizeCorrelations; 




