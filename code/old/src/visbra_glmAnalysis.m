% (C) Copyright 2019 Remi Gau

clear;
clc;

warning('off');
addpath(genpath('C:\Users\filip\Documents\MATLAB\spm12')); % genpath = subfolders
addpath(genpath('C:\Users\filip\Documents\MATLAB\NIfTI_tools'));

% Sets up the environment for the analysis and add libraries to the path
% initEnv();

%% Set options
opt = stats_getOption_localizer();
% opt = stats_getOption_evrel();

checkDependencies(opt);

%% Run batches
reportBIDS(opt);
bidsCopyInputFolder(opt);

% Smoothing to apply: change parameteres if you go for mvpa-rsa
if strcmp (opt.taskName, 'visualEventRelated')
    funcFWHM = 2;
else
    funcFWHM = 6;
end

bidsSmoothing(funcFWHM, opt);

bidsFFX('specifyAndEstimate', opt, funcFWHM);
bidsFFX('contrasts', opt, funcFWHM);
bidsResults(opt, funcFWHM);

%% Group analysis

bidsRFX('smoothContrasts', opt);
bidsRFX('RFX', opt);

% WIP: group level results
% bidsResults(opt);
