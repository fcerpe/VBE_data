% This script will download the dataset from the FIL for the block design SPM tutorial
% and will run the basic preprocessing.
%
% (C) Copyright 2019 Remi Gau

clear;
clc;

addpath(fullfile(pwd, 'lib', 'CPP_SPM'));
cpp_spm('init');

opt = preproc_option();

opt.subjects = '001';

bidsCopyInputFolder(opt);

bidsSTC(opt);

bidsSpatialPrepro(opt);

bidsSmoothing(opt);
