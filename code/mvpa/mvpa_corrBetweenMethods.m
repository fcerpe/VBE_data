%% Correlations between different methods and ROIs
%
% From several cosmomvpa outputs, alrrady passed through mvpa_readableMatrix,
% to correlations and triangular matrices (half-RDM)

% nice and spotless
clear;
clc;

warning('on')

% add spm to the path
addpath(fullfile(pwd, '..', 'lib', 'bidspm'));
addpath(fullfile(pwd, '..', 'lib', 'CPP_BIDS'));
bidspm;

opt = mvpa_option();

% go into derivatives/CoSMoMVPA to see how many decodings we have
filesToProcess = dir('../../outputs/derivatives/CoSMoMVPA/task-wordsDecoding_*.mat');

%% Load files and extract information

% save all the names of the variables that we'll put in a separate mat file
% to avoid loading everything all the time
varsToSave = {};

for ftp = 1:length(filesToProcess)

    load(fullfile(filesToProcess(ftp).folder, filesToProcess(ftp).name));
    filename = filesToProcess(ftp).name;
    filename = filename(1:end-4);

    % for each mvpa_results.mat (each RDM), take the bottom triangle
    rdmList = fieldnames(mvpa_results.mat);

    for rl = 1:length(rdmList)

        thisRDMname = rdmList{rl};
        splitName = split(thisRDMname,'_');
        thisSub = splitName{1}; thisROI = splitName{2}; thisImage = splitName{3};

        % get the current RDM
        eval(['thisRDM = mvpa_results.mat.' thisRDMname ';']);

        thisRDMtri = thisRDM(triu(true(size(thisRDM)),1));

        % remove NaNs
        thisRDMvalues = thisRDMtri(not(isnan(thisRDMtri)));

        % split according to script: first 6 values are french, last 6 are braille
        thisRDMfrench = thisRDMvalues(1:6);
        thisRDMbraille = thisRDMvalues(7:12);

        % save new elements into mvpa_results
        eval(['mvpa_results.tri.' thisRDMname ' = thisRDMtri;']);
        eval(['mvpa_results.values.' thisRDMname ' = thisRDMvalues;']);
        eval(['mvpa_results.french_decoding.' thisRDMname ' = thisRDMfrench;']);
        eval(['mvpa_results.braille_decoding.' thisRDMname ' = thisRDMbraille;']);

    end

    % save a copy of this results matrix
    nameDetails = split(filename,{'_','-'});
    if startsWith(nameDetails{5},'expand')
        varName = [nameDetails{4}, '_', nameDetails{5},'_',nameDetails{11},'vx'];
    else
        varName = [nameDetails{4}, '_', nameDetails{5},'_',nameDetails{6}];
    end
    eval([varName ' = mvpa_results;']);

    varsToSave = vertcat(varsToSave, varName);

    % save original matrix
    save([opt.dir.cosmo, '/', filename,'.mat'],'accu','mvpa_results');
    % append this mvpa_results to the others
    if ftp == 1
        save('mvpa_correlations.mat', varName);
    else
        save('mvpa_correlations.mat', varName,'-append');
    end
  
end

% close everything
clear;

%% Open the newly-saved matrices and calculate correlations

% open it again
load('mvpa_correlations.mat');

methodsToCorr = whos('-file','mvpa_correlations.mat');

for im = 2:4
    thisMethodName = methodsToCorr(im).name;

    eval(['thisMethod = ' thisMethodName ';']);

    % Correlations between areas within a method (same image)
    [thisMethod.correlations.corrBetweenAreas_beta, ...
     thisMethod.correlations.pvalBetweenAreas_beta] = corrcoef([thisMethod.values.average_VWFAfr_beta, ...
                                                              thisMethod.values.average_VWFAbr_beta, ...
                                                              thisMethod.values.average_lLO_beta, ...
                                                              thisMethod.values.average_lpFS_beta, ...
                                                              thisMethod.values.average_rLO_beta, ...
                                                              thisMethod.values.average_rpFS_beta]); 

    [thisMethod.correlations.corrBetweenAreas_tmap, ...
     thisMethod.correlations.pvalBetweenAreas_tmap] = corrcoef([thisMethod.values.average_VWFAfr_tmap, ...
                                                              thisMethod.values.average_VWFAbr_tmap, ...
                                                              thisMethod.values.average_lLO_tmap, ...
                                                              thisMethod.values.average_lpFS_tmap, ...
                                                              thisMethod.values.average_rLO_tmap, ...
                                                              thisMethod.values.average_rpFS_tmap]); 

    % Correlations between images within a method
    % concatenate values of the same image
    betaValues = vertcat(thisMethod.values.average_VWFAfr_beta, thisMethod.values.average_VWFAbr_beta, ...
                         thisMethod.values.average_lLO_beta,    thisMethod.values.average_lpFS_beta, ...
                         thisMethod.values.average_rLO_beta,    thisMethod.values.average_rpFS_beta);
    tmapValues = vertcat(thisMethod.values.average_VWFAfr_tmap, thisMethod.values.average_VWFAbr_tmap, ...
                         thisMethod.values.average_lLO_tmap,    thisMethod.values.average_lpFS_tmap, ...
                         thisMethod.values.average_rLO_tmap,    thisMethod.values.average_rpFS_tmap);

    [thisMethod.correlations.corrBetweenImages, ...
     thisMethod.correlations.pvalBetweenImages] = corrcoef(betaValues, tmapValues);

    % Correlation between scripts within VWFA
    [thisMethod.correlations.corrBetweenScripts_beta, ...
     thisMethod.correlations.pvalBetweenScripts_beta] = corrcoef(thisMethod.french_decoding.average_VWFAfr_beta, ...
                                                                 thisMethod.braille_decoding.average_VWFAfr_beta); 

    [thisMethod.correlations.corrBetweenScripts_tmap, ...
     thisMethod.correlations.pvalBetweenScripts_tmap] = corrcoef(thisMethod.french_decoding.average_VWFAfr_tmap, ...
                                                                 thisMethod.braille_decoding.average_VWFAfr_tmap); 

    % save everything in the method's matrix
    eval([thisMethodName '.correlations = thisMethod.correlations;']);

end

% save (again) the matrix with the new additions
save('mvpa_correlations.mat', ...
     'individual_expand_34vx', 'individual_sphere_marsbar', 'individual_sphere_10mm', ...
     'individual_sphere_8mm', 'neurosynth_sphere_10mm');





