%% VISual BRAille fMRI stats

% main script of the pipeline, first to run.
% A bit redundant, will call preproc.m multiple times with different
% attributes of option
% Ideally there are no hiccups and this script is the only one to run 

clear;
clc;

%% GET PATHS, BIDSSPM

% add bidspm and init it
addpath '../lib/bidspm'
bidspm;

%% Localizer stats
% get options
opt = stats_localizer_option();

stats_localizer;

%% MVPA task stats

opt = stats_blockMvpa_option();

stats_blockMvpa;








