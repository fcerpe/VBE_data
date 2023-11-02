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

% Small specific arrangements: 
% - Work exclusively on the braille experts, as we are interested in the
%   organization of both scripts
opt.subjects = opt.mvpaGroups.experts;

% - Work only on beta images
opt.mvpa.map4D = {'beta'};

%% Set dataset
% distatis requires a stack of RDMs, one for each subject.
% Steps:
% - organize dataset
% - average different targets
% - get RDM
%
% After distatis, unlfatten function provides data to plot.
% (still unclear how)

% To set cosmo mvpa structure, we need:
% - labels
% - decoding conditions
% - indices
% - pairs
% they change based on our analyses
[condLabelName, decodingCondition, condLabelNb] = mvpa_assignDecodingConditions(opt);

% choose masks to be used
opt = mvpa_chooseMask(opt);
opt.maskLabel = {'VWFAfr'};

% Extract and stack single subject's RDMs
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
            if ismember(subMasks{iMask}, availableMasks) && ismember(maskLabel, opt.maskLabel)

                % display the used mask
                disp(subMasks{iMask});

                % 4D image
                imageName = ['sub-', subID, '_task-', opt.taskName{:}, '_space-', opt.space{:}, '_desc-4D_', opt.mvpa.map4D{iImage}, '.nii'];
                image = fullfile(ffxDir, imageName);
                
                % load cosmo input
                ds = cosmo_fmri_dataset(image, 'mask', mask);

                % Getting rid off zeros
                zeroMask = all(ds.samples == 0, 1);
                ds = cosmo_slice(ds, ~zeroMask, 2);
                
                % remove constant features
                ds = cosmo_remove_useless_data(ds);

                % set cosmo structure
                ds = setCosmoStructure(opt, ds, condLabelNb, condLabelName, iSub);

                % Compute average for each unique target (e.g. FRW)
                % Dataset should have one sample for each target
                ds_mean = cosmo_fx(ds, @(x)mean(x,1), 'targets');

                ds_rdm = cosmo_dissimilarity_matrix_measure(ds_mean);

                % set chunks (one chunk per subject)
                ds_rdm.sa.chunks = iSub * ones(size(ds_rdm.samples, 1), 1);
                ds_rdms{iSub} = ds_rdm;

            end
        end
    end
end

%% Stack all the RDMs in a single dataset
% still untouched
allRDMs_ds = cosmo_stack(ds_rdms);

% Run DISTATIS
distatis = cosmo_distatis(allRDMs_ds);

% Compute compromise distance matrix
[compromise_matrix, dim_labels, values] = cosmo_unflatten(distatis, 1);


% Plot multidimensional scaling: like a scatter-plot but fancy
labels={'FRW', 'FPW', 'FNW', 'FFS', 'BRW', 'BPW', 'BNW', 'BFS'};
n_labels=numel(labels);
figure();
imagesc(compromise_matrix)
title('DSM ROI: VWFA');
set(gca,'YTick',1:n_labels,'YTickLabel',labels);
set(gca,'XTick',1:n_labels,'XTickLabel',labels);
ylabel(dim_labels{1});
xlabel(dim_labels{2});
colorbar

% skip if stats toolbox is not present
if cosmo_check_external('@stats',false)
    figure();
    hclus = linkage(compromise_matrix);
    dendrogram(hclus,'labels',labels,'orientation','left');
    title('dendrogram ROI: VWFA');

    figure();
    F = cmdscale(squareform(compromise_matrix));
    text(F(:,1), F(:,2), labels);
    title('2D MDS plot ROI: VWFA');
    mx = max(abs(F(:)));
    xlim([-mx mx]); ylim([-mx mx]);
end


 


%% FUNCTION TO SET TARTGET, CHUNKS, LABELS FOR COSMO
% sets up the target, chunk, labels by stimuli condition labels, runs,
% number labels.
%
% Modified to accomodate for different design
% Now, one run contains half of the conditions
% To understand which order the scrpts have in each subject, refer to 
% opt.subsCondition.
% 
% copy-pasted from mvpa_pairwiseDecoding, maybe can be a separate function?

function ds = setCosmoStructure(opt, ds, condLabelNb, condLabelName, iSub)

% design info from opt
nbRun = opt.mvpa.nbRun;
betasPerCondition = opt.mvpa.nbTrialRepetition;

% chunk (runs), target (condition), labels (condition names)
conditionPerRun = length(condLabelNb);
betasPerRun = betasPerCondition * conditionPerRun;

% chunks = repmat((1:nbRun)', 1, betasPerRun);
firstChunk = opt.subsCondition{strcmp(opt.subsCondition(:,1),opt.subjects{iSub}),2}(1:6);
secondChunk = opt.subsCondition{strcmp(opt.subsCondition(:,1),opt.subjects{iSub}),2}(7:end);
chunks = horzcat(repmat(firstChunk', 1, betasPerRun/2), repmat(secondChunk', 1, betasPerRun/2));
chunks = chunks(:);

targets = repmat(condLabelNb', 1, nbRun/2)';
targets = targets(:);
targets = repmat(targets, betasPerCondition, 1);

condLabelName = repmat(condLabelName', 1, nbRun/2)';
condLabelName = condLabelName(:);
condLabelName = repmat(condLabelName, betasPerCondition, 1);

% assign our 4D image design into cosmo ds git
ds.sa.targets = targets;
ds.sa.chunks = chunks;
ds.sa.labels = condLabelName;

% figure; imagesc(ds.sa.chunks);

end








