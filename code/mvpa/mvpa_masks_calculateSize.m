function [maskVoxel, opt] = mvpa_masks_calculateSize(opt)

% choose masks to be used
opt = mvpa_masks_choose(opt);

% initialize array with all the voxel values
maskVoxel = [];

%% MVPA options

% set cosmo mvpa structure, simple one to just get the number of voxels
% available in each ROI
condLabelNb = [1 1 1 1 2 2 2 2];
condLabelName = {'frw', 'fpw', 'fnw', 'ffs', 'brw', 'bpw', 'bnw', 'bfs'};

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

                % calculate the mask size
                thisVoxel = size(ds.samples, 2);

                % display the mask size
                disp(thisVoxel);
                maskVoxel = [maskVoxel, thisVoxel];

                % Make mini report to kep track of how big the ROIs are 
                reportSize = thisVoxel;
                reportMask = opt.mvpa.map4D{iImage};
                opt.roiSizesReport = vertcat(opt.roiSizesReport,{reportSize, reportMask});
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
