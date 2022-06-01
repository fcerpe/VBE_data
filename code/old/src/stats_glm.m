% (C) Copyright 2019 Remi Gau

clear;
clc;

warning('off');

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

%
bidsFFX('specifyAndEstimate', opt, funcFWHM);

%
bidsFFX('contrasts', opt, funcFWHM);

%
bidsResults(opt, funcFWHM);

%% Group analysis
% Soon
% 
% bidsRFX('smoothContrasts', opt);
% bidsRFX('RFX', opt);
