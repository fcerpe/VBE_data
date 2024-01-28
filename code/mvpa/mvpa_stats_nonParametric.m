function opt = mvpa_stats_nonParametric(opt)
%% Non-parametric statistics
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
                          ['decoding-', opt.decodingCondition, '_modality-within*_rois-', opt.roiMethod, '_nbvoxels-*.mat']));

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

% Set output structures
statsResults = struct('mask', [], ...
                      'image', [], ...
                      'group', [], ...
                      'condition', [], ...
                      'accuracy', [], ...
                      'pValueUncorr', []);
statsIdx = 1;

%% Create null distribution and compare it to observed results

for iGrp = 1:numel(opt.groups)

    % Get current group and its subjects
    thisGroup = opt.groups{iGrp};
    groupSubs = opt.subGroups.(thisGroup);

    % Notify the user
    fprintf(['\nWorking on GROUP - ', thisGroup, '\n\n']);
    
    % Given an ROI
    for iRoi = 1:numel(roiList)
    
        % Get current ROI
        thisROI = roiList(iRoi);
    
        % Notify the user
        fprintf(['Working on ROI - ', thisROI{1}, '\n\n']);
    
        % Work on each condition separately
        for iCond = 1:numel(decodingCondition)
    
            % Get current condition
            thisDec = decodingCondition(iCond);
            if startsWith(thisDec{1}, 'f'), decName = 'french';
            else, decName = 'braille';
            end

            % Notify the user
            fprintf(['Working on CONDITION - ', decName, '\n']);
    
    
            % Create null distribution
    
            % Different numbers of subjects based on the area
            % How many subjects have decoding results for the current mask
            whichSubs = ismember({res.subID}, groupSubs)              & strcmp({res.image}, opt.mvpa.map4D{1})  & ...
                     strcmp({res.decodingCondition}, thisDec{1}) & strcmp({res.mask}, thisROI);

            subs = {res(whichSubs).subID};

            % Pre-allocate space in which to save subject's bootstraps
            subSample = zeros(numel(subs), nbIterations);
    
            % Pre-allocate space in which to save subject's actual accuracy
            subAccuracy = zeros(numel(subs), 1);

    
            for iSub = 1:length(subs)
    
                % Get current subject
                subID = subs{iSub};
    
                % Find the proper row indicating:
                % - subject
                % - ffxResult (4D map)
                % - decoding condition 
                % - ROI
                resIdx = find(strcmp({res.subID}, char(subID)) & ...
                              strcmp({res.image}, opt.mvpa.map4D{1})  & ...
                              strcmp({res.decodingCondition}, thisDec{1}) & ...
                              strcmp({res.mask}, thisROI));

                % Store the actual accuracy for later
                subAccuracy(iSub) = res(resIdx).accuracy;

                % Notify the user
                fprintf(['\textracting values for sub-', subs{iSub}, '...\n']);

                % Randomly draw [number of iterations] values from the permutations
                % of each subject in a given condition
                for iIter = 1:nbIterations
 
                    % Read the random value from permutations with replacement
                    subSample(iSub, iIter) = datasample(res(resIdx).permutation, 1);
                end
            end
    
            % Average all subjects for the iteration
            % result is a 1 x [NbIterations] distribution
            nullDistribution = mean(subSample);
        
            % Notify the user
            fprintf('Bootstrapping is done\n')
        
        
            % Statistical significance
            %
            % Check how many times the observed group average accuracy is lower than
            % the random one
            subObservedPvalue = sum(mean(subAccuracy) < nullDistribution) / nbIterations;

            % Add information to the output variable
            statsResults(statsIdx).mask = thisROI{1};
            statsResults(statsIdx).image = opt.mvpa.map4D{1};
            statsResults(statsIdx).group = thisGroup;
            statsResults(statsIdx).condition = decName;
            statsResults(statsIdx).accuracy = mean(subAccuracy);
            statsResults(statsIdx).pValueUncorr = subObservedPvalue;

            statsIdx = statsIdx +1;

            % Notify the user
            fprintf('Statistical significance (uncorrected) is done\n\n')
    
        end
    end
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
                        '_stats.mat']);

savefileCsv = fullfile(opt.dir.cosmo, ...
                       ['decoding-', opt.decodingCondition,'_modality-',opt.decodingModality, ...
                        '_group-',opt.groupName, '_space-',opt.space{1},'_rois-', opt.roiMethod, ...
                        '_stats.csv']);

% Save as .mat 
save(savefileMat, 'statsResults');

% Save as .csv
writetable(struct2table(statsResults), savefileCsv);

end









