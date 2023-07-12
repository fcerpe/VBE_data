function accu = mvpa_crossScriptDecoding(opt)

% get the smoothing parameter for 4D map
funcFWHM = opt.fwhm.func;

% choose masks to be used
opt = mvpa_chooseMask(opt);

% set output folder/name
savefileMat = fullfile(opt.dir.cosmo, ...
    ['mvpa-decoding_grp-', opt.groupName{1}, '_task-', opt.taskName{1},'_condition-', ...
    opt.decodingCondition{1}, '_nbvoxels-', num2str(opt.mvpa.ratioToKeep), '.mat']);

savefileCsv = fullfile(opt.dir.cosmo, ...
    ['mvpa-decoding_grp-', opt.groupName{1}, '_task-', opt.taskName{1},'_condition-', ...
    opt.decodingCondition{1}, '_nbvoxels-', num2str(opt.mvpa.ratioToKeep), '.csv']);


%% MVPA options

% set cosmo mvpa structure
condLabelNb = [1 2 3 4 1 2 3 4];
condLabelName = {'frw','fpw','fnw','ffs','brw','bpw','bnw','bfs'};
decodingConditionList = {'tr-braille_te-french', 'tr-french_te-braille', 'both'};
modalityLabelNb = [1 1 1 1 2 2 2 2];
modalityLabelName = {'french','french','french','french','braille','braille','braille','braille'};
decodingPairs = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];
decodingPairLabels = {'rw_v_pw', 'rw_v_nw', 'rw_v_fs', 'pw_v_nw', 'pw_v_fs', 'nw_v_fs'};

%% let's get going!

% set structure array for keeping the results
accu = struct( ...
    'subID', [], ...
    'mask', [], ...
    'accuracy', [], ...
    'prediction', [], ...
    'maskVoxNb', [], ...
    'choosenVoxNb', [], ...
    'image', [], ...
    'ffxSmooth', [], ...
    'roiSource', [], ...
    'decodingCondition', [], ...
    'permutation', [], ...
    'imagePath', []);

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
                imageName = ['sub-', subID, '_task-', opt.taskName{:}, '_space-', opt.space{:}, '_desc-4D_', opt.mvpa.map4D{iImage}, '.nii'];
                image = fullfile(ffxDir, imageName);

                for iModality = 1:3 % see the types in decoing conditionlist
                                    % 1: train on FRENCH, test on BRAILLE
                                    % 2: train on BRAILLE, test on FRENCH
                                    % 3: train on BOTH, test on BOTH
                                    
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
                        meanPattern = mean(ds.samples,2);  % get the mean for every pattern
                        meanPattern = repmat(meanPattern,1,size(ds.samples,2)); % make a matrix with repmat
                        ds.samples  = ds.samples - meanPattern; % remove the mean from every every point in each pattern

                        % Slice the dataset accroding to modality
