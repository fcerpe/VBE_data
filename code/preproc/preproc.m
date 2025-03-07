% This script will download the dataset from the FIL for the block design SPM tutorial
% and will run the basic preprocessing.
%
% (C) Copyright 2019 Remi Gau

%% GO FOR IT

bidsCopyInputFolder(opt);

bidsSTC(opt);

bidsSpatialPrepro(opt);

% Smoothiing: check which task are we talking about before choosing FWHM
% Localizer: 6 mm (also, default)
% MVPA (aka event-related): 2 mm
if strcmp(opt.taskName, 'wordsDecoding') || strcmp(opt.taskName, 'visualEventRelated')

    % set the smmothing to 2mm instead of 6 (default)
    opt.fwhm.func = 2;
    opt.fwhm.contrast = 0;

end

bidsSmoothing(opt);
