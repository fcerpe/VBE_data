function opt = mvpa_blockMvpa_option()
% returns a structure that contains the options chosen by the user to run
% bidsConcat and also Decoding (two scripts)

if nargin < 1
    opt = [];
end

% suject to run in each group
opt.subjects = {'006','007'}; % 004

% specify the order of the runs where we can find the following conditions
% French - Braille: 003 006 008
% Braille - French: 002 004 007 009
%                            f  f  f  f  f  f  b  b  b  b  b  b
opt.subsCondition = {'006', [1  3  5  7  9 11  2  4  6  8 10 12];
                     '007', [2  4  6  8 10 12  1  3  5  7  9 11];
                     };
%                     '008', [1  3  5  7  9 11  2  4  6  8 10 12];
%                     '009', [2  4  6  8 10 12  1  3  5  7  9 11]

% assign the condition to decode, changes based on our aims
% - french_v_braille: simple script decoding
% - within_script: frw v. fpw v. fnw v. ffs; 
%                  brw v. bpw v. bnw v. bfs
% - all: frw, fpw, fnw, ffs, brw, bpw, bnw, bfs all against each other,
%        RDM-style
opt.decodingCondition = {'within_script'};

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
opt.taskName = 'wordsDecoding';

% PATHS
% The directory where the data are located
opt.dir.root = fullfile(fileparts(mfilename('fullpath')), '..', '..');

opt.dir.raw = fullfile(opt.dir.root, 'inputs', 'raw');
opt.dir.derivatives = fullfile(opt.dir.root, 'outputs', 'derivatives');
opt.dir.preproc = fullfile(opt.dir.root, 'outputs', 'derivatives', 'cpp_spm-preproc');
opt.dir.input = opt.dir.preproc;
opt.dir.rois = fullfile(opt.dir.root, 'outputs', 'derivatives', 'cpp_spm-rois');
opt.dir.stats = fullfile(opt.dir.root, 'outputs', 'derivatives', 'cpp_spm-stats');
opt.dir.cosmo = fullfile(opt.dir.root, 'outputs', 'derivatives', 'CoSMoMVPA');

% Suffix output directory for the saved jobs
opt.jobsDir = fullfile(opt.dir.stats, 'jobs', opt.taskName);
opt.glm.QA.do = false;

% multivariate
opt.pipeline.type = 'stats';

opt.model.file = fullfile(opt.dir.root, 'code', ...
    'models', 'model-wordsDecoding_fourConditions_smdl.json');

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
opt.fwhm.func = 2;
opt.fwhm.contrast = 2;

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
