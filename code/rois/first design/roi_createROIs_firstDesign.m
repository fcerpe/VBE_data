%% Create ROIs for the early subjects (001, 002, 003) with the new methods


%% clear
clear;
clc;

% add spm to the path
addpath(fullfile(pwd, '..', 'lib', 'bidspm'));
addpath(fullfile(pwd, '..', 'lib', 'CPP_BIDS'));
bidspm;

% get options
opt = roi_firstDesign_option();

%% Method: 8mm sphere around individual coordinates

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

            % Set up bids-like name
            bidslikeName = [subName,'_','space-MNI','_', 'trial-IndividualCoords_' , ...
                'label-',regName,'_','radius-',num2str(opt.radius),'mm','_mask'];

            betaReference = fullfile(opt.dir.stats, subName, ...
                'task-visualEventRelated_space-IXI549Space_FWHM-2', ...
                'beta_0001.nii');

            % specify the sphere characteristics for each of them
            sphereParams = struct;
            sphereParams.location = ROI_center;
            sphereParams.radius = opt.radius;

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
