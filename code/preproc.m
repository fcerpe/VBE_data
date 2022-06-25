% This script will download the dataset from the FIL for the block design SPM tutorial
% and will run the basic preprocessing.
%
% (C) Copyright 2019 Remi Gau

clear;

warning('off')

% add cpp_spm to the path
addpath(fullfile(pwd, 'lib', 'CPP_SPM'));
initCppSpm;

% check inside if everything is ok before starting the pipeline
opt = preproc_option();

%% GO FOR IT

bidsCopyInputFolder(opt);

bidsSTC(opt);

bidsSpatialPrepro(opt);

% Smoothiing: check which task are we talking about before choosing FWHM
% Localizer: 6 mm (also, default)
% MVPA (aka event-related): 2 mm
if strcmp(opt.taskName, 'wordsDecoding')

    % set the smmothing to 2mm instead of 6 (default)
    opt.fwhm.func = 2;
    opt.fwhm.contrast = 2;

end

bidsSmoothing(opt);
