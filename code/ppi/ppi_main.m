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
%
% TO-DO
% - avoid that running different alphabets overlap each other, specify
% which script in the folders (second level GLM)

clear;
clc;

% GET PATHS, BIDSSPM, OPTIONS

% add bidspm and init it
addpath '../lib/bidspm'
addpath(genpath(pwd))
bidspm;


%% LOCALIZER DATA

% get options
opt = ppi_localizer_option();

ppi_localizer; 

%% MVPA DATA

% get options
opt = ppi_mvpa_option();

ppi_mvpa; 


