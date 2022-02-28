
function opt = mvpa_getOption()
% returns a structure that contains the options chosen by the user to run
% bidsConcat and also Decoding (two scripts)

if nargin < 1
    opt = [];
end

% suject to run in each group
opt.subjects = {'001','002','003'};

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
WD = 'C:\Users\filip\Documents\Gin\VisualBraille\analysis';

opt.dataDir = fullfile(WD, 'inputs', 'raw');

opt.derivativesDir = fullfile(WD, 'outputs', 'derivatives', 'cpp_spm-stats');

opt.pathOutput = fullfile(WD, 'outputs', 'derivatives', 'cosmoMvpa');

% Dragging back probably obsolete stuff that I need 
opt.dir.derivatives = fullfile(opt.derivativesDir, 'cpp_spm-stats');

% Suffix output directory for the saved jobs
opt.jobsDir = fullfile(WD, 'outputs', 'derivatives', 'cpp_spm-stats', 'jobs', opt.taskName);
opt.glm.QA.do = true;

% multivariate
opt.pipeline.type = 'stats';

opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
    'models', 'model-FrenchBrailleDecoding_smdl.json');

% MASKS
opt.maskPath = fullfile(WD, 'outputs', 'derivatives', 'cpp_spm-rois');

% Options for normalization (in case they're needed)
opt.funcVoxelDims = [2.6 2.6 2.6];
opt.parallelize.do = false;
opt.parallelize.nbWorkers = 1;
opt.parallelize.killOnExit = true;

%% DO NOT TOUCH
opt = checkOptions(opt);
saveOptions(opt);
% we cannot save opt with opt.mvpa, it crashes

%% univariate options to specify contrasts etc.

opt.result.Steps(1) = returnDefaultResultsStructure();
opt.result.Steps(1).Level = 'subject';

% Specify how you want your output (all the following are on false by default)
opt.result.Steps(1).Output.png = true();
opt.result.Steps(1).Output.csv = true();
opt.result.Steps(1).Output.thresh_spm = true();
opt.result.Steps(1).Output.binary = true();

% MONTAGE FIGURE OPTIONS
opt.result.Steps(1).Output.montage.do = true();
opt.result.Steps(1).Output.montage.slices = -16:2:0; % in mm
% axial is default 'sagittal', 'coronal'
opt.result.Steps(1).Output.montage.orientation = 'axial';
% will use the MNI T1 template by default but the underlay image can be changed.
opt.result.Steps(1).Output.montage.background = ...
    fullfile(spm('dir'), 'canonical', 'avg152T1.nii,1');

opt.result.Steps(1).Output.NIDM_results = true();

%% multivariate options

% define the 4D maps to be used
opt.funcFWHM = 2;

% take the most responsive xx nb of voxels
% opt.mvpa.ratioToKeep = 300; % 100 150 250 350 420

% set which type of ffx results you want to use
opt.mvpa.map4D = {'beta', 't_maps'};

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
