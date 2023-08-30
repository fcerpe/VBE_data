%% Create ROIs based on peak coordinates from subjects' localizers
%
% From Fedorenko's parcels (Fedorenko et al. 2010).
% Extract the language ROIs, reslice them, and apply them to individual data
%
% Outputs:
% - ROIs (duh) in the 'code/rois/masks'
% - ROIs in the folder specified in roi_option
%
% TO-DO (08/08/2023)
%   - for each sub and roi, take the masks and apply them to ??? (copy
%     other script)

% If not done previously, extract language ROIs from Fedorenko's parcels
if isempty(dir('masks/fedorenko_parcels/r*atlas-fedorenko*'))

    getRoiFromParcels(opt);
    
end

% Apply the masks to subject data and get single participant's ROIs
% Localizer

%% Overlap the fROI to each subject VWFA contrast 

% get the resliced masks in the folder (created by code above)
fedorenkoMasks = dir('masks/fedorenko_parcels/r*');

% TL;DR
% Get each subject's constrasts [FW > SFW] and [BW > SBW]. In eacch of
% them, overlap the contrast with each of Fedorenko's fROIs.
% 'languageRoiReport_date.txt' contains a quick report of which area of
% each sub, area, contrast has been written

% Initialize report
repFile = dir(['languageRoiReport_' date '.txt']);
if not(isempty(repFile))
    % If there are already reports, name this 'report_date_1.txt'
    reportID = size(repFile,1);
else
    reportID = 0;
end
% Start a new report
report = [];

for iSub = 1:length(opt.subjects)

    % Get subject number
    subName = ['sub-', num2str(opt.subjects{iSub})];

    % Get a reference image for this sub
    dataImage = fullfile(opt.dir.stats, subName, ...
                         'task-visualLocalizer_space-IXI549Space_FWHM-6_node-localizerGLM', 'beta_0001.nii');

    % Get the contrasts: [FW > SFW] and, if expert, [BW > SBW] 
    subConFR = dir(fullfile(opt.dir.stats, subName, 'task-visualLocalizer_space-IXI549Space_FWHM-6_node-localizerGLM', ...
                   'sub-*_space-IXI549Space_desc-f*pt05*_mask.nii'));
    subConBR = [];
    if ismember(opt.subjects{iSub}, {'006','007','008','009','012','013'})
        subConBR = dir(fullfile(opt.dir.stats, subName, 'task-visualLocalizer_space-IXI549Space_FWHM-6_node-localizerGLM', ...
                       'sub-*_space-IXI549Space_desc-b*pt05*_mask.nii'));
    end

    % Join them to make looping easier
    subContrasts = vertcat(subConFR,subConBR);

    % Go through the relevant contrasts (should only be two for now)
    for iCon = 1:size(subContrasts,1)

        thisContrast = fullfile(subContrasts(iCon).folder, subContrasts(iCon).name);
        
        % Get the type of stimuli of the contrast, to be specified later in
        % the new ROI name
        conName = strsplit(thisContrast,{'desc-','Gt'});
        con = conName{2};

        % From this contrast, cut out all the necessary fROIs
        for iFed = 1:size(fedorenkoMasks,1)
            
            thisROI = fullfile(fedorenkoMasks(iFed).folder, fedorenkoMasks(iFed).name);

            % Reslice on each sub, necessary fro PPI.
            % Only one time, it's not necessary to do it for each contrast
            if iCon == 1
                unslicedRoi = fullfile(fedorenkoMasks(iFed).folder, fedorenkoMasks(iFed).name(2:end));
                resliceOnParticipant(unslicedRoi, opt, subName);
            end

            % Get name and hemisphere
            strName = strsplit(thisROI, {'_','-'});
            hemi = strName{4};
            reg = strName{10};

            % Load the mask and cast it as uint8, otherwise it's not
            % recognized as a binary mask
            recastROI = load_nii(thisROI);
            recastROI.img = cast(recastROI.img, 'uint8');
            save_nii(recastROI, thisROI);
            
            % specify the objects to pass: mask + mask
            specMasks = struct('mask1', thisROI, ...
                               'mask2', thisContrast);

            % specify the path for each subject
            outputPath = fullfile(opt.dir.rois, subName);

            % Reset fROI name. In case it stays empty, it means the ROI was
            % not created, thus there is no name change to do
            froiName = [];

            % Intersection of localizer spmT and mask (TBD)
            [froiMask, froiName] = roi_createMasksOverlap(specMasks, dataImage, outputPath, opt.saveROI);

            % Only rename ROI if an ROI was indeed created in the previous
            % line, otehrwise try with the next one
            if ~isempty(froiName)
                % Rename .json and .nii files of both masks to have more readable names
                % Remove file extension from name
                froiJustName = froiName(1:end-4);
                % New names
                froiNewName = fullfile(opt.dir.rois, subName, [subName, '_hemi-' hemi ...
                                       '_space-MNI_atlas-fedorenko_contrast-' con '_label-' reg '_mask']);
                % Rename intersection
                movefile(froiName, [froiNewName,'.nii'],'f')
                movefile([froiJustName,'.json'], [froiNewName,'.json'],'f')
                % reslice the masks
                intersectedMask = resliceRoiImages(dataImage, [froiNewName, '.nii']);
            end

            % Add information to the report
            % get a proper info for the roi name
            if isempty(froiName), done = 'skipped';
            else, done = 'created';
            end
            report = vertcat(report, ...
                {subName, con, hemi, reg, done});


        end
    end
