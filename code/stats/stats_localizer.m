% This script will run the FFX and contrasts on it of the MoAE dataset
%
% Results might be a bit different from those in the manual as some
% default options are slightly different in this pipeline
% (e.g use of FAST instead of AR(1), motion regressors added)
%
% (C) Copyright 2019 Remi Gau

clear;
clc;

warning('on');

% add spm to the path
addpath(fullfile(pwd, '..', 'lib', 'bidspm'));
addpath(fullfile(pwd, '..', 'lib', 'CPP_BIDS'));
bidspm;

% check inside if everything is ok before starting the pipeline
opt = stats_localizer_option();

%% Stats based on .json model file
% check stats_localizer_option for details

bidsFFX('specifyAndEstimate', opt);
 
bidsFFX('contrasts', opt);

bidsResults(opt);

%% Group analysis
% Soon
% 
% bidsRFX('smoothContrasts', opt);
% bidsRFX('RFX', opt);
