%% VISual BRAille DECODING ANALYSIS
%

clear;
clc;

%% GET PATHS, CPP_SPM, OPTIONS

% spm
warning('off');

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
initCppSpm;

% load options
opt = mvpa_blockMvpa_option();

%% SET UP MASKS AND VOXELS

% get how many voxels are active / significant in each ROI
maskVoxel = mvpa_calculateMaskSize(opt);

% keep the minimun value of voxels in a ROI as ratio to keep (must be constant)
opt.mvpa.ratioToKeep = min(maskVoxel); 

%% GO GET THAT ACCURACY!

% Within modality
% training set and test set both contain RW, PW, NW, FS stimuli.
% Learn to distinguish them
mvpaWithin = mvpa_withinModality(opt);

%%
% "Cross-modal" decoding
% Train on one of the conditions, test on the others
% mvpaCross = mvpa_CrossModal(opt);
