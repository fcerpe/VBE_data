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
%
% 5) anatomically-defined ROIs (suspended for now, need to check with Elahe')

%% clear
clear;
clc;

%% Method #1 - Take everything that is where the area is supposed to be

% add cpp repo
initCppSpm;

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
                case 1
                    regName = 'VWFAfr';
                case 2
                    regName = 'VWFAbr';
                case 3
                    regName = 'lLO';
                case 4
                    regName = 'lpFS';
                case 5
                    regName = 'rLO';
                case 6
                    regName = 'rpFS';
            end

            % Set up bids-like name
            bidslikeName = [subName,'_','space-MNI','_', 'trial-NeurosynthCoords_' , ...
                'label-',regName,'_','radius-',num2str(opt.radius),'mm','_mask'];

            betaReference = fullfile(opt.dir.stats, subName, ...
                'task-wordsDecoding_space-IXI549Space_FWHM-2_node-wordsDecodingMVPA', ...
                'spmT_0001.nii');

            % specify the sphere characteristics for each of them
            sphereParams = struct;
            sphereParams.location = ROI_center;
            sphereParams.radius = 10;

            % specify the path for each subject
            outputPath = [opt.dir.rois,'/',subName];

            mask = createRoi('sphere', sphereParams, betaReference, outputPath, opt.saveROI);

            path = '../../outputs/derivatives/cpp_spm-rois/';
            nativeName = ['label-',mask.label,'_mask'];
            movefile([path, subName, '/', nativeName,'.nii'], [path, subName, '/', bidslikeName,'.nii'])
            movefile([path, subName, '/', nativeName,'.json'], [path, subName, '/', bidslikeName,'.json'])
            % rename the mask to a bids-like name
            % movefile oldName newName
            % - find folder and name
            % - rename
        end
    end
end

%% Method #2 and #3 - 8mm and 10mm spheres around individual coordinates (one script for efficiency)

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

                betaReference = fullfile(opt.dir.stats, subName, ...
                    'task-wordsDecoding_space-IXI549Space_FWHM-2_node-wordsDecodingMVPA', ...
                    'spmT_0001.nii');

                % specify the sphere characteristics for each of them
                sphereParams = struct;
                sphereParams.location = ROI_center;
                sphereParams.radius = rad;

                % specify the path for each subject
                outputPath = [opt.dir.rois,'/',subName];

                mask = createRoi('sphere', sphereParams, betaReference, outputPath, opt.saveROI);

                path = '../../outputs/derivatives/cpp_spm-rois/';
                nativeName = ['label-',mask.label,'_mask'];
                movefile([path, subName, '/', nativeName,'.nii'], [path, subName, '/', bidslikeName,'.nii'])
                movefile([path, subName, '/', nativeName,'.json'], [path, subName, '/', bidslikeName,'.json'])
            end
        end
    end
end

%% Method #4 - expanding volume of 150vx starting from individual peaks

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

            % Set up bids-like name
            bidslikeName = [subName,'_','space-MNI','_', 'trial-IndividualCoords_' , ...
                'label-',regName,'_','voxels-',num2str(opt.numVoxels),'vx','_mask'];

            betaReference = fullfile(opt.dir.stats, subName, ...
                'task-wordsDecoding_space-IXI549Space_FWHM-2_node-wordsDecodingMVPA', ...
                'spmT_0001.nii');

            % specify the sphere characteristics for each of them

            sphereParams = struct;
            sphereParams.location = ROI_center;
            sphereParams.radius = 1; % starting radius
            sphereParams.maxNbVoxels = opt.numVoxels;

            specification = struct('mask1', [path, subName, '/', bidslikeName], ...
                                   'mask2', sphereParams);

            % specify the path for each subject
            outputPath = [opt.dir.rois,'/',subName];

            mask = createRoi('expand', specification, betaReference, outputPath, opt.saveROI);

            path = '../../outputs/derivatives/cpp_spm-rois/';
            nativeName = ['label-',mask.label,'_mask'];
            movefile([path, subName, '/', nativeName,'.nii'], [path, subName, '/', bidslikeName,'.nii'])
            movefile([path, subName, '/', nativeName,'.json'], [path, subName, '/', bidslikeName,'.json'])
        end
    end
end

%% #5 Anatomically-defined ROIs
% Speak with Elahe', she is the one doing them right now


%             % create the sphere with marsbar (OLD WAY) and save it
%             params = struct('centre', ROI_center, 'radius', opt.radius);
%             roi = maroi_sphere(params);
%             saveroi(roi, [ROI_save_name, '.mat']);
%             mars_rois2img([ROI_save_name, '.mat'], [ROI_save_name, '.nii']);
%             % Delete .mat files, not necessary
%             delete([ROI_save_name, '_labels.mat']);
%             delete([ROI_save_name, '.mat']);

