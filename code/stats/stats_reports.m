%% VISual BRAille fMRI stats - further analyses

% main script for perfrom further analyses on the univariate data
%
% Very rudimental script to collect different analyses:  
% - behavioural responses 
%
% - specialization for Braille stimuli in given ROIs
%
% - extract mean levels of univariate activation
% 
% - calculate dice coeffieicents
% 
% More details about each analysis are provided in the corresponding
% section
% All the scripts output a report that is processed by R 
% (scripts for that are in code/visualization), and that can be
% found in the /reports subfolder


clear;
clc;

% GET PATHS, BIDSSPM

% add bidspm and init it
addpath '../lib/bidspm'
addpath '../lib/CPP_BIDS'
bidspm;


%% Behavioural responses
% For the decoding task

% load options 
opt = stats_option_decoding();

% get responses
stats_reports_behaviouralRespones;

%% Pixel-wise distance matrix of stimuli 
% Extract the vectors of pixel information from the backstage code and feed
% it to R to create the RDMs
stats_reports_stimuliPixels;

%% General univariate activation in different areas and for different stimuli
% For all the ROIs determined (V1, LOC, VWFA, PosTemp) calculate the 
% univariate activation for all the decoding experiment stimuli

% load options 
opt = stats_option_decoding();

% get activations
stats_reports_univariateActivation;


%% Braille specialization at different processing stages 
% In localizer activation, look for differences between intact and
% scrambled braille. 
% Already assessed for VWFA, but known for the other ROIs

% load options 
opt = stats_option_localizer();

% get activations
stats_reports_brailleContrasts;


%% Check tSNR for acquired data 
% In localizer activation, look for differences between intact and
% scrambled braille. 
% Already assessed for VWFA, but known for the other ROIs

% load options 
opt = stats_option_localizer();

% get a report of the tSNR in the raw files
stats_reports_tSNR;


%% Calculate DICE coeffiecients 
% In localizer activation, calculate overlap between between [FW > SFW] 
% and [BW > SBW] contrasts

% load options 
opt = stats_option_localizer();

% Calculate DICE 
stats_reports_DICEcoeff;





