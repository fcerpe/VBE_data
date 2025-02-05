%% ROI from neurosynth
% From an extracted neurosynth (ns) mask, reslice it to the MNI space of
% the experiment's subjects, then extract the top 100 voxels and save the
% sliced and thresholded ROI


% Load reference for reslicing (static, does not matter which participant)
dataImage = '/Volumes/fcerpe_phd/VBE_data/outputs/derivatives/bidspm-stats/sub-006/task-visualLocalizer_space-IXI549Space_FWHM-6_node-localizerGLM/beta_0001.nii';

% Load the mask downloaded from neurosynth 
% Contrarily to what I thought, downloading the mask does not threshold it,
% se we do it by hand
nsImage = '/Volumes/fcerpe_phd/VBE_data/code/rois/masks/neurosynth/hemi-L_space-MNI_atlas-neurosynth_label-visualWords_threshold-7_mask.nii';

% Reslice the mask to put it in the same space as the participants
nsResliced = resliceRoiImages(dataImage, nsImage);

% Load the resliced ROI
% (equivalent to loading the mask with the same name and 'r' at the
% beginning) 
nsNifti = load_nii(nsResliced);

% Extract the active voxels
activeVoxels = nsNifti.img(nsNifti.img > 0);

% Sort them from the highest
sortedVoxels = sort(activeVoxels, 'descend');

% Pick the 100th value as threashold, save only the values above it
thresholdVoxel = sortedVoxels(100);

% Threshold the mask: 
% what is below is cast as 0
% what is above becomes 20 (to avoid issues with uint8 conversion) and then
% 1
nsNifti.img(nsNifti.img >= thresholdVoxel) = 20;

% Cast voxels as integer, to prevent issues went setting to zero
nsNifti.img = uint8(nsNifti.img);
nsNifti.img(nsNifti.img < thresholdVoxel) = 0;

nsNifti.img(nsNifti.img == 20) = 1;

nsNiftiPath = 'masks/neurosynth/hemi-L_space-MNI_atlas-neurosynth_label-visualWords_vox-100_mask.nii';

% Save the general ROI in masks/neurosynth
save_nii(nsNifti, nsNiftiPath)


% Apply the mask on the space of each subject, and save in the individual
% subject's folder in derivatives/cpp_spm-rois

% specify the folder contating the localizer activations
localizerStatsFolder = ['task-visualLocalizer_space-',opt.space{1},'_FWHM-6_node-localizerGLM'];

% for each subject
for iSub = 1:length(opt.subjects)

    % Get subject number
    subName = ['sub-', num2str(opt.subjects{iSub})];

    % load subject specific reference
    % space is the same for each participant, but there might be some sign
    % issues that is good to correct
    subDataImage = fullfile(opt.dir.stats, subName, localizerStatsFolder, 'beta_0001.nii');

    % reslice on the participant's space
    nsSubResliced = resliceRoiImages(subDataImage, nsNiftiPath);

    % open the resliced nii
    nsSubNifti = load_nii(nsSubResliced);
    nsSubNifti.img = uint8(nsSubNifti.img);

    % save in right place with right name
    filename = fullfile(opt.dir.rois, subName, ['r', subName, '_hemi-L_space-IXI549Space_atlas-neurosynth_label-visualWords_vox-100_mask.nii']);
    
    save_nii(nsSubNifti, filename)


end
