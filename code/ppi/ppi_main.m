%% VISual BRAille PPI analysis 
%
% main script of the pipeline.
% More details to come

% All the steps mimick what is indicated in the ppi_instruction.txt file,
% which is a trasnscription of the SPM 12 manual - chapter 37

clear;
clc;

%% GET PATHS, BIDSSPM, OPTIONS

% add bidspm and init it
addpath '../lib/bidspm'
bidspm;

% get options
opt = ppi_option();

%% Estimate GLM as indicated by SPM Manual
%
% Perform univariate stats on Localizer
% Runs a modified version of bidspm code, to allow for concatenation of
% diferent runs into one, in order to extract timeseries information
ppi_1stLevelConcat

% Extract the VOIs for each area 
ppi_extractVOIs

% (perform the PPI)
ppi_doPPI

% Visualizetion (on matlab)
ppi_visualizeCorrelations