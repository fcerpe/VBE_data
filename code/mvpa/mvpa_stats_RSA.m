function opt = mvpa_stats_RSA(opt)
%% Representational similraity analysis and non-parametric statistics
%
% Compute non-paramteric statistical significance of multiclass mvpa decoding,
% combining permutations and boot-strapping
%
% Steps:
% - Obtain permutations:
%   decoding accuracies also contain permutation (shuffling) of labels
%   This step was repeated 100 times for each subject.
%
% - Boot-strap premutations
%   from each subject's null distribution, choose one random value and
%   average across participants
%   Repeat 100k times to get null distribution of 100k values
%
% - Compute statistical significance
%   compare observed results to group-level null distribution
%
% - Correct for multiple comparisons
%   using false discovery rate (FDR) correction


%% Get decoding output file

% To identify the file, we only need to know which decoding (multiclass)
% was performed on which ROIs (expansion / language / early visual)
fileToLoad = dir(fullfile(opt.dir.cosmo, ...
                          ['decoding-', opt.decodingCondition, ...
                          '_modality-', opt.decodingModality, ...
                          '*_rois-', opt.roiMethod, '_nbvoxels-*.mat']));

% There should only corresponding to the condition-modality pair
if size(fileToLoad,1) > 1
    error('There are too many files, check the mvpa folder')
end

% Load file
res = load(fullfile(fileToLoad.folder, fileToLoad.name));
res = res.accu;

% Extract from accuracies:
% - which ROIs
roiList = unique({res.mask});

% - how many voxels were used for feature selection
nbVoxels = unique([res.choosenVoxNb]);

% - which decoding conditions are tested
decodingCondition = unique({res.decodingCondition});

% Specify case-specific parameters
nbIterations = 100000;

% RDMs: set groups-script and the conditions to compare
% Group names = 1: EXP-FR
%               2: EXP-BR
%               3: CTR-FR
%               4: CTR-BR
%               5: MODEL
rdmComparisons = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];
modelComparisons = [1 5; 2 5; 3 5; 4 5];

% Set output structure
statsResults = struct('mask', [], ...
                      'image', [], ...
                      'group1', [], ...
                      'group2', [], ...
                      'correlation', [], ...
                      'pValueUncorr', []);
statsIdx = 1;


%% Create null distributions of correlation and differences, and compare them to observed results

