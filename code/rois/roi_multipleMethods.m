%% Trial: create ROIs in different ways
%
% To settle a debate between Hans and Olivier: which ROI definition method
% should we use?
% 1) 10mm sphere around neurosynth coordinates
%    VWFA = -44 -56 -16, keyword: words
%    lLO  = -47 -70 -5
%    lpFS = -39 -55 -18
%    rLO  =  47 -70 -5
%    rpFS =  42 -50 -20, keyword: objects
%
% 2) 10mm sphere around individual coordinates (extracted from a 10mm
%    sphere around the neurosynth coordinates)
%
% 3) 8mm sphere around individual coordinates
%
% 4) expanding volume of 150 voxels around the individual coordinates
%    not done in this point. For now we apply the binary mask to it
%
% 5) anatomically-defined ROIs (suspended for now, need to check with Elahe')

%% clear
clear;
clc;

%% Method #1 - Take everything that is where the area is supposed to be

% add bidspm and init it
addpath '/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/code/lib/bidspm'
bidspm;

% marsbar;
% options > edit options > base space for ROIs > get your spmT.nii > accept
% AUTOMATIZE THIS

% get options
opt = roi_option();

% get general coordinates (manual input)
mni{1}(1, 1:3) = [-4.420000e+01, -5.480000e+01, -1.540000e+01];  % VWFA FRE
mni{1}(2, 1:3) = [-4.420000e+01, -5.480000e+01, -1.540000e+01];  % VWFA BRA
mni{1}(3, 1:3) = [-4.680000e+01, -7.040000e+01, -0.500000e+01];  %  LO LEFT
mni{1}(4, 1:3) = [-3.900000e+01, -5.480000e+01, -1.800000e+01];  % PFS LEFT
mni{1}(5, 1:3) = [ 4.680000e+01, -7.040000e+01, -0.500000e+01];  %  LO RIGHT
mni{1}(6, 1:3) = [ 4.160000e+01, -4.960000e+01, -2.060000e+01];  % PFS RIGHT

roiNames = opt.roiList;
save('ROI-trial_neurosynth-coords.mat', 'roiNames', 'mni');

% Get the ROIs (actually just the spheres)

for iSub = 1:length(opt.subjects)

    % Get subject number
    subName = ['sub-', num2str(opt.subjects{iSub})];

    % for each region this subject has
    for iReg = 1:length(mni{1}(:,1))

        % if the region is defined (vwfa-br for all, but in some is not present)
        if not(isnan(mni{1}(iReg, :)))

            % Get the center
            ROI_center = mni{1}(iReg, :);

            % Get the name of the roi for filename
            switch iReg
                case 1, regName = 'VWFAfr';
                case 2, regName = 'VWFAbr';
                case 3, regName = 'lLO';
                case 4, regName = 'lpFS';
                case 5, regName = 'rLO';
                case 6, regName = 'rpFS';
            end

            % Set up bids-like name
            bidslikeName = [subName,'_','space-MNI','_', 'trial-NeurosynthCoords_' , ...
                'label-',regName,'_','radius-',num2str(opt.radius),'mm','_mask'];

            betaReference = fullfile(opt.dir.stats, subName, ...
                'task-wordsDecoding_space-IXI549Space_FWHM-2', ...
                'beta_0001.nii');

            % specify the sphere characteristics for each of them
            sphereParams = struct;
            sphereParams.location = ROI_center;
            sphereParams.radius = 10;

            % specify the path for each subject
            outputPath = [opt.dir.rois,'/',subName];

            mask = createRoi('sphere', sphereParams, betaReference, outputPath, opt.saveROI);

            path = '../../outputs/derivatives/cpp_spm-rois/';
            nativeName = ['label-',mask.label,'_mask'];
            movefile([path, subName, '/', nativeName,'.nii'], [path, subName, '/', bidslikeName,'.nii'],'f')
            movefile([path, subName, '/', nativeName,'.json'], [path, subName, '/', bidslikeName,'.json'],'f')

            % reslice
            roiPath = fullfile(opt.dir.rois, subName, [bidslikeName, '.nii']);
            mask = resliceRoiImages(betaReference,roiPath);

        end
    end
end

%% Method #2 and #3 - 8mm and 10mm spheres around individual coordinates (one script for efficiency)
% Technically intersections between sphere and brain mask

% get individual coordinates
mni = roi_getMNIcoords(opt.subjects);

roiNames = opt.roiList;
save('ROI-trial_indivudal-coords.mat', 'roiNames', 'mni');

% Get the ROIs (actually just the spheres)

for iSub = 1:length(opt.subjects)

    % Get subject number
    subName = ['sub-', num2str(opt.subjects{iSub})];

    % for each region this subject has
    for iReg = 1:length(mni{1}(:,1))

        % if the region is defined (vwfa-br for all, but in some is not present)
        if not(isnan(mni{iSub}(iReg, :)))

            % Get the center
            ROI_center = mni{iSub}(iReg, :);

            % Get the name of the roi for filename
            switch iReg
                case 1, regName = 'VWFAfr';
                case 2, regName = 'VWFAbr';
                case 3, regName = 'lLO';
                case 4, regName = 'lpFS';
                case 5, regName = 'rLO';
                case 6, regName = 'rpFS';
            end

            for rad = 8:2:10

                % Set up bids-like name
                bidslikeName = [subName,'_','space-MNI','_', 'trial-IndividualCoords_' , ...
                    'label-',regName,'_','radius-',num2str(rad),'mm','_mask'];

                betaReference = fullfile(opt.dir.stats, subName, 'task-wordsDecoding_space-IXI549Space_FWHM-2', 'beta_0001.nii');

                % anatomical mask is brain mask, make sure that the sphere
                % doesn't excedd the limits of what makes sense
                brainMask = fullfile(opt.dir.stats, subName, 'task-wordsDecoding_space-IXI549Space_FWHM-2', 'mask.nii'); 

                % specify the sphere characteristics for each of them
                sphereParams = struct;
                sphereParams.location = ROI_center;
                sphereParams.radius = rad;

                % % specify the object to pass: mask + sphere
                specification = struct('mask1', brainMask, ...
                                       'mask2', sphereParams);

                % specify the path for each subject
                outputPath = [opt.dir.rois,'/',subName];

                mask = createRoi('intersection', specification, betaReference, outputPath, opt.saveROI);

                path = '../../outputs/derivatives/cpp_spm-rois/';
                nativeName = ['label-',mask.label,'_mask'];
                movefile([path, subName, '/', nativeName,'.nii'], [path, subName, '/', bidslikeName,'.nii'],'f')
                movefile([path, subName, '/', nativeName,'.json'], [path, subName, '/', bidslikeName,'.json'],'f')

                % reslice
                roiPath = fullfile(opt.dir.rois, subName, [bidslikeName, '.nii']);
                mask = resliceRoiImages(betaReference,roiPath);
            end
        end
    end
end

%% Method #4 - expanding volume of 150vx starting from individual peaks

% 4.1 Apply mask from localizer peaks - created in localizer_stats

% which name to assign: 1 to 6 based on the region
regName = ["VWFAfr","VWFAbr","lLO","lpFS","rLO","rpFS"];

% which ROI mask to look for: 1 to 6 based on the contrast
%                             1 if responses were saved, 2 if not
% e.g. roiDesc(1,2) = french contrast, no responses
roiDescriptions = ["frenchGtScrambled_label-0032",  "brailleGtScrambled_label-0033", "drawingGtScrambled_label-0034", ...
                   "drawingGtScrambled_label-0034", "drawingGtScrambled_label-0034", "drawingGtScrambled_label-0034"; ...
                   "frenchGtScrambled_label-0029",  "brailleGtScrambled_label-0030", "drawingGtScrambled_label-0031", ...
                   "drawingGtScrambled_label-0031", "drawingGtScrambled_label-0031", "drawingGtScrambled_label-0031"];

for iSub = 1:length(opt.subjects)

    % Get subject number
    subName = ['sub-', num2str(opt.subjects{iSub})];

    switch subName
        case{'sub-007','sub-008'}
            roiDesc = roiDescriptions(2,:); % response missing in only 2 subs
        otherwise
            roiDesc = roiDescriptions(1,:);
    end

    % for each region this subject has
    for iReg = 1:length(mni{1}(:,1))

        % if the region is defined (vwfa-br in some is not present)
        if not(isnan(mni{iSub}(iReg, :)))

            % Get the center
            ROI_center = mni{iSub}(iReg, :);

            dataImage = fullfile(opt.dir.stats, subName, 'task-wordsDecoding_space-IXI549Space_FWHM-2', ...
                'beta_0001.nii');

            roiChar = char(roiDesc(iReg));
            localizerMask = fullfile(opt.dir.stats, subName, 'task-visualLocalizer_space-IXI549Space_FWHM-6', ...
                [subName, '_task-visualLocalizer_space-IXI549Space_desc-', roiChar ,'_p-0pt001_k-0_MC-none_mask.nii']);

            % all cases where the expansion sphere is over 15mm from the individual peak, suspicious

            lowerThresConditions = (strcmp(subName, 'sub-009') && iReg == 2) || (strcmp(subName, 'sub-007') && iReg == 1) || ...
                (strcmp(subName, 'sub-006') && iReg == 1) || (strcmp(subName, 'sub-006') && iReg == 3) || ...
                (strcmp(subName, 'sub-006') && iReg == 5);

            if lowerThresConditions
                localizerMask = fullfile(opt.dir.stats, subName, 'task-visualLocalizer_space-IXI549Space_FWHM-6', ...
                    [subName, '_task-visualLocalizer_space-IXI549Space_desc-', roiChar ,'_p-0pt05_k-0_MC-none_mask.nii']);
            end

            % specify the sphere characteristics for each of them
            sphereParams = struct;
            sphereParams.location = ROI_center;
            sphereParams.radius = 1; % starting radius
            sphereParams.maxNbVoxels = opt.numVoxels;

            specification = struct('mask1', localizerMask, ...
                'mask2', sphereParams);

            % specify the path for each subject
            outputPath = [opt.dir.rois,'/',subName];

            fprintf('\nWorking on %s, area %s',subName,char(regName(iReg)));

            % just to know which is not right
            mask = createRoi('expand', specification, dataImage, outputPath, opt.saveROI);

            path = '../../outputs/derivatives/cpp_spm-rois/';

            nativeName = [subName, '_task-visualLocalizer_space-IXI549Space_label-', ...
                roiChar(end-3:end),'E',mask.label(2:end),'_desc-', roiChar(1:end-11), localizerMask(end-29:end-4)]; % p-0pt001_k-0_MC-none_mask

            if lowerThresConditions
                nativeName = [subName, '_task-visualLocalizer_space-IXI549Space_label-', ...
                    roiChar(end-3:end),'E',mask.label(2:end),'_desc-', roiChar(1:end-11), localizerMask(end-28:end-4)]; % p-0pt05_k-0_MC-none_mask
            end

            finalVoxs = mask.label;
            finalVoxs(1:9) = [];

            % Set up bids-like name
            bidslikeName = [subName,'_','space-MNI','_', 'trial-IndividualCoords_' , ...
                'label-',char(regName(iReg)),'_','voxels-',finalVoxs,'vx','_mask'];

            movefile([path, subName, '/', nativeName,'.nii'], [path, subName, '/', bidslikeName,'.nii'],'f')
            movefile([path, subName, '/', nativeName,'.json'], [path, subName, '/', bidslikeName,'.json'],'f')

            % reslice
            roiPath = fullfile(opt.dir.rois, subName, [bidslikeName, '.nii']);
            mask = resliceRoiImages(dataImage, roiPath);
        end
    end
end

%% #5 Anatomically-defined ROIs
% ROIs created using SPM Anatomy toolbox
% (https://github.com/inm7/jubrain-anatomy-toolbox)
%
% CPP_ROI has 'getDataFromIntersection' to extract an ROI from a mask and a
% sphere

% which name to assign: 1 to 6 based on the region
regName = {'VWFAfr','VWFAbr','lLO','lpFS','rLO','rpFS'};

mni = roi_getMNIcoords(opt.subjects);

roiNames = opt.roiList;
save('ROI-trial_indivudal-coords.mat', 'roiNames', 'mni');

% Get the ROIs (actually just the spheres)
for iSub = 1:length(opt.subjects)

    % Get subject number
    subName = ['sub-', num2str(opt.subjects{iSub})];

    specificRegions = [1 2 4 6];

    % for each region this subject has
    for iReg = 1:length(mni{1}(:,1))

        % if the region is defined (vwfa-br for all, but in some is not present)
        % and if there is a definitve anatomical mask: applicable to 
        % VWFAs and lpFS
        if ismember(iReg,specificRegions) && not(all(isnan(mni{iSub}(iReg, :))))

            % Sphere data: get the center, radius is fixed
            ROI_center = mni{iSub}(iReg, :);
            opt.radius = 10;

            % Set up bids-like name to save ROI
            bidslikeName = [subName,'_','space-MNI','_','trial-AnatIntersection_', ...
                            'label-',regName{iReg},'_','radius-',num2str(opt.radius),'mm','_mask'];

            % Get the reference, a random beta
            betaReference = fullfile(opt.dir.stats, subName, 'task-wordsDecoding_space-IXI549Space_FWHM-2', 'beta_0001.nii');

            % Get the anatomical mask based on the contrast
            % left fg for vwfa
            if ismember(iReg,[1 2 4])
                anatomicalMask = 'JuBrain_ROIs/sub-none_space-MNI_desc-leftFG_label-0000_mask.nii'; 
            else % right hemisphere
                anatomicalMask = 'JuBrain_ROIs/sub-none_space-MNI_desc-rightFG_label-0000_mask.nii';
            end

            % Reslice it for compatibility with our 2.6mm voxel size
            anatomicalMask = resliceRoiImages(betaReference,anatomicalMask);

            % convert the data-type of the nii file from 'single' to
            % 'uint8', otherwise isBinaryMask does not work
            thisMask = load_nii(anatomicalMask);
            thisMask.img = cast(thisMask.img,'uint8');
            save_nii(thisMask,anatomicalMask);

            % specify the sphere characteristics for each of them
            sphereParams = struct;
            sphereParams.location = ROI_center;
            sphereParams.radius = opt.radius;

            % specify the object to pass: mask + sphere
            specification = struct('mask1', anatomicalMask, ...
                                   'mask2', sphereParams);

            % specify the path for each subject
            outputPath = [opt.dir.rois,'/',subName];

            mask = createRoi('intersection', specification, betaReference, outputPath, opt.saveROI);

            path = '../../outputs/derivatives/cpp_spm-rois/';
            if iReg == 6
                nativeName = 'rsub-none_space-MNI_label-0000Intersection_desc-rightFG_mask';                
            else
                nativeName = 'rsub-none_space-MNI_label-0000Intersection_desc-leftFG_mask';
            end
            movefile([path, subName, '/', nativeName,'.nii'], [path, subName, '/', bidslikeName,'.nii'],'f')
            movefile([path, subName, '/', nativeName,'.json'], [path, subName, '/', bidslikeName,'.json'],'f')

            % reslice
            roiPath = fullfile(opt.dir.rois, subName, [bidslikeName, '.nii']);
            mask = resliceRoiImages(betaReference,roiPath);

        end
    end
end

%% NOT NEEDED ANYMORE - OLD MARSBAR WAY

% % create the sphere with marsbar (OLD WAY) and save it
% params = struct('centre', ROI_center, 'radius', opt.radius);
% roi = maroi_sphere(params);
% saveroi(roi, [ROI_save_name, '.mat']);
% mars_rois2img([ROI_save_name, '.mat'], [ROI_save_name, '.nii']);
% % Delete .mat files, not necessary
% delete([ROI_save_name, '_labels.mat']);
% delete([ROI_save_name, '.mat']);

