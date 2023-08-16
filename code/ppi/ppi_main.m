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

%% Get to it

% Concatenate runs, onsets, durations, motion regressors
% Compute 1st level analyses
ppi_1stLevelConcat;

% Extract the VOIs for each area 
ppi_extractVOIs;
% 
% % (perform the PPI)
% ppi_doPPI
% 
% % Visualizetion (on matlab)
% ppi_visualizeCorrelations