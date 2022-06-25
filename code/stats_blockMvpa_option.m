function opt = stats_blockMvpa_option()
%
% returns a structure that contains the options chosen by the user to run
% slice timing correction, pre-processing, FFX, RFX.
%
% (C) Copyright 2019 Remi Gau

opt = [];

opt.subjects = {'002','003','005'}; 
% '004' is weird

% Task to analyze - change accordingly
opt.taskName = 'wordsDecoding';

opt.verbosity = 1;

% space to analyse
opt.space = 'MNI';

% Drastically improve analysis speed with a simple trick!  
% the F in false stands fo fast
opt.glm.QA.do = false;

% The functional smoothing 
opt.fwhm.func = 2;
opt.fwhm.contrast = 2;

% The directory where the data are located
opt.dir.root = fullfile(fileparts(mfilename('fullpath')), '..');

opt.dir.raw = fullfile(opt.dir.root, 'inputs', 'raw');
opt.dir.derivatives = fullfile(opt.dir.root, 'outputs', 'derivatives');
opt.dir.preproc = fullfile(opt.dir.root, 'outputs', 'derivatives', 'cpp_spm-preproc');
opt.dir.input = opt.dir.preproc;
opt.dir.roi = fullfile(opt.dir.root, 'outputs', 'derivatives', 'cpp_spm-roi');
opt.dir.stats = fullfile(opt.dir.root, 'outputs', 'derivatives', 'cpp_spm-stats');

% Model specifies all the contrasts
opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
    'models', 'model-wordsDecoding_fourConditions_smdl.json');

opt.pipeline.type = 'stats';

% Specify the result to compute
opt.result.Nodes(1) = returnDefaultResultsStructure();

opt.result.Nodes(1).Level = 'subject';

% For each contrats, you can adapt:
%  - voxel level (p)
%  - cluster (k) level threshold
%  - type of multiple comparison:
%    - 'FWE' is the defaut
%    - 'FDR'
%    - 'none'

% % Do it for all of them
% % FRENCH
% % REAL WORDS > FAKE SCRIPT 
% opt.result.Nodes(1).Contrasts(1).Name = 'frw_gt_ffs';   opt.result.Nodes(1).Contrasts(1).MC =  'none';
% opt.result.Nodes(1).Contrasts(1).p = 0.001;             opt.result.Nodes(1).Contrasts(1).k = 0;
% 
% % REAL WORDS > NON WORDS
% opt.result.Nodes(1).Contrasts(2).Name = 'frw_gt_fnw';   opt.result.Nodes(1).Contrasts(2).MC =  'none';
% opt.result.Nodes(1).Contrasts(2).p = 0.001;             opt.result.Nodes(1).Contrasts(2).k = 0;
% 
% % REAL WORDS > PSEUDO WORDS 
% opt.result.Nodes(1).Contrasts(3).Name = 'frw_gt_fpw';   opt.result.Nodes(1).Contrasts(3).MC =  'none';
% opt.result.Nodes(1).Contrasts(3).p = 0.001;             opt.result.Nodes(1).Contrasts(3).k = 0;
% 
% % PSEUDO WORDS > FAKE SCRIPT
% opt.result.Nodes(1).Contrasts(4).Name = 'fpw_gt_ffs';   opt.result.Nodes(1).Contrasts(4).MC =  'none';
% opt.result.Nodes(1).Contrasts(4).p = 0.001;             opt.result.Nodes(1).Contrasts(4).k = 0;
% 
% % PSEUDO WORDS > NON WORDS
% opt.result.Nodes(1).Contrasts(5).Name = 'fpw_gt_fnw';   opt.result.Nodes(1).Contrasts(5).MC =  'none';
% opt.result.Nodes(1).Contrasts(5).p = 0.001;             opt.result.Nodes(1).Contrasts(5).k = 0;
% 
% % NON WORDS > FAKE SCRIPT
% opt.result.Nodes(1).Contrasts(6).Name = 'fnw_gt_ffs';   opt.result.Nodes(1).Contrasts(6).MC =  'none';
% opt.result.Nodes(1).Contrasts(6).p = 0.001;             opt.result.Nodes(1).Contrasts(6).k = 0;
% 
% % BRAILLE
% % REAL WORDS > FAKE SCRIPT 
% opt.result.Nodes(1).Contrasts(7).Name = 'brw_gt_bfs';   opt.result.Nodes(1).Contrasts(7).MC =  'none';
% opt.result.Nodes(1).Contrasts(7).p = 0.001;             opt.result.Nodes(1).Contrasts(7).k = 0;
% 
% % REAL WORDS > NON WORDS
% opt.result.Nodes(1).Contrasts(8).Name = 'brw_gt_bnw';   opt.result.Nodes(1).Contrasts(8).MC =  'none';
% opt.result.Nodes(1).Contrasts(8).p = 0.001;             opt.result.Nodes(1).Contrasts(8).k = 0;
% 
% % REAL WORDS > PSEUDO WORDS
% opt.result.Nodes(1).Contrasts(9).Name = 'brw_gt_bpw';   opt.result.Nodes(1).Contrasts(9).MC =  'none';
% opt.result.Nodes(1).Contrasts(9).p = 0.001;             opt.result.Nodes(1).Contrasts(9).k = 0;
% 
% % PSEUDO WORDS > FAKE SCRIPT
% opt.result.Nodes(1).Contrasts(10).Name = 'bpw_gt_bfs';   opt.result.Nodes(1).Contrasts(10).MC =  'none';
% opt.result.Nodes(1).Contrasts(10).p = 0.001;             opt.result.Nodes(1).Contrasts(10).k = 0;
% 
% % PSEUDO WORDS > FAKE SCRIPT
% opt.result.Nodes(1).Contrasts(11).Name = 'bpw_gt_bnw';   opt.result.Nodes(1).Contrasts(11).MC =  'none';
% opt.result.Nodes(1).Contrasts(11).p = 0.001;             opt.result.Nodes(1).Contrasts(11).k = 0;
% 
% % NON WORDS > FAKE SCRIPT
% opt.result.Nodes(1).Contrasts(12).Name = 'bnw_gt_bfs';   opt.result.Nodes(1).Contrasts(12).MC =  'none';
% opt.result.Nodes(1).Contrasts(12).p = 0.001;             opt.result.Nodes(1).Contrasts(12).k = 0;

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
