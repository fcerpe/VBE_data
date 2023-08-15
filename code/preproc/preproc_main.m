%% VISual BRAille fMRI data preproccessing 

% main script of the pipeline, first to run.
% A bit redundant, will call preproc.m multiple times with different
% attributes of option
% Ideally there are no hiccups and this script is the only one to run 

clear;
clc;

warning('on')

%% GET PATHS, BIDSSPM, OPTIONS

% add bidspm and init it
addpath '../lib/bidspm'
bidspm;

% get options
opt = preproc_option();

%% Task: visualLocalizer

opt.taskName = 'visualLocalizer';

preproc;


% Parfor allow to simultaneously compute different subjects on different
% cores of the CPU. Make sure you have enough of them and to keep one free
% to multitask
% UNTESTED AS OF 02/08/2023 

% parfor iSub = 1:numel(opt.subjects)
% 
%     bidspm(opt.dir.raw, opt.dir.output, 'subject', ...
%             'action', 'preprocess', ...
%             'participant_label', opt.subjects(iSub), ... 
%             'task', opt.taskName, ...
%             'space', opt.space, ...
%             'options', opt, ...
%             'skip_validation', true);
% end
%% Task: wordsDecoding

opt.taskName = {'wordsDecoding'};

preproc;

% UNTESTED AS OF 02/08/2023 

% Does it intergrate smoothing already? Check
% When should I smooth?
% Try also without smoothing, Zhan's style

% parfor iSub = 1:numel(opt.subjects)
% 
%     bidspm(opt.dir.raw, opt.dir.output, 'subject', ...
%             'action', 'preprocess', ...
%             'participant_label', opt.subjects, ... 
%             'task', opt.taskName, ...
%             'space', opt.space, ...
%             'options', opt, ...
%             'skip_validation', true);
% end


