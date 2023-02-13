function opt = roi_option()
% returns a structure that contains the options chosen by the user to run
% createROI (extraction)

if nargin < 1
    opt = [];
end

% suject to run in each group
opt.subjects = {'006','007','008','009', '012', '013'}; % every participant after 006 is included in the final study

opt.roiList = {'VWFA-Fr', 'VWFA-Br', 'LOC-Left', 'LOC-Right'}; % , 'PFS-Left', 'PFS-Right'};

% Radius of the sphere around the peak
opt.radius = 10; %mm

% Number of voxels in the case of expanding ROI
opt.numVoxels = 50;

% Save the ROI?
opt.saveROI = true;

% specify the order of the runs where we can find the following conditions
% French - Braille: 003 006 008
% Braille - French: 002 004 007 009
%                            f  f  f  f  f  f  b  b  b  b  b  b
opt.subsCondition = {'006', [1  3  5  7  9 11  2  4  6  8 10 12];
                     '007', [2  4  6  8 10 12  1  3  5  7  9 11];
                     };
%                     '008', [1  3  5  7  9 11  2  4  6  8 10 12];
%                     '009', [2  4  6  8 10 12  1  3  5  7  9 11]


% we stay in native space (that of the T1)
opt.space = 'MNI'; % 'individual', 'MNI'

% description to add to folder name, to distinguish from GLM (see other
% script)
opt.desc = 'MVPA';

% I like chatty outputs
opt.verbosity = 2;

% task to analyze
opt.taskName = 'wordsDecoding';

% PATHS
% The directory where the data are located
opt.dir.root = fullfile(fileparts(mfilename('fullpath')), '..', '..');

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
opt.pipeline.type = 'roi';

opt.model.file = fullfile(opt.dir.root, 'code', ...
    'models', 'model-wordsDecoding_fourConditions_smdl.json');


%% DO NOT TOUCH
opt = checkOptions(opt);
saveOptions(opt);
% we cannot save opt with opt.mvpa, it crashes

%% univariate options to specify contrasts etc.

%% multivariate options

% define the 4D maps to be used
opt.fwhm.func = 2;
opt.fwhm.contrast = 0;

% take the most responsive xx nb of voxels
% opt.mvpa.ratioToKeep = 300; % 100 150 250 350 420

% set which type of ffx results you want to use
opt.mvpa.map4D = {'beta', 'tMaps'};

% design info
opt.mvpa.nbRun = 12;
opt.mvpa.nbTrialRepetition = 1;

% cosmo options
opt.mvpa.tool = 'cosmo';
% opt.mvpa.normalization = 'zscore';
opt.mvpa.child_classifier = @cosmo_classify_libsvm;
opt.mvpa.feature_selector = @cosmo_anova_feature_selector;

% permute the accuracies ?
opt.mvpa.permutate = 0;

end
