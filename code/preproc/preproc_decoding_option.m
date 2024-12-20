function opt = preproc_decoding_option()
%
% returns a structure that contains the options chosen by the user to run
% slice timing correction, pre-processing, FFX, RFX.
%
% (C) Copyright 2019 Remi Gau

opt = [];

% task to analyze
opt.taskName = 'wordsDecoding';

% who will be preprocessed?
opt.subjects = {'007','008','009','010','011','012','013','017','018','019','020','021','022','023','024','025','026','027','028'};  
% possible participants: 
% '006','007','008','009','010','011','012','013','017','018','019','020',
% '021','022','023','024','025','026','027','028'

% space is not important now, if not specified, do it for both individual and MNI
opt.space = {'MNI'};

opt.pipeline.type = 'preproc';

% Define how to reslice the images and the resolution
opt.funcVoxelDims = [2.600 2.600 2.600];

% The functional smoothing 
opt.fwhm.func = 2;
opt.fwhm.contrast = 0;

% The directory where the data are located
opt.dir.root = fullfile(fileparts(mfilename('fullpath')), '..', '..');
opt.dir.raw = fullfile(opt.dir.root, 'inputs', 'raw');
opt.dir.derivatives = fullfile(opt.dir.root, 'outputs', 'derivatives');

opt.segment.force = true;


%% DO NOT TOUCH
opt = checkOptions(opt);
saveOptions(opt);

end
