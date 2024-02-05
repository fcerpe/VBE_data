function opt = mvpa_option_languageROIs()
% returns a structure that contains the options chosen by the user to run
% bidsConcat and also Decoding (two scripts)

if nargin < 1
    opt = [];
end

% Sujects to run 
% Subgroup of total subject pool, some do not present any lPosTemp
% activation
opt.subjects = {'006','007','008','009','010','011','013','018','019','020','021','023','024','027','028'};
% Group name for filename
opt.groupName = 'all';

% Which groups can be processed? 
opt.groups = {'experts', 'controls'};

% Also, determine sub groups, for cross-script decoding
opt.subGroups.experts = {'006','007','008','009','013'};
opt.subGroups.controls = {'010','011','018','019','020','021','023','024','027','028'};

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
                     '021', [2  4  6  8 10 12  1  3  5  7  9 11];
                     '022', [2  4  6  8 10 12  1  3  5  7  9 11];
                     '023', [1  3  5  7  9 11  2  4  6  8 10 12];
                     '024', [2  4  6  8 10 12  1  3  5  7  9 11];
                     '026', [2  4  6  8 10 12  1  3  5  7  9 11];
                     '027', [1  3  5  7  9 11  2  4  6  8 10 12];
                     '028', [1  3  5  7  9 11  2  4  6  8 10 12]};

% Determine the decoding conditions 
% (used both for final filename and in mvpa_assignDecodingConditions
% - pairwise: RW-PW, RW-NW, RW-FS, PW-NW, PW-FS, NW-FS              
% - multiclass: RW-PW-NW-FS
% Also determine the modality, within or cross
opt.decodingCondition = 'pairwise';
opt.decodingModality = 'within';

% ROI method (empty = default = intersection between expansion and neurosynth, 'expansionIntersection' for short)
% - expansion: VWFA, lLO, rLO
% - language: l-PosTemp
% - split: antVWFA, posVWFA
% - splitAtlas: uses VWFA splitted according to atlas (undefined)
% - earlyVisual: V1
opt.roiMethod = 'language';

% Uncomment the lines below to run preprocessing
% - don't use realign and unwarp
opt.realign.useUnwarp = true;

% we stay in native space (that of the T1)
opt.space = 'IXI549Space'; % 'individual', 'MNI'

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
    'models', 'model-wordsDecoding_smdl.json');

opt.result.Nodes(1) = defaultResultsStructure();

% Options for normalization (in case they're needed)
opt.funcVoxelDims = [2.6 2.6 2.6];
opt.parallelize.do = false;
opt.parallelize.nbWorkers = 1;
opt.parallelize.killOnExit = true;

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
opt.mvpa.permutate = 1;

end
