%% VISual BRAille ROI creation 
%
% main script of the pipeline, to be run after preproc_main,
% stas_main 
% Ideally there are no hiccups and this script is the only one to run 

clear;
clc;

%% GET PATHS, BIDSSPM, OPTIONS

% add bidspm and init it
addpath '../lib/bidspm'
bidspm;

% get options
opt = roi_option();

%% Select the ROIs based on the functional localizers 

% Extract the following ROIs based contrasts coming from the functional localizers
% - VWFAfr, [french words] - [scrambled french words]
% - VWFAbr, [braille words] - [scrambled braille words] * Skipped for now
% - lLO,    [line drawings] - [scrambled line drawings]
% - rLO,    [line drawings] - [scrambled line drawings]
% - V1,     [all] - [rest] * To be implemented

roi_createROIs; 

% Extract ROIs based on results from language localizer of Fedorenko et al.
% (TBD)
% roi_languageAreas;

%% Resolve possible overlaps between neighbouring areas

roi_resolveOverlaps; 

%% Split VWFA between anterior and posterior

% Consider all subjects (i.e. don't change subjects pool). 
% Control group can be informativve for french stimuli
% opt.subjects = {'006','007','008','009','012','013'};
roi_splitVWFA;

