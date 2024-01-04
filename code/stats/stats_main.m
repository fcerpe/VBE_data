%% VISual BRAille fMRI stats

% main script for univariate stats and analyses done on univariate
% activations
%
% If ran entirely, it will perform almost all the GLMs done in the project, 
% with the exception of the 1st level PPI GLM, computed through the PPI scripts. 
% If ran block-by-block, allows to perform the different analyses
%
% From data preprocessed thorugh bidspm (see code/preproc): 
% - localizerGLM: univariate analysis of the task 'visualLocalizer'
% - mvpaGLM: univariate analysis of the task 'wordsDecoding'
% - eyeMovementsGLM: univariate analysis of the task 'visualLocalizer',
%                    including eyes displacement computed through 'bidsMReye'
%
% From data preprocessed thorugh fmriprep:
% - fmriprepLocalizerGLM: univariate analysis of the task 'visualLocalizer'
% - fmriprepMvpaGLM: univariate analysis of the task 'wordsDecoding'

clear;
clc;

% GET PATHS, BIDSSPM

% add bidspm and init it
addpath '../lib/bidspm'
addpath '../lib/CPP_BIDS'
bidspm;

%% Localizer stats

% get GLM-specific options
opt = stats_option_localizer();

% Call a generic function to compute GLM stats
stats_run(opt);

%% Decoding / MVPA task stats

% get GLM-specific options
opt = stats_option_decoding();

stats_run(opt);

%% Eye movement analysis: localizer stats

% Add eyes displacement to the confounds table.
% This should be ran only once, be careful in adding too many columns to
% the same file 
stats_addEyeMovements;

% get GLM-specific options
opt = stats_option_eyeMovements();

% run GLM
stats_run(opt);

%% Localizer stats from fmriprep preprocessed data

% get GLM-specific options
opt = stats_option_fmriprep_localizer();

% fmriprep does not perfrom smoothing, need to do it manually
% If you are using datalad to store this data, it must be unlocked 
bidsSmoothing(opt);

% run GLM
stats_run(opt);

%% Decoding / MVPA stats from fmriprep preprocessed data

% get GLM-specific options
opt = stats_option_fmriprep_decoding();

% Apply smoothing
% If you are using datalad to store this data, it must be unlocked 
bidsSmoothing(opt)

% run GLM
stats_run(opt);


