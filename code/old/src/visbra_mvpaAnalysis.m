%% MVPA Analysis scirpt for VISual BRAille study.
%
%   Coming from CerenB\rhythmBlock_mvpa scripts on github
%   + Fede's and Iqra's scripts

clear;
clc;

%% Load options
% 

% options come from event related design, the one set up to do mvpa
opt = mvpa_getOption();

% add cpp repo
run ../lib/CPP_SPM/initCppSpm.m;

warning('off');

%% Run batches
reportBIDS(opt);
bidsCopyRawFolder(opt);

% slice time correction
bidsSTC(opt);

% spatial preprocessing
bidsSpatialPrepro(opt);

% Quality control
% anatomicalQA(opt);
% bidsResliceTpmToFunc(opt);
% functionalQA(opt);

%% smth = 6
% group level univariate
% conFWHM = 8;
% bidsRFX('smoothContrasts', opt,funcFWHM, conFWHM);
% bidsRFX('RFX', opt, funcFWHM, conFWHM);
% WIP: group level results
% bidsResults(opt, FWHM);


%% MVPA

% %% SMOOTHING OF 0
% funcFWHM = 0;
%     
% bidsSmoothing(funcFWHM, opt);
% 
% bidsFFX('specifyAndEstimate', opt, funcFWHM);
% bidsFFX('contrasts', opt, funcFWHM);
% 
% bidsResults(opt, funcFWHM);
% % % prep for mvpa
% 
% bidsConcatBetaTmaps(opt, funcFWHM, 0, 0);

%% SMOOTHING OF 2
funcFWHM = 2; 

bidsSmoothing(funcFWHM, opt);

bidsFFX('specifyAndEstimate', opt, funcFWHM);
bidsFFX('contrasts', opt, funcFWHM);

bidsResults(opt, funcFWHM);

bidsConcatBetaTmaps(opt, funcFWHM, 0, 0);

