%% VISual BRAille DECODING ANALYSIS
%

clear;
clc;

%% GET PATHS, BIDSSPM, OPTIONS

% spm
warning('on');

% cosmo
cosmo = '~/Applications/CoSMoMVPA-master';
addpath(genpath(cosmo));
cosmo_warning('once');

% libsvm
libsvm = 'Users/Applications/libsvm';
addpath(genpath(libsvm));

% verify it worked
cosmo_check_external('libsvm'); % should not give an error

% add cpp repo
bidspm;

% load options
opt = mvpa_option();

%% SET UP MASKS AND VOXELS

% starts report on sizes of ROIs
opt.roiSizesReport = [];
allRatios = [];

% get how many voxels are active / significant in each ROI
[maskVoxel, opt] = mvpa_calculateMaskSize(opt);

% keep the minimun value of voxels in a ROI as ratio to keep (must be constant)
opt.mvpa.ratioToKeep = min(maskVoxel);

%% Compute decoding

% Within modality
% training set and test set both contain RW, PW, NW, FS stimuli.
% Learn to distinguish them
mvpaWithin = mvpa_pairwiseDecoding(opt);

%%
% "Cross-modal" decoding
% Train on one of the conditions, test on the others
% mvpaCross = mvpa_CrossModal(opt);
