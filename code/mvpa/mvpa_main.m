%% VISual BRAille DECODING ANALYSIS
%
% Main script to run all the multivariate analyses
% Performs several types of decoding:
% - pairwise decoding within script
% - pairwise decoding cross-script
% - multiclass decoding 
% in several areas (the ROIs created beforehand) 
%
% Code is split between the different areas analysed: 
% * localized areas include VWFA, lLO, rLO
% * language areas include all the Fedorenko's parcels and l-PosTemp in
%   particular
% * early visual areas includes V1, obviuously (could not find a better 
%   definition)

clear;
clc;

% GET PATHS, BIDSSPM

% spm
warning('on');

% cosmo
cosmo = '~/Applications/CoSMoMVPA';
addpath(genpath(cosmo));
cosmo_warning('once');

% libsvm
libsvm = '~/Applications/libsvm';
addpath(genpath(libsvm));

% verify it worked
cosmo_check_external('libsvm'); 

% add bidspm repo
addpath '../lib/bidspm'
bidspm;


%% Decoding on localized areas 
% Areas localized in the first part of the experiment are the main focus

% Load options
opt = mvpa_option();

% Perform all the decodings in one function:
% - feature selection
% - pairwise comparisons within script
% - multiclass decoding within script
% - pairwise comparison cross-script
[expansionPairwiseWithin, expansionMulticlass, expansionPairwiseCross, opt] = mvpa_decoding(opt);

% Multidimensional scaling 
mds_main 
% TO BE FIXED

%% Language areas decoding
% Perform within-script and cross-script decoding in language areas
% Subject pool and areas from roi_createLanguageRois

% Load options
opt = mvpa_option_languageROIs();

% Perform all the decodings in one function:
% - feature selection
% - pairwise comparisons within script
% - multiclass decoding within script
% - pairwise comparison cross-script
[languagePairwiseWithin, languageMulticlass, languagePairwiseCross, opt] = mvpa_decoding(opt);


%% Early visual areas decoding
% Perform within-script and cross-script decoding in early visual areas
% Subject pool and areas from roi_createV1ROIs

% Load options
opt = mvpa_option_earlyVisual();

% Perform all the decodings in one function:
% (you know the gist by now)
[visualPairwiseWithin, visualMulticlass, visualPairwiseCross, opt] = mvpa_decoding(opt);


