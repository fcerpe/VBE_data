%% VISual BRAille DECODING ANALYSIS
%

clear;
clc;

%% GET PATHS, CPP_SPM, OPTIONS

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

% add spm to the path
addpath(fullfile(pwd, '..', '..', 'lib', 'bidspm'));
addpath(fullfile(pwd, '..', '..', 'lib', 'CPP_BIDS'));
bidspm;

% load options
opt = mvpa_evrel_option();

%% SET UP MASKS AND VOXELS

% get how many voxels are active / significant in each ROI
maskVoxel = mvpa_evrel_calculateMaskSize(opt);

% keep the minimun value of voxels in a ROI as ratio to keep (must be constant)
opt.mvpa.ratioToKeep = 50; 

%% GO GET THAT ACCURACY!

% Within modality
% training set and test set both contain RW, PW, NW, FS stimuli.
% Learn to distinguish them
mvpaWithin = mvpa_evrel_withinModality(opt);

%%
% "Cross-modal" decoding
% Train on one of the conditions, test on the others
% mvpaCross = mvpa_CrossModal(opt);
