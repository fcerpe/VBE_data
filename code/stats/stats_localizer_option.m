function opt = stats_localizer_option()
%
% returns a structure that contains the options chosen by the user to run
% slice timing correction, pre-processing, FFX, RFX.
%
% (C) Copyright 2019 Remi Gau

opt = [];

opt.subjects = {'006','007','008','009'}; % 002 003 004 005

% Task to analyze - change accordingly
opt.taskName = 'viualLocalizer';

opt.verbosity = 1;

% space to analyse
opt.space = 'MNI';

% Drastically improve analysis speed with a simple trick!  
% the F in false stands fo fast
opt.glm.QA.do = false;

% The functional smoothing 
opt.fwhm.func = 6;
opt.fwhm.contrast = 6;

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
    'models', 'model-visualLocalizerUnivariate_smdl.json');

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

% Do it for all of them
% FRENCH WORDS > SCRAMBLED FRENCH WORDS
opt.result.Nodes(1).Contrasts(1).Name = 'french_gt_scrambled';
opt.result.Nodes(1).Contrasts(1).MC =  'none';
opt.result.Nodes(1).Contrasts(1).p = 0.0001;
opt.result.Nodes(1).Contrasts(1).k = 0;

% BRAILLE WORDS > SCRAMBLED BRAILLE WORDS
opt.result.Nodes(1).Contrasts(2).Name = 'braille_gt_scrambled';
opt.result.Nodes(1).Contrasts(2).MC =  'none';
opt.result.Nodes(1).Contrasts(2).p = 0.0001;
opt.result.Nodes(1).Contrasts(2).k = 0;

% LINE DRAWINGS > SCRAMBLED LINE DRAWINGS
opt.result.Nodes(1).Contrasts(3).Name = 'drawing_gt_scrambled';
opt.result.Nodes(1).Contrasts(3).MC =  'none';
opt.result.Nodes(1).Contrasts(3).p = 0.0001;
opt.result.Nodes(1).Contrasts(3).k = 0;

% FRENCH WORDS > SCRAMBLED LINE DRAWINGS
opt.result.Nodes(1).Contrasts(4).Name = 'frWords_gt_scrLines';
opt.result.Nodes(1).Contrasts(4).MC =  'none';
opt.result.Nodes(1).Contrasts(4).p = 0.001;
opt.result.Nodes(1).Contrasts(4).k = 0;

% FRENCH AND BRAILLE WORDS > SCRAMBLED LINE DRAWINGS 
opt.result.Nodes(1).Contrasts(5).Name = 'allWords_gt_scrLines';
opt.result.Nodes(1).Contrasts(5).MC =  'none';
opt.result.Nodes(1).Contrasts(5).p = 0.001;
opt.result.Nodes(1).Contrasts(5).k = 0;

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
