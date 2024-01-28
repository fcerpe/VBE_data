%% Overlap displacement contrasts and BA8 (FEF) 

clear;
clc;

% Get path and init bidspm
addpath '../lib/bidspm'
bidspm;

% Get options - common to all the scripts
opt = roi_option();

% Get the resliced masks in the folder (created by code above)
maskPath = dir('masks/broadmann/*.nii');

% Set an accepted nb of voxels 
nbVoxels = opt.numLanguageVoxels;

% Initialize report 
report = {'subject','area','voxels'};


%% TL;DR
% For each subject, 
% - reslice the mask to the MNI space, 
% - overlap it with displacement contrast, 
% - produce report on how many voxels are there

for iSub = 1:length(opt.subjects)
    
    % Get subject number
    subName = ['sub-', num2str(opt.subjects{iSub})];
    
    % Get a reference image for this sub
    dataImage = fullfile(opt.dir.stats, subName, ...
                         ['task-visualLocalizer_space-',opt.space{1},'_FWHM-6_node-eyeMovementsGLM'], 'beta_0001.nii');
    
    % Get the contrasts: [displacement > nothing] 
    subContrast = dir(fullfile(opt.dir.stats, subName, ['task-visualLocalizer_space-',opt.space{1},'_FWHM-6_node-eyeMovementsGLM'], ...
                   '*_desc-dispGtNothing_*_mask.nii'));
    
    thisContrast = fullfile(subContrast.folder, subContrast.name);
    
    
    % Get the mask to reslice and overlap to contrast
    thisROI = fullfile(maskPath.folder, maskPath.name);
    
    % Reslice on each sub, necessary for PPI.
    % Only one time, it's not necessary to do it for each contrast
    resliceOnParticipant(thisROI, opt, subName);
    
    % Get name and hemisphere
    hemi = 'B';
    reg = 'broadmann8';
    
    % Load the mask and cast it as uint8, 
    % otherwise it's not recognized as a binary mask
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
    
    % Only rename ROI if an ROI was indeed created in the previous line, 
    % otherwise try with the next one
    if ~isempty(froiName)
        % Rename .json and .nii files of both masks to have more readable names
        % Remove file extension from name
        froiJustName = froiName(1:end-4);
        % New names
        froiNewName = fullfile(opt.dir.rois, subName, [subName,'_hemi-B_space-',opt.space{1},'_atlas-broadmann_label-BA8_mask']);
        % Rename intersection
        movefile(froiName, [froiNewName,'.nii'],'f')
        movefile([froiJustName,'.json'], [froiNewName,'.json'],'f')
        % reslice the masks
        intersectedMask = resliceRoiImages(dataImage, [froiNewName, '.nii']);
    end
    
    % Add information to the report
    % - how many voxels are there in the new ROI?
    voxels = froiMask.roi.size;
    
    % Add subject, contrast, hemisphere, region, and details to report
    report = vertcat(report, {subName, reg, voxels});


end

% Save report
writecell(report,['reports/roi_reports_languageROIs_voxThres-' num2str(nbVoxels) '_' date '.txt']);


%% FUNCTION TO RESLICE ROI BASED ON PARTICIPANT'S SPACE 
function resliceOnParticipant(roi, opt, subName)

    % copy image in sub roi folder
    roiParseName = strsplit(roi, 'broadmann/');
    copyfile(roi, fullfile(opt.dir.rois, subName, [subName '_' roiParseName{2}]), 'f');
    
    % get new name
    copiedRoi = fullfile(opt.dir.rois, subName, [subName '_' roiParseName{2}]);

    % Open the mask, cast as binary, close it 
    recastROI = load_nii(copiedRoi);
    recastROI.img = cast(recastROI.img, 'uint8');
    save_nii(recastROI, copiedRoi);

    % get reference
    dataImage = fullfile(opt.dir.stats, subName, ...
                         ['task-visualLocalizer_space-',opt.space{1},'_FWHM-6_node-eyeMovementsGLM'], 'beta_0001.nii');

    % relisce roi based on the specific sub
    resliceRoiImages(dataImage, copiedRoi);

    % case resliced ROI as binary 
    reslicedRoi = fullfile(opt.dir.rois, subName, ['r' subName '_' roiParseName{2}]);
    % Open the mask, cast as binary, close it 
    recastROI = load_nii(reslicedRoi);
    recastROI.img = cast(recastROI.img, 'uint8');
    save_nii(recastROI, reslicedRoi);

end


