function accu = mvpa_decoding_cross(opt)
% Main function which loops through masks, images, subjects to calculate 
% decoding accuracies for given conditions.
% 
% Output:
% - .csv compatible with R visualisation (more in code/visualization) 
% - .mat file

% Choose masks to be used
opt = mvpa_masks_choose(opt);

% Set output folder/name
savefileMat = fullfile(opt.dir.cosmo, ...
                       ['decoding-', opt.decodingCondition,'_modality-',opt.decodingModality, ...
                        '_group-',opt.groupName, '_space-',opt.space{1},'_rois-', opt.roiMethod, ...
                        '_nbvoxels-', num2str(opt.mvpa.ratioToKeep), '.mat']);

savefileCsv = fullfile(opt.dir.cosmo, ...
                       ['decoding-', opt.decodingCondition,'_modality-',opt.decodingModality, ...
                        '_group-',opt.groupName, '_space-',opt.space{1},'_rois-', opt.roiMethod, ...
                        '_nbvoxels-', num2str(opt.mvpa.ratioToKeep), '.csv']);


%% MVPA options

% set cosmo mvpa structure
% get:
% - labels,
% - decoding condition, 
% - indices,
% - pairs, 
% - modalities
% they change based on our analyses
[condLabelName, decodingPairLabels, condLabelNb, ...
 decodingPairs, modalityLabelName, modalityLabelNb, decodingConditionList] = mvpa_assignConditions(opt);

%% let's get going!

% Set structure array for keeping the results
accu = struct('subID', [],             'mask', [],        'accuracy', [], ...
              'prediction', [],        'maskVoxNb', [],   'choosenVoxNb', [], ...
              'image', [],             'ffxSmooth', [],   'roiSource', [],   ...
              'decodingCondition', [], 'permutation', [], 'imagePath', []);

count = 1;

for iSub = 1:numel(opt.subjects)

    % get FFX path
    subID = opt.subjects{iSub};
    ffxDir = getFFXdir(subID, opt);

    % get subject folder name
    subFolder = ['sub-', subID];

    for iImage = 1:length(opt.mvpa.map4D)

        subMasks = opt.maskName(startsWith(opt.maskName, strcat('rsub-', subID)));

        for iMask = 1:length(subMasks)

            % choose the mask: check if it's actually present
            % get the masks present in derivatives/cpp_spm-rois/sub-xxx/
            presentMasks = dir(fullfile(opt.dir.rois, subFolder));
            availableMasks = {presentMasks(3:end).name}.';
            mask = fullfile(opt.dir.rois, subFolder, subMasks{iMask});

            % check which mask are we dealing with
            maskSplit = split(mask,{'_','-'});
            maskLabel = maskSplit{find(strcmp(maskSplit,'label'))+1};

            % check if the mask we want to use is actually present,
            % if so do the mask calculation
            if ismember(subMasks{iMask}, availableMasks)

                % display the used mask
                disp(opt.maskName{iMask});

                % 4D image
                imageName = ['sub-', subID, '_task-', opt.taskName{:}, '_space-', ...
                             opt.space{:}, '_desc-4D_', opt.mvpa.map4D{iImage}, '.nii'];
                image = fullfile(ffxDir, imageName);

                for iModality = 1:3 
                    
                    % see the types in decoing conditionlist
                    % 1: train on FRENCH, test on BRAILLE
                    % 2: train on BRAILLE, test on FRENCH
                    % 3: train on BOTH, test on BOTH (average)
                    test = iModality;
                    decodingCondition = decodingConditionList(iModality);

                    if iModality == 3
                        test = [];
                    end

                    for iPair = 1:size(decodingPairs,1)

                        % load cosmo input
                        ds = cosmo_fmri_dataset(image, 'mask', mask);

                        ds = cosmo_remove_useless_data(ds);

                        % Getting rid off zeros
                        zeroMask = all(ds.samples == 0, 1);
                        ds = cosmo_slice(ds, ~zeroMask, 2);

                        % set cosmo structure
                        ds = setCosmoStructure(opt, ds, condLabelNb, condLabelName, modalityLabelNb, modalityLabelName, iSub);

                        % Demean every pattern to remove univariate effect differences
                        meanPattern = mean(ds.samples,2);  
                        meanPattern = repmat(meanPattern,1,size(ds.samples,2)); 
                        ds.samples = ds.samples - meanPattern; 

                        % slice the ds according to your targets
                        ds = cosmo_slice(ds, ds.sa.targets == decodingPairs(iPair,1) | ds.sa.targets == decodingPairs(iPair,2));

                        % remove constant features
                        ds = cosmo_remove_useless_data(ds);

                        % calculate the mask size
                        maskVoxel = size(ds.samples, 2);

                        % Partitions for test and training : cross validation
                        partitions = cosmo_nchoosek_partitioner(ds, 1, 'modality', test);

                        opt.mvpa.feature_selection_ratio_to_keep = opt.mvpa.ratioToKeep;

                        % ROI mvpa analysis
                        [pred, accuracy] = cosmo_crossvalidate(ds, ...
                            @cosmo_classify_meta_feature_selection, ...
                            partitions, opt.mvpa);

                        % store output
                        accu(count).subID = subID;
                        accu(count).mask = opt.maskLabel{iMask};
                        accu(count).maskVoxNb = maskVoxel;
                        accu(count).choosenVoxNb = opt.mvpa.feature_selection_ratio_to_keep;
                        accu(count).image = opt.mvpa.map4D{iImage};
                        accu(count).ffxSmooth = opt.fwhm.func;
                        accu(count).accuracy = accuracy;
                        accu(count).prediction = pred;
                        accu(count).imagePath = image;
                        accu(count).modality = decodingConditionList{iModality};
                        accu(count).decodingCondition = decodingPairLabels{iPair};

                        % Perform permutations if needed 
                        if opt.mvpa.permutate  == 1
                            % number of iterations
                            nbIter = 100;

                            % allocate space for permuted accuracies
                            acc0 = zeros(nbIter, 1);

                            % make a copy of the dataset
                            dsCopy = ds;

                            % Reshuffle the labels and compute accuracy
                            % Use the helper function cosmo_randomize_targets
                            for k = 1:nbIter
                                dsCopy.sa.targets = cosmo_randomize_targets(ds);
                                [~, acc0(k)] = cosmo_crossvalidate(dsCopy, ...
                                                                   @cosmo_meta_feature_selection_classifier, ...
                                                                   partitions, ...
                                                                   opt.mvpa);
                            end

                            p = sum(accuracy < acc0) / nbIter;
                            fprintf('%d permutations: accuracy=%.3f, p=%.4f\n', nbIter, accuracy, p);

                            % save permuted accuracies
                            accu(count).permutation = acc0';
                        end

                        % increase the counter and allons y!
                        count = count + 1;
                        
                        fprintf(['sub-',subID,': cross-script direction: ' decodingConditionList{iModality}, ...
                            '; pairwise decoding: ',decodingPairLabels{iPair},' in ',maskLabel,' - accuracy: ',num2str(accuracy),'\n\n\n']);
                    end

                    % map in nii file the voxels used
                    cosmo_map2fmri(ds, ['cosmo_datasets/data_' subMasks{iMask}]);

                end

            end
        end
    end
