function opt = mvpa_stats_RSA_partial(opt)
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
%               5: MODEL - Linguistic
%               6: MODEL - Low-level position FR
%               7: MODEL - Low-level position BR
rdmComparisons = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];
modelComparisons = [1 5; 2 5; 3 5; 4 5; 1 6; 3 6; 2 7; 4 7];

modelNames = {'MLANG', 'MLATIN', 'MBRAILLE'};

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
    % for iRCom = 1:length(rdmComparisons)
    % 
    %     % Follow the steps by Mattioni et al. 2020 (eLife)
    % 
    %     % Extract Group1 information
    %     [g1name, g1script, g1subs] = getGroupInformation(res, thisROI, opt, rdmComparisons, iRCom, 1);
    % 
    %     % Extract Group2 information
    %     [g2name, g2script, g2subs] = getGroupInformation(res, thisROI, opt, rdmComparisons, iRCom, 2);
    % 
    %     % Correlate each Group1 subejct's RDM with Group2 average RDM
    %     fprintf(['\n\nComputing correlations between ', g1name, ' and ', g2name, '\n\n']);
    %     fprintf(['Correlations of ', g1name,' subejcts RDMs with the average RDM of ', g2name, '\n']);
    % 
    %     % Pre-allocate space in which to save subject's bootstraps
    %     subG1sample = zeros(numel(g1subs), nbIterations);
    % 
    %     % Pre-allocate space in which to save subject's actual accuracy
    %     subG1corrs = zeros(numel(g1subs), 1);
    % 
    %     for iSG1 = 1:numel(g1subs)
    % 
    %         % Tell the user
    %         fprintf(['- computing correlation between sub-', g1subs{iSG1}, ' and the mean of ', g2name, '\n']);
    % 
    %         % Find RDM values (array of decoding accuracies) for this
    %         % subject, area, image, script
    %         subRDM = computeSubjectRDM(res, g1subs{iSG1}, opt.mvpa.map4D{1}, thisROI, g1script);
    % 
    %         % Adjust group's subject pool: 
    %         % if it's the same group, mean of G2 should not include this sub
    %         otherSubs = isSameGroup(g1name, g2name, g1subs{iSG1}, g2subs);
    % 
    %         % Find values for group RDM
    %         groupRDM = computeGroupRDM(res, otherSubs, opt.mvpa.map4D{1}, thisROI, g2script);
    % 
    %         % Compute correlation between
    %         % - G1 subject's RDM 
    %         % - G2 group RDM (minus G1 sub if from the same group)
    %         thisCorr = corr([subRDM' groupRDM]);
    %         subG1corrs(iSG1) = thisCorr(2);
    % 
    %         % Randomize order of RDM elements and compute 10k correlations,
    %         % to create null distribution 
    %         for iIter = 1:nbIterations
    % 
    %             subG1sample(iSG1, iIter) = shuffleRDMs(subRDM, groupRDM, 0);
    %         end
    %     end
    % 
    % 
    %     % Correlate each Group2 subejct's RDM with Group1 average RDM
    %     fprintf(['\nCorrelations of ', g2name,' subejcts RDMs with the average RDM of ', g1name, '\n']);
    % 
    %     % Pre-allocate space in which to save subject's bootstraps
    %     subG2sample = zeros(numel(g2subs), nbIterations);
    % 
    %     % Pre-allocate space in which to save subject's actual accuracy
    %     subG2corrs = zeros(numel(g2subs), 1);
    % 
    %     for iSG2 = 1:numel(g2subs)
    % 
    %         % Tell the user
    %         fprintf(['- computing correlation between sub-', g2subs{iSG2}, ' and the mean of ', g1name, '\n']);
    % 
    %         % Find RDM values (array of decoding accuracies) for this
    %         % subject, area, image, script
    %         subRDM = computeSubjectRDM(res, g2subs{iSG2}, opt.mvpa.map4D{1}, thisROI, g2script);
    % 
    %         % Adjust group's subject pool:
    %         % if it's the same group, mean of G2 should not include this sub
    %         otherSubs = isSameGroup(g2name, g1name, g2subs{iSG2}, g1subs);
    % 
    %         % Find values for group RDM
    %         groupRDM = computeGroupRDM(res, otherSubs, opt.mvpa.map4D{1}, thisROI, g1script);
    % 
    %         % Compute correlation between
    %         % - G1 subject's RDM
    %         % - G2 group RDM (minus G1 sub if from the same group)
    %         thisCorr = corr([subRDM' groupRDM]);
    %         subG2corrs(iSG2) = thisCorr(2);
    % 
    %         % Randomize order of RDM elements and compute 10k correlations,
    %         % to create null distribution
    %         for iIter = 1:nbIterations
    % 
    %             subG2sample(iSG2, iIter) = shuffleRDMs(subRDM, groupRDM, 0);
    %         end
    %     end
    % 
    % 
    %     % Tell the user
    %     fprintf('\nCalculating averages and null distribution\n')
    % 
    %     % Compute average correlation between subjects of Group1 and the
    %     % average of Group2
    %     avgG1 = mean(subG1corrs);
    % 
    %     % Compute average correlation between subjects of Group2 and the
    %     % average of Group1
    %     avgG2 = mean(subG2corrs);
    % 
    %     % Average between the two directions 
    %     avgGG = mean([avgG1, avgG2]);
    % 
    % 
    %     % Compute averages within the premutations to obtain null 
    %     % distribution for this correlations
    %     % Average all subjects for the iteration
    %     % - result is a 1 x [NbIterations] distribution
    %     nullG1 = mean(subG1sample);
    %     nullG2 = mean(subG2sample);
    % 
    %     nullDistribution = mean([nullG1; nullG2]);
    % 
    % 
    %     fprintf('\nCalculating statistical significance of results\n')
    % 
    %     % Statistical significance
    %     %
    %     % Check how many times the observed group average accuracy is lower than
    %     % the random one
    %     subObservedPvalue = sum(avgGG < nullDistribution) / nbIterations;
    % 
    %     % Add information to the output variable
    %     statsResults(statsIdx).mask = thisROI{1};
    %     statsResults(statsIdx).image = opt.mvpa.map4D{1};
    %     statsResults(statsIdx).group1 = g1name;
    %     statsResults(statsIdx).group2 = g2name;
    %     statsResults(statsIdx).correlation = avgGG;
    %     statsResults(statsIdx).pValueUncorr = subObservedPvalue;
    % 
    %     statsIdx = statsIdx +1;
    % 
    % end

    fprintf('\n\nDone computing correlations between neural matrices\n\n');


    % Correlations between neural matrices and model
    for iMCom = 1:length(modelComparisons)

        % Extract Group1 information
        [g1name, g1script, g1subs] = getGroupInformation(res, thisROI, opt, modelComparisons, iMCom, 1);

        % Extract model information, could use the proper function but we
        % only need one static value
        modelName = modelNames{modelComparisons(iMCom,2)-4};
        
        switch modelComparisons(iMCom,1)
            case {1,3}
                switch modelComparisons(iMCom,2)
                    case 5, regressorName = modelNames{2};
                    case 6, regressorName = modelNames{1};
                end
            case {2,4}
                switch modelComparisons(iMCom,2)
                    case 5, regressorName = modelNames{3};
                    case 7, regressorName = modelNames{1};
                end
        end

        % Correlate each Group1 subejct's RDM with Model RDM
        fprintf(['\n\nComputing partial correlations between ',g1name,' and ',modelName,', while controlling for ',regressorName,'\n\n']);
        fprintf(['Correlations of ', g1name,' subejcts RDMs with the ', modelName, ' RDM\n']);

        % Pre-allocate space in which to save subject's bootstraps
        subG1sample = zeros(numel(g1subs), nbIterations);

        % Pre-allocate space in which to save subject's actual accuracy
        subG1corrs = zeros(numel(g1subs), 1);

        % Correlate every subject with the model
        for iS = 1:numel(g1subs)
            
            % Tell the user
            fprintf(['- computing parital correlation between sub-', g1subs{iS}, ' and theoretical model\n']);

            % Find RDM values (array of decoding accuracies) for this
            % subject, area, image, script
            subRDM = computeSubjectRDM(res, g1subs{iS}, opt.mvpa.map4D{1}, thisROI, g1script);

            % To implement the latest models, need the full square
            % subRDM = squareRDM(subRDM);

            % Adjust group's subject pool: 
            % if it's the same group, mean of G2 should not include this sub
            
            % Find values for group RDM
            modelRDM = computeModelRDM(modelComparisons(iMCom,2));

            % Get the RDM of the model to control for in the partial
            % correlation
            regressRDM = getConditionRegressor(modelComparisons(iMCom,:));
            
            % Compute correlation between
            % - G1 subject's RDM 
            % - model RDM (linguistic / visual)
            % - controlling for the other model (visual / linguistic)
            subG1corrs(iS) = partialcorr(subRDM, modelRDM, regressRDM, 'Tail', 'right');
         
            % Randomize order of RDM elements and compute 10k correlations,
            % to create null distribution 
            for iIter = 1:nbIterations
                subG1sample(iS, iIter) = shuffleRDMs(subRDM, modelRDM, regressRDM, 1);
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
                        '_stats-rsa_partial.mat']);

savefileCsv = fullfile(opt.dir.cosmo, ...
                       ['decoding-', opt.decodingCondition,'_modality-',opt.decodingModality, ...
                        '_group-',opt.groupName, '_space-',opt.space{1},'_rois-', opt.roiMethod, ...
                        '_stats-rsa_partial.csv']);

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
    
    rdm = [results(whichAccuracies).accuracy]';
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
function rdm = computeModelRDM(modelNumber)

switch modelNumber

    case 5 % MODEL - Linguistic
        rdm = [1, 2, 3, 1, 2, 1]';
        % Full rdm = [NaN; 1; 2; 3; 1; NaN; 1; 2; 2; 1; NaN; 1; 3; 2; 1; NaN];

    case 6 % MODEL - Low-level French script
        % rdm = [1.29; 2.13; 5.67; 2.15; 5.75; 3.83]; % Number of strokes / dots
        rdm = [6168.611; 7043.542; 7523.750; 7188.403; 7679.264; 8084.153]; % Overlapping pixels

    case 7 % MODEL - Low-level Braille script
        % rdm = [2.06; 2.19; 2.19; 2.00; 2.00; 2.028]; % Number of strokes / dots
        rdm = [2786.889; 3227.736; 6882.014; 3254.986; 6896.833; 6868.958]; % Overlapping pixels
end

end


% Remove subject from group, if needed
function subs = isSameGroup(name1, name2, thisSub, subList)

subs = unique(subList);

if name1(1) == name2(1), subs(ismember(subs, thisSub)) = [];
end

end


% Compute permutations on the subject and group RDMs, then correlate
% matrices
function corrOut = shuffleRDMs(subRDM, groupRDM, regressRDM, model)

% Shuffle subject RDM
permSubRDM = datasample(subRDM, length(subRDM), 'Replace', false);

% Shuffle group RDM
permGrpRDM = datasample(groupRDM, length(groupRDM), 'Replace', false);

% Shuffle regressor RDM
permRegRDM = datasample(regressRDM, length(regressRDM), 'Replace', false);

if model
    % Correlate RDMs - model
    corrOut = partialcorr(permSubRDM, permGrpRDM, permRegRDM, 'Tail', 'right');
else
    % Correlate RDMs 
    permCorr = corr([permSubRDM permGrpRDM]);
    corrOut = permCorr(2);
end


end


% Convert the array of accuracies into a 4-by-4 matrix, to be correlated 
% with the model
function rdm = squareRDM(rdmIn)

rdm = [NaN;      rdmIn(1); rdmIn(2); rdmIn(3);
       rdmIn(1); NaN;      rdmIn(4); rdmIn(5);
       rdmIn(2); rdmIn(4); NaN;      rdmIn(6);
       rdmIn(3); rdmIn(5); rdmIn(6); NaN];

end


% Compute the model to use as a regressor in the partial correlation
% In the case of linguistic model, regress visual and viceversa
function rdm = getConditionRegressor(conditions)

    % Based on the neural RDM (first element) and the model (second
    % element), determine which is the model to regress out
    % E.G. french-experts r linguistic model needs to account for visual
    % model of french
    switch conditions(1)

        % French neural RDMs
        case {1,3}
            switch conditions(2)

                % Case of linguistic model, regressor is visual 
                case 5, rdm = computeModelRDM(6);

                % Case of visual model, regressor is linguistic 
                case 6, rdm = computeModelRDM(5);
            end

        % Braille neural RDMs 
        case {2,4}
            switch conditions(2)
                case 5, rdm = computeModelRDM(7);
                case 7, rdm = computeModelRDM(5);
            end
    end 
end