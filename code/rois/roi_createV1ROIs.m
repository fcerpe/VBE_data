
%% Create ROIs based on peak coordinates from subjects' localizers
%
% From visfatlas and extracted V1 mask.
% Extract ROIs for eacch participant and subject, reslice them, and apply them to individual data
%
% Outputs:
% - ROIs (duh) in the 'code/rois/masks'
% - image reference to reslice the original mask on the single subject's
%   space
%
% TO-DO (09/10/2023)
% - ?

% find V1 masks. There are many as visfatlas divides both hemisphere and
% dorsal/ventral
% Atlas may change:
% - visfatlas
% - JUBrain (anatomy toolbox)
atlas = 'JUBrain';
visfatlasV1Masks = dir(['masks/*atlas-' atlas '*V1*']);

% extract the first one
% Correpsonds to the fusion of all the subareas, created in roi_createROIs 
v1mask = fullfile(visfatlasV1Masks(1).folder, visfatlasV1Masks(1).name);

% Iterate through subjects to reslice the original mask on each subjecct's
% space and save it as a personal ROI
for iSub = 1:numel(opt.subjects)

    % Get subject number
    subName = ['sub-', num2str(opt.subjects{iSub})];

    % Get a reference image for this sub
    dataImage = fullfile(opt.dir.stats, subName, ...
                         'task-visualLocalizer_space-IXI549Space_FWHM-6_node-localizerGLM', 'beta_0001.nii');

    % Reslice on each sub

    % Before reslicing, copy image in sub roi folder
    % Get name and use it to compose new path
    newMaskPath = fullfile(opt.dir.rois, subName, [subName '_' visfatlasV1Masks(1).name]);
    copyfile(v1mask, newMaskPath, 'f');

    % Open the mask, cast as binary, close it 
    recastROI = load_nii(newMaskPath);
    recastROI.img = cast(recastROI.img, 'uint8');
    save_nii(recastROI, newMaskPath);

    % relisce roi based on the specific sub
    resliceRoiImages(dataImage, newMaskPath);

    % case resliced ROI as binary 
    reslicedRoi = fullfile(opt.dir.rois, subName, ['r' subName '_' visfatlasV1Masks(1).name]);
    % Open the mask, cast as binary, close it 
    recastROI = load_nii(reslicedRoi);
    recastROI.img = cast(recastROI.img, 'uint8');
    save_nii(recastROI, reslicedRoi);

    % Get the contrasts: [FW + SFW > nothing] 
    subCon = dir(fullfile(opt.dir.stats, subName, 'task-visualLocalizer_space-IXI549Space_FWHM-6_node-localizerGLM', ...
                   'sub-*_desc-allF*pt05*_mask.nii'));

    % Join them to make looping easier
    thisContrast = fullfile(subCon.folder, subCon.name);
    
    % Get the type of stimuli of the contrast, to be specified later in
    % the new ROI name
    conName = strsplit(thisContrast,{'desc-','Gt'});
    con = conName{2};

    % Get name and hemisphere
    strName = strsplit(v1mask, {'_','-'});
    hemi = strName{3};
    reg = strName{9};

    % Load the mask and cast it as uint8, otherwise it's not
    % recognized as a binary mask
    recastROI = load_nii(v1mask);
    recastROI.img = cast(recastROI.img, 'uint8');
    save_nii(recastROI, v1mask);

    % specify the objects to pass: mask + mask
    specMasks = struct('mask1', reslicedRoi, ...
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
            '_space-MNI_atlas-JUBrain_contrast-' con '_label-' reg '_mask']);
        % Rename intersection
        movefile(froiName, [froiNewName,'.nii'],'f')
        movefile([froiJustName,'.json'], [froiNewName,'.json'],'f')
        % reslice the masks
        intersectedMask = resliceRoiImages(dataImage, [froiNewName, '.nii']);
    end

end



