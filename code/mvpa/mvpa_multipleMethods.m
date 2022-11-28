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

% add cpp repo
initCppSpm;

% load options
opt = mvpa_option();

%% SET UP MASKS AND VOXELS

% opt = mvpa_prepareMasks(opt);

methods = {'general_coords_10mm','individual_coords_10mm','individual_coord_8mm','individual_coords_50vx'};

% DO IT FOR EVERY METHOD

% for i = 1:length(methods)
    opt.roiMethod = 'individual_coords_marsbar';

    % get how many voxels are active / significant in each ROI
    maskVoxel = mvpa_calculateMaskSize(opt);

    % keep the minimun value of voxels in a ROI as ratio to keep (must be constant)
    opt.mvpa.ratioToKeep = 50;

% end


%% GO GET THAT ACCURACY!

% Within modality
% training set and test set both contain RW, PW, NW, FS stimuli.
% Learn to distinguish them
mvpaWithin = mvpa_withinModality(opt);

%% Visualize nicely

mvpa_readableMatrix;

%%
% "Cross-modal" decoding
% Train on one of the conditions, test on the others
% mvpaCross = mvpa_CrossModal(opt);