end
% save output

% As .mat file
save(savefileMat, 'accu');

% As .csv with important info for plotting
csvAccu = rmfield(accu, 'permutation');
csvAccu = rmfield(csvAccu, 'prediction');
csvAccu = rmfield(csvAccu, 'imagePath');
writetable(struct2table(csvAccu), savefileCsv);

end


%% CUSTOM STRUCTURE

function ds = setCosmoStructure(opt, ds, condLabelNb, condLabelName, modalityLabelNb, modalityLabelName, iSub)
% sets up the target, chunk, labels by stimuli condition labels, runs,
% number labels.

% design info from opt
nbRun = opt.mvpa.nbRun;
betasPerCondition = opt.mvpa.nbTrialRepetition;

% chunk (runs), target (condition), labels (condition names)
conditionPerRun = length(condLabelNb)/2;
betasPerRun = betasPerCondition * conditionPerRun;

% Manage chunks to consider the alternation of Braille and French runs
% This is the result of a thought mistake: runs are concatenated based on 
% stimuli, not run order.
% It does not impair results, just requires a further modification
firstChunk = opt.subsCondition{strcmp(opt.subsCondition(:,1),opt.subjects{iSub}),2}(1:6);
secondChunk = opt.subsCondition{strcmp(opt.subsCondition(:,1),opt.subjects{iSub}),2}(7:end);
chunks = horzcat(repmat(firstChunk', 1, betasPerRun), repmat(secondChunk', 1, betasPerRun));
chunks = chunks(:);

targets = repmat(condLabelNb', 1, nbRun/2)';
targets = targets(:);
targets = repmat(targets, betasPerCondition, 1);

condLabelName = repmat(condLabelName', 1, nbRun/2)';
condLabelName = condLabelName(:);
condLabelName = repmat(condLabelName, betasPerCondition, 1);

modalityLabelName = repmat(modalityLabelName', 1, nbRun/2)';
modalityLabelName = modalityLabelName(:);
modalityLabelName = repmat(modalityLabelName, betasPerCondition, 1);

modalityLabelNb = repmat(modalityLabelNb', 1, nbRun/2)';
modalityLabelNb = modalityLabelNb(:);
modalityLabelNb = repmat(modalityLabelNb, betasPerCondition, 1);

% assign our 4D image design into cosmo ds git
ds.sa.targets = targets;
ds.sa.chunks = chunks;
ds.sa.labels = condLabelName;
ds.sa.modality = modalityLabelNb;

end
