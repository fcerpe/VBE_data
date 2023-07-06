function opt = mvpa_option()
% returns a structure that contains the options chosen by the user to run
% bidsConcat and also Decoding (two scripts)

if nargin < 1
    opt = [];
end

% suject to run in each group
% Specifiy which group is being analysed, to ease comprehension 

% All available subjects
% opt.subjects = {'006','007','008','009','010','011','012','013','018','019','020','021'};

% Only experts
opt.subjects = {'006','007','008','009','012','013'};
opt.groupName = {'experts'};

% Only controls
% opt.subjects = {'010','011','018','019','020','021'};
% opt.groupName = {'controls'};

% specify the order of the runs where we can find the following conditions
%                            F  F  F  F  F  F  B  B  B  B  B  B
opt.subsCondition = {'006', [1  3  5  7  9 11  2  4  6  8 10 12];
                     '007', [2  4  6  8 10 12  1  3  5  7  9 11];
                     '008', [1  3  5  7  9 11  2  4  6  8 10 12];
                     '009', [2  4  6  8 10 12  1  3  5  7  9 11];
                     '010', [1  3  5  7  9 11  2  4  6  8 10 12];
                     '011', [2  4  6  8 10 12  1  3  5  7  9 11];
                     '012', [1  3  5  7  9 11  2  4  6  8 10 12];
                     '013', [2  4  6  8 10 12  1  3  5  7  9 11];
                     '018', [1  3  5  7  9 11  2  4  6  8 10 12];
                     '019', [2  4  6  8 10 12  1  3  5  7  9 11];
                     '020', [1  3  5  7  9 11  2  4  6  8 10 12];
                     '021', [2  4  6  8 10 12  1  3  5  7  9 11]};

% assign the condition to decode, changes based on our aims.
% Will influence mvpa_assignDecodingConditions
%
% - french-braille: simple script decoding
%
% - pairwise-within-script: frw v. fpw, frw v. fnw, frw v. ffs, fpw v. fnw, fpw v. ffs, fnw v. ffs 
%                           brw v. bpw, brw v. bnw, brw v. bfs, bpw v. bnw, bpw v. bfs, bnw v. bfs
%
% - four-way-classification-within: frw v. fpw v. fnw v. ffs
%                                   brw v. bpw v. bnw v. bfs
%
% - linguistic-condition: frw+brw v. fpw+bpw v. fnw+bnw v. ffs+bfs
%
% - crossmodal: not yet implemented
%
% - all: frw v. fpw v. fnw v. ffs v. brw v. bpw v. bnw v. bfs 
%
% - cross-script: [ONLY FOR mvpa_crossScriptDecoding] train on f/b, test on
%                  b/f

opt.decodingCondition = {'pairwise-within-script'};

% Uncomment the lines below to run preprocessing
% - don't use realign and unwarp
opt.realign.useUnwarp = true;

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
opt.pipeline.type = 'stats';

% Model specifies all the contrasts
opt.model.file = fullfile(fileparts(mfilename('fullpath')), '..', ...
    'models', 'model-wordsDecoding_fourConditions_smdl.json');

% Options for normalization (in case they're needed)
opt.funcVoxelDims = [2.6 2.6 2.6];
opt.parallelize.do = false;
opt.parallelize.nbWorkers = 1;
opt.parallelize.killOnExit = true;

% ROI method (empty = default = intersection between expansion and neurosynth, 'expansionIntersection' for short)
opt.roiMethod = 'expansionIntersection';

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
opt.mvpa.map4D = {'beta','tmap'};

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
