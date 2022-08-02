function opt = preproc_option()
%
% returns a structure that contains the options chosen by the user to run
% slice timing correction, pre-processing, FFX, RFX.
%
% (C) Copyright 2019 Remi Gau

opt = [];

% task to analyze: alternate
opt.taskName = 'wordsDecoding';
% opt.taskName = 'visualLocalizer';

% who will be preprocessed?
opt.subjects = {'006', '007', '008'}; % ,'002','004','005'

% space is not important now, if not specified, do it for both individual and MNI
opt.space = 'MNI';

opt.pipeline.type = 'preproc';

% The directory where the data are located
opt.dir.root = fullfile(fileparts(mfilename('fullpath')), '..');
opt.dir.raw = fullfile(opt.dir.root, 'inputs', 'raw');
opt.dir.derivatives = fullfile(opt.dir.root, 'outputs', 'derivatives');


%% DO NOT TOUCH
opt = checkOptions(opt);
saveOptions(opt);

end
