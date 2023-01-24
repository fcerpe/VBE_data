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
bidspm;

% load options
opt = mvpa_option();

%% SET UP MASKS AND VOXELS

% opt = mvpa_prepareMasks(opt);

methods = {'anatomical_intersection_8mm','general_coords_10mm','individual_coords_10mm','individual_coords_8mm','individual_coords_50vx'};

allRatios = [];
opt.mvpa.minMasks = [];
% DO IT FOR EVERY METHOD

for i = 1:length(methods)
    opt.roiMethod = methods{i};

    % get how many voxels are active / significant in each ROI
    maskVoxel = mvpa_calculateMaskSize(opt);

    % keep the minimun value of voxels in a ROI as ratio to keep (must be constant)
    opt.mvpa.minMasks = [opt.mvpa.minMasks, min(maskVoxel)];
    allRatios = [allRatios; maskVoxel'];

end


%% GO GET THAT ACCURACY!

opt.mvpa.nbRun = 12;

for i = 1:length(methods)
    
        opt.roiMethod = methods{i};
    
        % use maximum 50 voxels, less if we don't have enough
        if opt.mvpa.minMasks(i) < 50
            opt.mvpa.ratioToKeep = opt.mvpa.minMasks(i);
        else
            opt.mvpa.ratioToKeep = 50;
        end
    
        % Within modality
        % training set and test set both contain RW, PW, NW, FS stimuli.
        % Learn to distinguish them
        mvpaWithin = mvpa_withinModality(opt);
    
end

%% Visualize nicely

% mvpa_readableMatrix;

%%
% "Cross-modal" decoding
% Train on one of the conditions, test on the others
% mvpaCross = mvpa_CrossModal(opt);
