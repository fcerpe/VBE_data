function opt = stats_blockMvpa_option()
%
% returns a structure that contains the options chosen by the user to run
% slice timing correction, pre-processing, FFX, RFX.
%
% (C) Copyright 2019 Remi Gau

opt = [];

opt.subjects = {'006'}; 

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
opt.fwhm.contrast = 2;

% The directory where the data are located
opt.dir.root = fullfile(fileparts(mfilename('fullpath')), '..', '..');

opt.dir.raw = fullfile(opt.dir.root, 'inputs', 'raw');
opt.dir.derivatives = fullfile(opt.dir.root, 'outputs', 'derivatives');
opt.dir.preproc = fullfile(opt.dir.root, 'outputs', 'derivatives', 'cpp_spm-preproc');
opt.dir.input = opt.dir.preproc;
opt.dir.roi = fullfile(opt.dir.root, 'outputs', 'derivatives', 'cpp_spm-roi');
opt.dir.stats = fullfile(opt.dir.root, 'outputs', 'derivatives', 'cpp_spm-stats');

% Model specifies all the contrasts
opt.model.file = fullfile(fileparts(mfilename('fullpath')), '..', ...
    'models', 'model-wordsDecoding_fourConditions_smdl.json');

opt.pipeline.type = 'stats';

% Specify the result to compute
opt.result.Nodes(1) = defaultResultsStructure();

opt.result.Nodes(1).Level = 'subject';

% For each contrats, you can adapt:
%  - voxel level (p)
%  - cluster (k) level threshold
%  - type of multiple comparison:
%    - 'FWE' is the defaut
%    - 'FDR'
%    - 'none'

% Specify how you want your output (all the following are on false by default)
opt.result.Nodes(1).Output.png = true();
opt.result.Nodes(1).Output.csv = true();
opt.result.Nodes(1).Output.thresh_spm = true();
opt.result.Nodes(1).Output.binary = true();

% MONTAGE FIGURE OPTIONS
opt.result.Nodes(1).Output.montage.do = true();
opt.result.Nodes(1).Output.montage.slices = -20:2:0; % in mm
% axial is default 'sagittal', 'coronal'
opt.result.Nodes(1).Output.montage.orientation = 'axial';
% will use the MNI T1 template by default but the underlay image can be changed.
opt.result.Nodes(1).Output.montage.background = ...
    fullfile(spm('dir'), 'canonical', 'avg152T1.nii');

opt.result.Nodes(1).Output.NIDM_results = true();

%% DO NOT TOUCH
opt = checkOptions(opt);
saveOptions(opt);

end