%                         modIdx = (ds.sa.modality == 1) | (ds.sa.modality == 2) ;
%                         ds = cosmo_slice(ds,modIdx);

                        % slice the ds according to your targets
                        ds = cosmo_slice(ds, ds.sa.targets == decodingPairs(iPair,1) | ds.sa.targets == decodingPairs(iPair,2));

                        % remove constant features
                        ds = cosmo_remove_useless_data(ds);

                        % calculate the mask size
                        maskVoxel = size(ds.samples, 2);

                        % partitioning, for test and training : cross validation
                        %         partitions = cosmo_nfold_partitioner(ds);
                        partitions = cosmo_nchoosek_partitioner(ds, 1, 'modality', test);

                        % define the voxel number for feature selection
                        % set ratio to keep depending on the ROI dimension
                        % if SMA, double the voxel number
                        %         if strcmpi(maskLabel{iMask}, 'sma')
                        %            opt.mvpa.feature_selection_ratio_to_keep = 2 * opt.mvpa.ratioToKeep;
                        %         else
                        %            opt.mvpa.feature_selection_ratio_to_keep = opt.mvpa.ratioToKeep;
                        %         end

                        % use the ratios, instead of the voxel number:
                        opt.mvpa.feature_selection_ratio_to_keep = opt.mvpa.ratioToKeep;

                        % ROI mvpa analysis
                        [pred, accuracy] = cosmo_crossvalidate(ds, ...
                            @cosmo_classify_meta_feature_selection, ...
                            partitions, opt.mvpa);

                        %         ratios_to_keep = .05:.05:.95;
                        %         nratios = numel(ratios_to_keep);
                        %         accs = zeros(nratios, 1);
                        %         for k = 1:nratios
                        %           opt.mvpa.feature_selection_ratio_to_keep = ratios_to_keep(k);
                        %           [pred, acc] = cosmo_crossvalidate(ds, @cosmo_meta_feature_selection_classifier, partitions, opt.mvpa);
                        %           accs(k) = acc;
                        %         end
                        %         plot(ratios_to_keep, accs);
                        %         xlabel('ratio of selected feaures');
                        %         ylabel('classification accuracy');
                        %         accuracy = max(accs);
                        %         maxRatio = ratios_to_keep(accs == max(accs));

                        %% store output
                        accu(count).subID = subID;
                        accu(count).mask = opt.maskLabel{iMask};
                        accu(count).maskVoxNb = maskVoxel;
                        accu(count).choosenVoxNb = opt.mvpa.feature_selection_ratio_to_keep;
                        % accu(count).choosenVoxNb = round(maskVoxel * maxRatio);
                        % accu(count).maxRatio = maxRatio;
                        accu(count).image = opt.mvpa.map4D{iImage};
                        accu(count).ffxSmooth = funcFWHM;
                        accu(count).accuracy = accuracy;
                        accu(count).prediction = pred;
                        accu(count).imagePath = image;
                        accu(count).modality = decodingConditionList{iModality};
                        accu(count).decodingCondition = decodingPairLabels{iPair};

                        %% PERMUTATION PART
                        if opt.mvpa.permutate  == 1
                            % number of iterations
                            nbIter = 100;

                            % allocate space for permuted accuracies
                            acc0 = zeros(nbIter, 1);

                            % make a copy of the dataset
                            ds0 = ds;

                            % for _niter_ iterations, reshuffle the labels and compute accuracy
                            % Use the helper function cosmo_randomize_targets
                            for k = 1:nbIter
                                ds0.sa.targets = cosmo_randomize_targets(ds);
                                [~, acc0(k)] = cosmo_crossvalidate(ds0, ...
                                    @cosmo_meta_feature_selection_classifier, ...
                                    partitions, opt.mvpa);
                            end

                            p = sum(accuracy < acc0) / nbIter;
                            fprintf('%d permutations: accuracy=%.3f, p=%.4f\n', nbIter, accuracy, p);

                            % save permuted accuracies
                            accu(count).permutation = acc0';
                        end

                        % increase the counter and allons y!
                        count = count + 1;

                        fprintf(['sub-' subID ': cross-modal direction: ' decodingConditionList{iModality} ...
                            '; pairwise decoding: ' decodingPairLabels{iPair} ' in ' maskLabel ' - accuracy: ' num2str(accuracy) '\n\n\n']);
                    end

                    % map in nii file the voxels used
                    cosmo_map2fmri(ds, ['cosmo_datasets/data_' subMasks{iMask}]);

                end

            end
        end
    end
end
%% save output

% mat file
save(savefileMat, 'accu');

% csv but with important info for plotting
csvAccu = rmfield(accu, 'permutation');
csvAccu = rmfield(csvAccu, 'prediction');
csvAccu = rmfield(csvAccu, 'imagePath');
writetable(struct2table(csvAccu), savefileCsv);

end

function ds = setCosmoStructure(opt, ds, condLabelNb, condLabelName, modalityLabelNb, modalityLabelName, iSub)
% sets up the target, chunk, labels by stimuli condition labels, runs,
% number labels.

% design info from opt
nbRun = opt.mvpa.nbRun;
betasPerCondition = opt.mvpa.nbTrialRepetition;

% chunk (runs), target (condition), labels (condition names)
conditionPerRun = length(condLabelNb)/2;
betasPerRun = betasPerCondition * conditionPerRun;

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
