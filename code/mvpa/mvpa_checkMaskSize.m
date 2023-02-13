function [maskVoxel, opt] = mvpa_checkMaskSize(opt)

% choose masks to be used
opt = mvpa_chooseMask(opt);

% initialize array with all the voxel values
maskVoxel = [];

%% MVPA options

% set cosmo mvpa structure
condLabelNb = [1 1 1 1 2 2 2 2];
condLabelName = {'frw', 'fpw', 'fnw', 'ffs', 'brw', 'bpw', 'bnw', 'bfs'};
%   decodingCondition = 'visual_vertical_vs_visual_horizontal';%'tactile_vertical_vs_tactile_horizontal';

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

            % check if the mask we want to use is actually present,
            % if so do the mask calculation
            if ismember(subMasks{iMask}, availableMasks)

                % display the used mask
                disp(subMasks{iMask});

                % 4D image: e.g. sub-009_task-wordsDecoding_space-IXI549Space_desc-4D_tmap
                imageName = ['sub-', subID, '_task-', opt.taskName{:}, '_space-', opt.space{:}, '_desc-4D_', opt.mvpa.map4D{iImage}, '.nii'];
                image = fullfile(ffxDir, imageName);

                % load cosmo input
                ds = cosmo_fmri_dataset(image, 'mask', mask);

                % Getting rid off zeros
                zeroMask = all(ds.samples == 0, 1);
                ds = cosmo_slice(ds, ~zeroMask, 2);

                % set cosmo structure
                ds = setCosmoStructure(opt, ds, condLabelNb, condLabelName);

                % slice the ds according to your targers (choose your
                % train-test conditions
                %         ds = cosmo_slice(ds, ds.sa.targets == 1 | ds.sa.targets == 2);%%??

                % remove constant features
                %         ds = cosmo_remove_useless_data(ds);

                % calculate the mask size
                thisVoxel = size(ds.samples, 2);
%                 cosmo_map2fmri(ds, ['cosmo_datasets/data_' subMasks{iMask}]);
                % display the mask size
                disp(thisVoxel);
                maskVoxel = [maskVoxel, thisVoxel];

                % add everything to a report of how big the ROIs are
                parts = split(mask,{'-','_'});
                reportSub = ['sub-', subID];
                if strcmp(parts{9},'atlas')
                    if strcmp(parts{10},'Broadmann')
                        reportMethod = parts{10};
                        reportFormat = parts{12};
                        reportThreshold = '/';
                    else
                        reportMethod = parts{10};
                        reportFormat = parts{14};
                        reportThreshold = parts{12};
                    end
                    
                else
                    reportMethod = 'expansion';
                    reportThreshold = '/';
                    reportFormat = '50vx';
                end
                reportSize = thisVoxel;
                reportMask = opt.mvpa.map4D{iImage};
                opt.report = vertcat(opt.report,{reportSub, reportMethod, reportThreshold, reportFormat, reportSize, reportMask});
            end
        end

        % increase the counter and allons y!
        count = count + 1;
    end

end

end

function ds = setCosmoStructure(opt, ds, condLabelNb, condLabelName)
% sets up the target, chunk, labels by stimuli condition labels, runs,
% number labels.

% design info from opt
nbRun = opt.mvpa.nbRun;
betasPerCondition = opt.mvpa.nbTrialRepetition;

% chunk (runs), target (condition), labels (condition names)
conditionPerRun = length(condLabelNb);
betasPerRun = betasPerCondition * conditionPerRun;

chunks = repmat((1:nbRun)', 1, betasPerRun);
chunks = chunks(:);

targets = repmat(condLabelNb', 1, nbRun)';
targets = targets(:);
targets = repmat(targets, betasPerCondition, 1);

condLabelName = repmat(condLabelName', 1, nbRun)';
condLabelName = condLabelName(:);
condLabelName = repmat(condLabelName, betasPerCondition, 1);

% assign our 4D image design into cosmo ds git
ds.sa.targets = targets;
ds.sa.chunks = chunks;
ds.sa.labels = condLabelName;

% figure; imagesc(ds.sa.chunks);

end
