function opt = mvpa_evrel_option()
% returns a structure that contains the options chosen by the user to run
% bidsConcat and also Decoding (two scripts)

if nargin < 1
    opt = [];
end

% suject to run in each group
opt.subjects = {'001','002','003'}; % 004


% assign the condition to decode, changes based on our aims
% all: single words decoding
opt.decodingCondition = {'all'};

% Uncomment the lines below to run preprocessing
% - don't use realign and unwarp
opt.realign.useUnwarp = true;

% we stay in native space (that of the T1)
opt.space = 'MNI'; % 'individual', 'MNI'

% description to add to folder name, to distinguish from GLM (see other
% script)
opt.desc = 'MVPA';

% I like chatty outputs
opt.verbosity = 1;

% task to analyze
opt.taskName = 'visualEventRelated';

% PATHS
% The directory where the data are located
opt.dir.root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');

opt.dir.raw = fullfile(opt.dir.root, 'inputs', 'raw');
opt.dir.derivatives = fullfile(opt.dir.root, 'outputs', 'derivatives');
opt.dir.preproc = fullfile(opt.dir.root, 'outputs', 'derivatives', 'bidspm-preproc');
opt.dir.input = opt.dir.preproc;
opt.dir.rois = fullfile(opt.dir.root, 'outputs', 'derivatives', 'cpp_spm-rois');
opt.dir.stats = fullfile(opt.dir.root, 'outputs', 'derivatives', 'bidspm-stats');
opt.dir.cosmo = fullfile(opt.dir.root, 'outputs', 'derivatives', 'CoSMoMVPA');

% Suffix output directory for the saved jobs
opt.jobsDir = fullfile(opt.dir.stats, 'jobs', opt.taskName);
opt.glm.QA.do = false;

% multivariate
% Model specifies all the contrasts
opt.model.file = fullfile(fileparts(mfilename('fullpath')), '..', '..', ...
    'models', 'obsolete', 'model-visualEvrel_singleWords_smdl.json');

opt.pipeline.type = 'stats';

% Options for normalization (in case they're needed)
opt.funcVoxelDims = [2.6 2.6 2.6];
opt.parallelize.do = false;
opt.parallelize.nbWorkers = 1;
opt.parallelize.killOnExit = true;

% ROI method (empty will be 10mm sphere around individual peaks)
opt.roiMethod = [];

%% DO NOT TOUCH
opt = checkOptions(opt);
saveOptions(opt);
% we cannot save opt with opt.mvpa, it crashes

%% multivariate options

% define the 4D maps to be used
opt.fwhm.func = 2;
opt.fwhm.contrast = 0;

% take the most responsive xx nb of voxels
% opt.mvpa.ratioToKeep = 300; % 100 150 250 350 420

% set which type of ffx results you want to use
opt.mvpa.map4D = {'beta'};

% design info
opt.mvpa.nbRun = 8;
opt.mvpa.nbTrialRepetition = 1;

% cosmo options
opt.mvpa.tool = 'cosmo';
% opt.mvpa.normalization = 'zscore';
opt.mvpa.child_classifier = @cosmo_classify_libsvm;
opt.mvpa.feature_selector = @cosmo_anova_feature_selector;

% permute the accuracies ?
opt.mvpa.permutate = 0;

end
