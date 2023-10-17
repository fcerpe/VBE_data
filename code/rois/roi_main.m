%% VISual BRAille ROI creation 
%
% main script of the pipeline, to be run after preproc_main,
% stas_main 
% Ideally there are no hiccups and this script is the only one to run 

clear;
clc;

% GET PATHS, BIDSSPM, OPTIONS

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
% - V1      [all] - [rest] ((WIP))

roi_createROIs; 

%% Resolve possible overlaps between neighbouring areas

roi_resolveOverlaps; 

%% Split VWFA between anterior and posterior

% Consider all subjects (i.e. don't change subjects pool). 
roi_splitVWFA;

%% Extract ROIs based on language localizer of Fedorenko et al.
% Extract parcels from Fedorenko et al.'s localzier
%
% Use those parcels to create subject level ROIs:
% - just the mask resliced to the participant's reference
% - intersections of mask and [french words] - [scrambled french words]
%
% Generate and elaborate a report to show which subjects present which
% areas and plot a 'consensus' over the activated areas.
% Consensus will be used in PPI
roi_createLanguageROIs;


%% Extract V1 ROIs based on visfatlas 

roi_createV1ROIs;



