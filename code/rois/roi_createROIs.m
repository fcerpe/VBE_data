%% Create ROIs based on peak coordinates from subjects' localizers
%
% Adapted from roi_multipleMethods, method #4
%
% From individual activation peaks identified by the localizers, extract
% the expansion for a specified number of voxels, then overlap the
% resulting mask with those extracted from neurosynth.org and relative to
% the same contrast: in visbra, 'visual words' for VWFA and 'objects' for LO
% 
% Outputs:
% - ROIs (duh) in the folder specified in roi_option
% - expansionReport_date.txt with a recap of the expansion process. It will
%   show 'area', 'method', 'iteration', 'p', 'sphere radius', 'number of
%   voxels'
%
% Steps:
% 1) get peak coordinates - requires hard-coded peaks, see roi_getMNIcoords
%
% 2) draw expansion with different thresholds 
%    - requires already-made contrasts with p = 0.001; 0.01; 0.05; 0.1
%      (made with stats_localizer)
% 
% 3) overlap localizer expansion with neurosynth thresholded mask
% 
% 4) resolve potential overlaps between areas (momentarily in a second
%    script)
%
% TO-DO (02/03/2023)
%   - can it merge expansion and neurosynth masks automatically, instead of
%     in two steps?
%   - can it resolve the overlaps in the same script? 

%% Initialize bidspm and the options we need
clear;
clc;

% add bidspm and init it
addpath '../lib/bidspm'
bidspm;

% get options
opt = roi_option();

% If not done previously, extract PPA, FFA, and V1 ROIs from visfatlas
if isempty(dir('*atlas-visfatlas*'))
    % PPA
    lh_ppa = extractRoiFromAtlas('masks/', 'visfatlas', 'CoS','L'); 
    
    % FFA
    lh_ffa1 = extractRoiFromAtlas('masks/', 'visfatlas', 'mFus','L'); % FFA-1 - left hemisphere
    lh_ffa2 = extractRoiFromAtlas('masks/', 'visfatlas', 'pFus','L'); % FFA-2 - left hemisphere
    % Join ROIs
    roi_mergeMasks(lh_ffa1, lh_ffa2, 'masks/hemi-L_space-MNI_atlas-visfatlas_label-FFA_mask');
    
    % V1
    lh_v1d = extractRoiFromAtlas('masks/', 'visfatlas', 'v1d','L'); % V1d - left hemisphere
    lh_v1v = extractRoiFromAtlas('masks/', 'visfatlas', 'v1v','L'); % V1v - left hemisphere
    rh_v1d = extractRoiFromAtlas('masks/', 'visfatlas', 'v1d','R'); % V1d - right hemisphere
    rh_v1v = extractRoiFromAtlas('masks/', 'visfatlas', 'v1v','R'); % V1v - right hemisphere
    % Join ROIs
    roi_mergeMasks(lh_v1d, lh_v1v, 'masks/hemi-L_space-MNI_atlas-visfatlas_label-V1_mask');
    roi_mergeMasks(rh_v1d, rh_v1v, 'masks/hemi-R_space-MNI_atlas-visfatlas_label-V1_mask');
    roi_mergeMasks('masks/hemi-L_space-MNI_atlas-visfatlas_label-V1_mask.nii', 'masks/hemi-R_space-MNI_atlas-visfatlas_label-V1_mask.nii', ...
                   'masks/hemi-B_space-MNI_atlas-visfatlas_label-V1_mask');

    % reslice everything to be in the same dimensional space
    dataImage = fullfile(opt.dir.stats, 'sub-007', 'task-wordsDecoding_space-IXI549Space_FWHM-2', 'beta_0001.nii');
    resliceRoiImages(dataImage, 'masks/hemi-L_space-MNI_atlas-visfatlas_label-CoS_mask.nii');
    resliceRoiImages(dataImage, 'masks/hemi-L_space-MNI_atlas-visfatlas_label-FFA_mask.nii');
    resliceRoiImages(dataImage, 'masks/hemi-B_space-MNI_atlas-visfatlas_label-V1_mask.nii');
end

%% Get the ROIs (actually just the spheres)

% get the resliced masks in the folder. Only 'visualWords' and 'objects'
% fit the criterium
neurosynthMasks = dir("masks/r*");

mni = roi_getMNIcoords(opt.subjects);

roiNames = opt.roiList;
save('ROI_controlled-expansion.mat', 'roiNames', 'mni');

% Specify region name, which contrast to use, hemisphere
% ! vwfa braille-defined is skipped for now. Peaks are useful, but decoding
% is not at the moment (02/03/2023) ! 
regName = {'VWFAfr','VWFAbr','lLO','rLO'};
contrastName = {'frenchGtScrambled', 'brailleGtScrambled', 'drawingGtScrambled', 'drawingGtScrambled'};
hemiName = {'L','L','L','R'};

% specify th number of voxels to keep
opt.numVoxels = 62;

