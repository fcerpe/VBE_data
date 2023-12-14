%% VISual BRAille fMRI data preproccessing 

% main script of the pipeline, first to run.
% A bit redundant, will call preproc.m multiple times with different
% attributes of option
% Ideally there are no hiccups and this script is the only one to run 

clear;
clc;

warning('on')

% GET PATHS, BIDSSPM, OPTIONS

% add bidspm and init it
addpath '../lib/bidspm'
bidspm;


%% Task: visualLocalizer

% get options
opt = preproc_localizer_option();

% overwrite task name. Bidspm standard forces a 'cell' value, new call to
% bidspm wants a 'char' array
opt.taskName = 'visualLocalizer';

% Copy inputs nifti files from inputs/raw to derivatives/bidspm-preproc.
% Needed to get information about the acquisitions (e.g. RepetitionTime)
% 'parfor' skips this step, so execute it outside the parallel loop
bidsCopyInputFolder(opt);

% Run multiple participants at the same time, one per CPU core
% For more info, check 'parallel computing toolbox' and 
% https://bidspm.readthedocs.io/en/latest/FAQ.html#
for iSub = 1:numel(opt.subjects)

    % preprocessing
    bidspm(opt.dir.raw, opt.dir.output, ...
            'action', 'preprocess', ...
            'participant_label', opt.subjects(iSub), ... 
            'task', opt.taskName, ...
            'space', opt.space, ...
            'options', opt, ...
            'skip_validation', true);

    % smoothing
    bidspm(opt.dir.raw, opt.dir.output, ...
           'participant_label', opt.subjects(iSub), ...
           'action', 'smooth', ...
           'task', opt.taskName, ...
           'space', opt.space, ...
           'options', opt);
end

% MATLAB can appear being done (e.g. '>>' in the command window and no
% 'busy' message) while it's still running tasks. The following message is
% meant to be a signal that the preprocessing is officially done
fprintf('\n\nLOCALIZER PIPELINE DONE\n\n')

%% Task: wordsDecoding

% Change paramters according to MVPA task and its needs (e.g. smoothing of
% 2mm instead of 6mm)
opt = preproc_decoding_option();

% overwrite format of task name
opt.taskName = 'wordsDecoding';

% Copy nifti to preproc folder
bidsCopyInputFolder(opt);

parfor iSub = 1:numel(opt.subjects)

    % preprocessing
    bidspm(opt.dir.raw, opt.dir.output, ...
            'action', 'preprocess', ...
            'participant_label', opt.subjects(iSub), ... 
            'task', opt.taskName, ...
            'space', opt.space, ...
            'options', opt, ...
            'skip_validation', true);

%     % smoothing 
%     bidspm(opt.dir.raw, opt.dir.output, ...
%            'participant_label', opt.subjects(iSub), ...
%            'action', 'smooth', ...
%            'task', opt.taskName, ...
%            'space', opt.space, ...
%            'options', opt);
end

% Temporarily perform smoothing outside the parfor loop. 
% If done inside, it's forced at 6mm.
bidsSmoothing(opt);

% Nofity the user
fprintf('\n\nDECODING PIPELINE DONE\n\n')