end

% save report
if reportID == 0, writecell(report,['languageRoiReport_' date '.txt']);
else, writecell(report,['languageRoiReport_' date '_' num2str(reportID) '.txt']);
end



%% FUNCTION TO EXTRACT ALL FEDORENKO'S PARCELS
function getRoiFromParcels(opt)
% Code to extract ROIs from atlas is taken and adapted from the
% extractRoiFromAtlas function of CPP_ROI
% 09/08/23: addition of the atlas to the defaults of CPP_ROI is in
%           process

% load look-up table and get ROI names
fedLut = spm_load('masks/fedorenko_parcels/LUT.csv');
roiNames = fedLut.ROI';

% load parcels .nii file and get the volume data
fedHdr = spm_vol('masks/fedorenko_parcels/allParcels_language_SN220.nii');
fedVol = spm_read_vols(fedHdr);

% There are 12 ROIs (see lut.csv for a list of them)
% Loop through them and extracct them all
for r = 1:numel(roiNames)

    label = fedLut.label(r);
    labelStruct = struct('ROI', roiNames{r}, ...
                         'label', label);
    
    % create 'negative' vol that is all zeros, set as one only the voxels
    % corresponding with the current ROI label
    outputVol = false(size(fedVol));
    outputVol(fedVol == labelStruct.label) = true;

    % Personal addition, adhere to the common naming for ROIs
    % Split the name of the parcel in two: 
    % - hemisphere goes after 'hemi' attribute,
    % - area goeas after 'label'
    strName = strsplit(roiNames{r}, '_');
    hemi = strName{1}(1);
    reg = strName{2};
    roiFilename = ['hemi-' hemi '_space-MNI_atlas-fedorenko_label-' reg '_mask.nii'];

    % Assign the new filename to the ROI and save it
    fedHdr.fname = spm_file(fedHdr.fname, 'filename', roiFilename);
    spm_write_vol(fedHdr, outputVol);

    % reslice them to be in the same space as our beta maps
    % to do so, we need a beta map of reference
    % It does not matter which sub now, when we apply them to single
    % subjecct they'll be resliced with their distorsions
    dataImage = fullfile(opt.dir.stats, 'sub-006', ...
                         'task-visualLocalizer_space-IXI549Space_FWHM-6_node-localizerGLM', 'beta_0001.nii');

    resliceRoiImages(dataImage, fullfile('masks/fedorenko_parcels', roiFilename));

end
end


function resliceOnParticipant(roi, opt, subName)

    % copy image in sub roi folder
    roiParseName = strsplit(roi, 'fedorenko_parcels/');
    copyfile(roi, fullfile(opt.dir.rois, subName, [subName '_' roiParseName{2}]), 'f');
    
    % get new name
    copiedRoi = fullfile(opt.dir.rois, subName, [subName '_' roiParseName{2}]);

    % get reference
    dataImage = fullfile(opt.dir.stats, subName, ...
                         'task-visualLocalizer_space-IXI549Space_FWHM-6_node-localizerGLM', 'beta_0001.nii');

    % relisce roi based on the specific sub
    resliceRoiImages(dataImage, copiedRoi);

end


%% CHECK SIZE ustom new name - separate function?
% % Rename .json and .nii files of both masks to have more readable names
% % Remove file extension from name
% intersectedJustTheName = intersectedName(1:end-4);
% 
% % New names
% intersectedNewName = fullfile(opt.dir.rois, subName, [subName, '_hemi-' hemiName{iReg} ...
%                               '_space-MNI_atlas-neurosynth_method-expansionIntersection_label-' regName{iReg} '_mask']);
% 
% % Rename intersection
% movefile(intersectedName, [intersectedNewName,'.nii'],'f')
% movefile([intersectedJustTheName,'.json'], [intersectedNewName,'.json'],'f')
% 
% % reslice the masks
% intersectedMask = resliceRoiImages(dataImage, [intersectedNewName, '.nii']);


