function opt = stats_blockMvpa_option()
%
% returns a structure that contains the options chosen by the user to run
% slice timing correction, pre-processing, FFX, RFX.
%
% (C) Copyright 2019 Remi Gau

opt = [];

opt.subjects = {'019','020','021'}; % 002 003 004 005

% Task to analyze - change accordingly
opt.taskName = 'wordsDecoding';

opt.verbosity = 2;
opt.verbose = 2;

% space to analyse
opt.space = 'MNI';

% Drastically improve analysis speed with a simple trick!  
% the F in false stands fo fast
opt.glm.QA.do = false;

% The functional smoothing 
opt.fwhm.func = 2;
opt.fwhm.contrast = 0;

% The directory where the data are located
opt.dir.root = fullfile(fileparts(mfilename('fullpath')), '..', '..');

opt.dir.raw = fullfile(opt.dir.root, 'inputs', 'raw');
opt.dir.derivatives = fullfile(opt.dir.root, 'outputs', 'derivatives');
opt.dir.preproc = fullfile(opt.dir.root, 'outputs', 'derivatives', 'bidspm-preproc');
opt.dir.input = opt.dir.preproc;
opt.dir.roi = fullfile(opt.dir.root, 'outputs', 'derivatives', 'cpp_spm-roi');
opt.dir.stats = fullfile(opt.dir.root, 'outputs', 'derivatives', 'bidspm-stats');

% Model specifies all the contrasts
opt.model.file = fullfile(fileparts(mfilename('fullpath')), '..', ...
    'models', 'model-wordsDecoding_smdl.json');

opt.pipeline.type = 'stats';

% Specify the result to compute
% opt.result.Nodes(1) = defaultResultsStructure();
% 
% opt.result.Nodes(1).Level = 'subject';

% For each contrats, you can adapt:
%  - voxel level (p)
%  - cluster (k) level threshold
%  - type of multiple comparison:
%    - 'FWE' is the defaut
%    - 'FDR'
%    - 'none'

opt.results(1).nodeName = 'run_level';

% Specify how you want your output (all the following are on false by default)
opt.results(1).binary = true();
opt.results(1).montage.do = true();
opt.results(1).montage.background = struct('suffix', 'T1w', 'desc', 'preproc', 'modality', 'anat');
opt.results(1).montage.slices = -20:2:0;
opt.results(1).montage.orientation = 'axial'; % also 'sagittal', 'coronal'
opt.results(1).nidm = true();
opt.results(1).threshSpm = true();
opt.results(1).png = true();
opt.results(1).csv = true();

%% DO NOT TOUCH
opt = checkOptions(opt);
saveOptions(opt);

end