% Given an ROI
for iRoi = 1:numel(roiList)

    % Get current ROI
    thisROI = roiList(iRoi);

    % Notify the user
    fprintf(['\nWorking on ROI - ', thisROI{1}, '\n']);
    

    % Create RDMs, null distribution of correlation, and compare it to observed results
    for iRCom = 1:length(rdmComparisons)

        % Follow the steps by Mattioni et al. 2020 (eLife)
        
        % Extract Group1 information
        [g1name, g1script, g1subs] = getGroupInformation(res, thisROI, opt, rdmComparisons, iRCom, 1);

        % Extract Group2 information
        [g2name, g2script, g2subs] = getGroupInformation(res, thisROI, opt, rdmComparisons, iRCom, 2);

        % Correlate each Group1 subejct's RDM with Group2 average RDM
        fprintf(['\n\nComputing correlations between ', g1name, ' and ', g2name, '\n\n']);
        fprintf(['Correlations of ', g1name,' subejcts RDMs with the average RDM of ', g2name, '\n']);

        % Pre-allocate space in which to save subject's bootstraps
        subG1sample = zeros(numel(g1subs), nbIterations);

        % Pre-allocate space in which to save subject's actual accuracy
        subG1corrs = zeros(numel(g1subs), 1);

        for iSG1 = 1:numel(g1subs)
            
            % Tell the user
            fprintf(['- computing correlation between sub-', g1subs{iSG1}, ' and the mean of ', g2name, '\n']);

            % Find RDM values (array of decoding accuracies) for this
            % subject, area, image, script
            subRDM = computeSubjectRDM(res, g1subs{iSG1}, opt.mvpa.map4D{1}, thisROI, g1script);

            % Adjust group's subject pool: 
            % if it's the same group, mean of G2 should not include this sub
            otherSubs = isSameGroup(g1name, g2name, g1subs{iSG1}, g2subs);
            
            % Find values for group RDM
            groupRDM = computeGroupRDM(res, otherSubs, opt.mvpa.map4D{1}, thisROI, g2script);

            % Compute correlation between
            % - G1 subject's RDM 
            % - G2 group RDM (minus G1 sub if from the same group)
            thisCorr = corr([subRDM' groupRDM]);
            subG1corrs(iSG1) = thisCorr(2);
         
            % Randomize order of RDM elements and compute 10k correlations,
            % to create null distribution 
            for iIter = 1:nbIterations

                subG1sample(iSG1, iIter) = shuffleRDMs(subRDM, groupRDM, 0);
            end
        end


        % Correlate each Group2 subejct's RDM with Group1 average RDM
        fprintf(['\nCorrelations of ', g2name,' subejcts RDMs with the average RDM of ', g1name, '\n']);

        % Pre-allocate space in which to save subject's bootstraps
        subG2sample = zeros(numel(g2subs), nbIterations);

        % Pre-allocate space in which to save subject's actual accuracy
        subG2corrs = zeros(numel(g2subs), 1);

        for iSG2 = 1:numel(g2subs)

            % Tell the user
            fprintf(['- computing correlation between sub-', g2subs{iSG2}, ' and the mean of ', g1name, '\n']);

            % Find RDM values (array of decoding accuracies) for this
            % subject, area, image, script
            subRDM = computeSubjectRDM(res, g2subs{iSG2}, opt.mvpa.map4D{1}, thisROI, g2script);

            % Adjust group's subject pool:
            % if it's the same group, mean of G2 should not include this sub
            otherSubs = isSameGroup(g2name, g1name, g2subs{iSG2}, g1subs);

            % Find values for group RDM
            groupRDM = computeGroupRDM(res, otherSubs, opt.mvpa.map4D{1}, thisROI, g1script);

            % Compute correlation between
            % - G1 subject's RDM
            % - G2 group RDM (minus G1 sub if from the same group)
            thisCorr = corr([subRDM' groupRDM]);
            subG2corrs(iSG2) = thisCorr(2);

            % Randomize order of RDM elements and compute 10k correlations,
            % to create null distribution
            for iIter = 1:nbIterations

                subG2sample(iSG2, iIter) = shuffleRDMs(subRDM, groupRDM, 0);
            end
        end


        % Tell the user
        fprintf('\nCalculating averages and null distribution\n')

        % Compute average correlation between subjects of Group1 and the
        % average of Group2
        avgG1 = mean(subG1corrs);

        % Compute average correlation between subjects of Group2 and the
        % average of Group1
        avgG2 = mean(subG2corrs);

        % Average between the two directions 
        avgGG = mean([avgG1, avgG2]);


        % Compute averages within the premutations to obtain null 
        % distribution for this correlations
        % Average all subjects for the iteration
        % - result is a 1 x [NbIterations] distribution
        nullG1 = mean(subG1sample);
        nullG2 = mean(subG2sample);
        
        nullDistribution = mean([nullG1; nullG2]);


        fprintf('\nCalculating statistical significance of results\n')

        % Statistical significance
        %
        % Check how many times the observed group average accuracy is lower than
        % the random one
        subObservedPvalue = sum(avgGG < nullDistribution) / nbIterations;

        % Add information to the output variable
        statsResults(statsIdx).mask = thisROI{1};
        statsResults(statsIdx).image = opt.mvpa.map4D{1};
        statsResults(statsIdx).group1 = g1name;
        statsResults(statsIdx).group2 = g2name;
        statsResults(statsIdx).correlation = avgGG;
        statsResults(statsIdx).pValueUncorr = subObservedPvalue;

        statsIdx = statsIdx +1;

    end

    fprintf('\n\nDone computing correlations between neural matrices\n\n');


    % Correlations between neural matrices and model
    for iMCom = 1:length(modelComparisons)

        % Extract Group1 information
        [g1name, g1script, g1subs] = getGroupInformation(res, thisROI, opt, modelComparisons, iMCom, 1);

        % Extract model information, could use the proper function but we
        % only need one static value
        modelName = 'MODEL';

        % Correlate each Group1 subejct's RDM with Model RDM
        fprintf(['\n\nComputing correlations between ', g1name, ' and model\n\n']);
        fprintf(['Correlations of ', g1name,' subejcts RDMs with the model RDM\n']);

        % Pre-allocate space in which to save subject's bootstraps
        subG1sample = zeros(numel(g1subs), nbIterations);

        % Pre-allocate space in which to save subject's actual accuracy
        subG1corrs = zeros(numel(g1subs), 1);

        for iS = 1:numel(g1subs)
            
            % Tell the user
            fprintf(['- computing correlation between sub-', g1subs{iS}, ' and theoretical model\n']);

            % Find RDM values (array of decoding accuracies) for this
            % subject, area, image, script
            subRDM = computeSubjectRDM(res, g1subs{iS}, opt.mvpa.map4D{1}, thisROI, g1script);

            % Adjust group's subject pool: 
            % if it's the same group, mean of G2 should not include this sub
            
            % Find values for group RDM
            modelRDM = computeModelRDM();

            % Compute correlation between
            % - G1 subject's RDM 
            % - model RDM
            subG1corrs(iS) = corr(subRDM', modelRDM, 'Tail', 'right');
         
            % Randomize order of RDM elements and compute 10k correlations,
            % to create null distribution 
            for iIter = 1:nbIterations
                subG1sample(iS, iIter) = shuffleRDMs(subRDM, modelRDM, 1);
            end
        end

        % Tell the user
        fprintf('\nCalculating averages and null distribution\n')

        % Compute average correlation between subjects of Group1 and model
        avgG1 = mean(subG1corrs);


        % Compute averages within the premutations to obtain null 
        % distribution for this correlations
        % Average all subjects for the iteration
        % - result is a 1 x [NbIterations] distribution
        nullDistribution = mean(subG1sample);
        

        fprintf('\nCalculating statistical significance of results\n')

        % Statistical significance
        %
        % Check how many times the observed group average accuracy is lower than
        % the random one
        subObservedPvalue = sum(avgG1 < nullDistribution) / nbIterations;

        % Add information to the output variable
        statsResults(statsIdx).mask = thisROI{1};
        statsResults(statsIdx).image = opt.mvpa.map4D{1};
        statsResults(statsIdx).group1 = g1name;
        statsResults(statsIdx).group2 = modelName;
        statsResults(statsIdx).correlation = avgG1;
        statsResults(statsIdx).pValueUncorr = subObservedPvalue;

        statsIdx = statsIdx +1;

    end

    fprintf('\n\nDone computing correlations with model\n\n');


end

%% Correct the p-values for multiple comparisons
% using FDR correction 

correction = mafdr([statsResults.pValueUncorr], 'BHFDR', 'true');

% Assign results to struct
for iFDR = 1:length(correction)
    statsResults(iFDR).pValueFDRcorr = correction(iFDR);
end


%% Save the output

% Set pathnames
savefileMat = fullfile(opt.dir.cosmo, ...
                       ['decoding-', opt.decodingCondition,'_modality-',opt.decodingModality, ...
                        '_group-',opt.groupName, '_space-',opt.space{1},'_rois-', opt.roiMethod, ...
                        '_stats-rsa.mat']);

savefileCsv = fullfile(opt.dir.cosmo, ...
                       ['decoding-', opt.decodingCondition,'_modality-',opt.decodingModality, ...
                        '_group-',opt.groupName, '_space-',opt.space{1},'_rois-', opt.roiMethod, ...
                        '_stats-rsa.csv']);

% Save as .mat 
save(savefileMat, 'statsResults');

% Save as .csv
writetable(struct2table(statsResults), savefileCsv);

end


%% SUBFUNCTIONS

% Extract information from comparison indexes and ROI
function [name, script, subs] = getGroupInformation(results, roi, opt, comparisons, index, order)

% Which groups are available?
% Static, parameter is passed many times
groups = {'EXPFR', 'EXPBR', 'CTRFR', 'CTRBR', 'MODEL'};

% Get name of group
name = groups{comparisons(index, order)};

% Get script from name
script = lower(name(4));


% If the group is not the model matrix, look for the corresponding subjects
% Otherwise, mark the subjects' pool as 'none'
if ~(name(1) == 'M')

    % Get subjects from decodings:
    % - get theoretical subs list
    switch name(1)
        case 'E', subs = opt.subGroups.experts;
        case 'C', subs = opt.subGroups.controls;
    end

    % - get how many subjects have decodings matching the query
    % Different numbers of subjects based on the area
    % How many subjects have decoding results for the current mask
    whichSubs = ismember({results.subID}, subs) & ...
                         strcmp({results.image}, opt.mvpa.map4D{1})  & ...
                         startsWith({results.decodingCondition}, script) & ...
                         strcmp({results.mask}, roi);
    
    % - use the subejcts from the group with actual decodings as subs list
    subs = unique({results(whichSubs).subID});

else
    subs = {'none'};
end

end


% Compute RDM for subject
function rdm = computeSubjectRDM(results, sub, image, roi, script)

if ~strcmp(sub, 'none')
    % Find RDM values (array of decoding accuracies) for this
    % subject, area, script, image
    whichAccuracies = ismember({results.subID}, sub) & ...
                                  strcmp({results.image}, image) & ...
                                  strcmp({results.mask}, roi) & ...
                                  startsWith({results.decodingCondition}, script);
    
    rdm = [results(whichAccuracies).accuracy];
else
    % use model RDM
    rdm = [1/3, 2/3, 3/3, 1/3, 2/3, 1/3];
end

end


% Compute RDM for group
function rdm = computeGroupRDM(results, subs, image, roi, script)

% All the subs are actual subs
whichAccuracies = ismember({results.subID}, subs) & ...
    strcmp({results.image}, image) & ...
    strcmp({results.mask}, roi) & ...
    startsWith({results.decodingCondition}, script);

groupSelection = [results(whichAccuracies).accuracy];
groupReshaped = reshape(groupSelection, 6, []);

rdm = mean(groupReshaped,2);
end


% Compute model RDM
% Only linguistic model implemented, just one RDM possible
function rdm = computeModelRDM()

% use model RDM
rdm = [1/3, 2/3, 3/3, 1/3, 2/3, 1/3]';

end


% Remove subject from group, if needed
function subs = isSameGroup(name1, name2, thisSub, subList)

subs = unique(subList);

if name1(1) == name2(1), subs(ismember(subs, thisSub)) = [];
end

end


% Compute permutations on the subject and group RDMs, then correlate
% matrices
function corrOut = shuffleRDMs(subRDM, groupRDM, model)

% Shuffle subject RDM
permSubRDM = datasample(subRDM, length(subRDM), 'Replace', false);

% Shuffle group RDM
permGrpRDM = datasample(groupRDM, length(groupRDM), 'Replace', false);

if model
    % Correlate RDMs - model
    corrOut = corr(permSubRDM', permGrpRDM, 'Tail', 'right');
else
    % Correlate RDMs 
    permCorr = corr([permSubRDM' permGrpRDM]);
    corrOut = permCorr(2);
end



end




