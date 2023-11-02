%% MULTIDIMENSIONAL SCALING
% Visual representation of relationshiips between stimuli categories 
%
% Adapted from scripts of Iqra and Ineke

%% Clean workspace, load cosmo and bidspm, load options 

clear;
clc;

% GET PATHS, BIDSPM, OPTIONS
warning('on');

% cosmo
cosmo = '~/Applications/CoSMoMVPA-master';
addpath(genpath(cosmo));
cosmo_warning('once');

% libsvm
libsvm = 'Users/Applications/libsvm';
addpath(genpath(libsvm));

% verify it worked
cosmo_check_external('libsvm'); % should not give an error

% bisdpm
bidspm;

% load options
opt = mvpa_option();

%% Adjust dataset 