for iSub = 1:length(opt.subjects)

    % Get subject number
    subName = ['sub-', num2str(opt.subjects{iSub})];

    % for each region this subject has
    for iReg = 1:length(mni{1}(:,1))

        % if the region is defined AND if it's not braille-defined VWFA 
        % VWFAbr: 
        % - control group doesn't have it
        % - not implemented
        if all(not(isnan(mni{iSub}(iReg, :)))) && iReg ~= 2 

            % STEP 1 : expansion around peak coordinates

            % Get the center
            ROI_center = mni{iSub}(iReg, :);
            
            % Get the reference image
            dataImage = fullfile(opt.dir.stats, subName, 'task-wordsDecoding_space-IXI549Space_FWHM-2', 'beta_0001.nii');

            % Get the filename of the corresponding contrast
            mask001InDir = dir(fullfile(opt.dir.stats, subName, 'task-visualLocalizer_space-IXI549Space_FWHM-6', ...
                [subName, '_task-visualLocalizer_space-IXI549Space_desc-', contrastName{iReg} ,'_*_p-0pt001_k-0_MC-none_mask.nii']));
            mask01InDir = dir(fullfile(opt.dir.stats, subName, 'task-visualLocalizer_space-IXI549Space_FWHM-6', ...
                [subName, '_task-visualLocalizer_space-IXI549Space_desc-', contrastName{iReg} ,'_*_p-0pt010_k-0_MC-none_mask.nii']));
            mask05InDir = dir(fullfile(opt.dir.stats, subName, 'task-visualLocalizer_space-IXI549Space_FWHM-6', ...
                [subName, '_task-visualLocalizer_space-IXI549Space_desc-', contrastName{iReg} ,'_*_p-0pt050_k-0_MC-none_mask.nii']));
            mask1InDir = dir(fullfile(opt.dir.stats, subName, 'task-visualLocalizer_space-IXI549Space_FWHM-6', ...
                [subName, '_task-visualLocalizer_space-IXI549Space_desc-', contrastName{iReg} ,'_*_p-0pt100_k-0_MC-none_mask.nii']));
            
            % Get the full path: folder + name
            localizer001Mask = fullfile(mask001InDir.folder, mask001InDir.name);
            if not(isempty(mask05InDir)), localizer05Mask = fullfile(mask05InDir.folder, mask05InDir.name);
            end
            if not(isempty(mask01InDir)), localizer01Mask = fullfile(mask01InDir.folder, mask01InDir.name);
            end
            if not(isempty(mask1InDir)),  localizer1Mask = fullfile(mask1InDir.folder, mask1InDir.name);
            end

            % specify the sphere characteristics for each of them
            sphereParams = struct;
            sphereParams.location = ROI_center;
            sphereParams.radius = 1; % starting radius
            sphereParams.maxNbVoxels = opt.numVoxels;

            specification = struct('mask1', localizer001Mask, 'maskSphere', sphereParams);

            % add other masks, if present
            if not(isempty(mask01InDir)),   specification.mask2 = localizer01Mask;
            end
            if not(isempty(mask05InDir)),   specification.mask3 = localizer05Mask;
            end
            if not(isempty(mask1InDir)),    specification.mask4 = localizer1Mask;
            else

            end
            % specify the path for each subject
            outputPath = [opt.dir.rois,'/',subName];

            fprintf('\nWorking on %s, area %s \n',subName, char(regName{iReg}));
           
            % expansion based on localizer mask(s): 
            % - draw progressively larger spheres around the peak
            %   coordinates and take only the active voxels in the mask
            % - if the sphere expands without including other voxels, means
            %   the cluster is finished: use a more lax threshold and try
            %   again until we reach our number of voxels
            [sphereMask, sphMaskName] = roi_createCustomExpansion(specification, dataImage, outputPath, opt.saveROI, 1);

            % manipulations on the filename to make it more readable
            sphMaskJustTheName = sphMaskName(1:end-4);
            findVox = split(sphMaskJustTheName, {'Vox','_desc'});

            % Set up a custom bids-like name
            bidslikeName = fullfile(opt.dir.rois, subName, [subName,'_','space-MNI','_', 'trial-Expansion_' , ...
                'label-',char(regName{iReg}),'_','voxels-',findVox{2},'vx','_mask']);

            % rename both the .nii and the .json files to the new name
            movefile(sphMaskName, [bidslikeName,'.nii'],'f')
            movefile([sphMaskJustTheName,'.json'], [bidslikeName,'.json'],'f')

            % reslice the mask to make sure fits our voxel size and voxel
            % space
            sphereMask = resliceRoiImages(dataImage, [bidslikeName, '.nii']);


            % STEP 2 : intersection with neurosynth mask
            % (could be written to be more efficient, at the moment
            % (20/02/23) it's a WIP)

            % Get the neurosynth masks
            % 'objects' is first because of [B]ilateral hemisphere 
            % 'visualWords' has only [L]eft hemisphere
            switch iReg
                case {1,2}, nsMask = fullfile(neurosynthMasks(2).folder, neurosynthMasks(2).name);
                case {3,4}, nsMask = fullfile(neurosynthMasks(1).folder, neurosynthMasks(1).name);
            end

            % Open the image to make sure it's uint8
            % otherwise it's not read properly
            temp = load_nii(nsMask);
            temp.img = cast(temp.img, 'uint8');
            save_nii(temp, nsMask);

            % specify the objects to pass: mask + sphere or mask + mask
            specMasks = struct('mask1', nsMask, ...
                               'mask2', sphereMask);

            % specify the path for each subject
            outputPath = [opt.dir.rois,'/',subName];

            % intersection between expansion and neurosynth mask: 
            [intersectedMask, intersectedName] = roi_createMasksOverlap(specMasks, dataImage, outputPath, opt.saveROI);

            % Rename .json and .nii files of both masks to have more readable names
            % Remove file extension from name
            intersectedJustTheName = intersectedName(1:end-4);

            % New names
            intersectedNewName = fullfile(opt.dir.rois, subName, ...
                                [subName, '_hemi-' hemiName{iReg} ...
                                '_space-MNI_atlas-neurosynth_method-expansionIntersection_label-' regName{iReg} '_mask']);
 
            % Rename intersection
            movefile(intersectedName, [intersectedNewName,'.nii'],'f')
            movefile([intersectedJustTheName,'.json'], [intersectedNewName,'.json'],'f')

            % reslice the masks
            intersectedMask = resliceRoiImages(dataImage, [intersectedNewName, '.nii']);

        end
    end
end

