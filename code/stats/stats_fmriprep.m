% This script will run the FFX and contrasts on it of the MoAE dataset
%
% Results might be a bit different from those in the manual as some
% default options are slightly different in this pipeline
% (e.g use of FAST instead of AR(1), motion regressors added)
%
% (C) Copyright 2023 Remi Gau

clear;
clc;

warning('on');

% add spm to the path
addpath(fullfile(pwd, '..', 'lib', 'bidspm'));
addpath(fullfile(pwd, '..', 'lib', 'CPP_BIDS'));
bidspm;

% check inside if everything is ok before starting the pipeline
opt = stats_fmriprep_option();

%% Smooth data
bidsSmoothing(opt);

%% Stats based on .json model file
% check stats_localizer_option for details

bidsFFX('specifyAndEstimate', opt);
 
bidsFFX('contrasts', opt);

bidsResults(opt);

%% Group analysis
% Soon
% 
% bidsRFX('smoothContrasts', opt);
% bidsRFX('RFX', opt);

%% TASK - visualLocalizer
%
% Will perform stats and results for selected contrasts on the localizer
% runs
% Details of the contrasts are in stats_fmriprep_option
   
%% Stats - subject level
%
% All parameters are set in stats_fmriprep_option()
% Different from prvious way of running bidspm, but the output is the same
% (fingers crossed).
% More info on this usage method on: 
% https://bidspm.readthedocs.io/en/latest/usage_notes.html

bidspm(opt.dir.raw, opt.dir.output, ...                
        'subject', ...                                  
        'action', 'stats', ...                          
        'participant_label', opt.subjects, ...
        'preproc_dir', opt.dir.preproc, ...
        'model_file', opt.model.file, ...
        'dry_run', opt.dryRun, ...
        'verbosity', opt.verbosity, ...
        'space', opt.space, ...
        'fwhm', opt.fwhm.func);

%% Results - subject level

% prepare to print the results
% results = defaultResultsStructure();
% 
% opt.subjects = cell(1,1);
% 
% results.nodeName = 'subject_level';
% results.name = {'static', 'motion', 'motion_gt_static', 'static_gt_motion'};
% results.MC = 'none';
% results.p = 0.001;
% results.k = 0;
% results.threshSpm = true();
% results.png = false();
% results.csv = true();
% results.binary = true();
% results.nidm = false();
% results.montage.do = true();
% results.montage.slices = -50:10:50;
% results.montage.orientation = 'axial';
% results.montage.background = struct('sub', opt.subjects{1}, ...
%                                     'suffix', 'T1w', ...
%                                     'desc', 'preproc', ...
%                                     'modality', 'anat');
% 
% results(2) = results;
% results(2).MC = 'FWE';
% results(2).p = 0.05;
% 
% opt.results = results;

bidspm(opt.dir.raw, opt.dir.output, 'subject', ...
       'action', 'results', ... 
       'participant_label', opt.subjects, ...
       'preproc_dir', opt.dir.preproc, ...
       'model_file', opt.model.file, ...
       'dry_run', opt.dryRun, ...
       'verbosity', 3, ...
       'space', opt.space, ...
       'fwhm', opt.fwhm.func, ...
       'options', opt);


%% TASK - wordsDecoding
%
% Will perform stats and concatenation into 4D images on the mvpa runs
% No results are planned so far, will probably be implemented later
% If present, details of the contrasts are in stats_fmriprep_option
   
