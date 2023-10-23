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
% Calc features selection on all the subjects
opt.subjects = opt.mvpaGroups.allParticipants;

opt.roiSizesReport = [];
allRatios = [];

% get how many voxels are active / significant in each ROI
[maskVoxel, opt] = mvpa_calculateMaskSize(opt);

% keep the minimun value of voxels in a ROI as ratio to keep (must be constant)
opt.mvpa.ratioToKeep = min(maskVoxel);

fprintf(['\nWILL USE ', num2str(min(maskVoxel)), ' VOXELS FOR MVPA\n\n']);


%% Compute decoding
% Within modality
% training set and test set both contain RW, PW, NW, FS stimuli.
% Learn to distinguish them


%% Experts
opt.subjects = opt.mvpaGroups.experts;
opt.groupName = {'experts'};
mvpaWithin = mvpa_pairwiseDecoding(opt);


%% Controls
opt.subjects = opt.mvpaGroups.controls;
opt.groupName = {'controls'};
mvpaWithin = mvpa_pairwiseDecoding(opt);


%% Compute cross-script decoding
% Train on one of the conditions, test on the others
opt.subjects = opt.mvpaGroups.experts;
opt.groupName = {'experts'};
opt.decodingCondition = {'cross-script'};
mvpaCross = mvpa_crossScriptDecoding(opt);



%% Higher level language decoding
% Perform within-script and cross-script decoding in language areas
% Subject pool and areas from roi_createLanguageRois
opt.roiMethod = 'fedorenko';

% Calc features selection on all the subjects
opt.subjects = opt.mvpaGroups.languageActivation;
opt.roiSizesReport = [];
allRatios = [];

% get how many voxels are active / significant in each ROI
[maskVoxel, opt] = mvpa_calculateMaskSize(opt);

% keep the minimun value of voxels in a ROI as ratio to keep (must be constant)
opt.mvpa.ratioToKeep = min(maskVoxel);
fprintf(['\nWILL USE ', num2str(min(maskVoxel)), ' VOXELS FOR MVPA\n\n']);

% Experts
opt.subjects = {'006','007','008','009','013'};
opt.groupName = {'experts'};
mvpaWithin = mvpa_pairwiseDecoding(opt);
% Compute cross-script decoding
opt.decodingCondition = {'cross-script'};
mvpaCross = mvpa_crossScriptDecoding(opt);

% Controls
opt.subjects = {'010','011','018','019','020','021','022','023','024','027','028'};
opt.groupName = {'controls'};
mvpaWithin = mvpa_pairwiseDecoding(opt);

