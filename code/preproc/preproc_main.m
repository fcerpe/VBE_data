%% VISual BRAille fMRI data preproccessing 

% main script of the pipeline, first to run.
% A bit redundant, will call preproc.m multiple times with different
% attributes of option
% Ideally there are no hiccups and this script is the only one to run 

clear;
clc;

%% GET PATHS, BIDSSPM, OPTIONS

% add bidspm and init it
addpath '../lib/bidspm'
bidspm;

% get options
opt = preproc_option();

%% Task: visualLocalizer

opt.taskName = 'visualLocalizer';
preproc; 

%% Task: wordsDecoding

opt.taskName = 'wordsDecoding';
preproc;


