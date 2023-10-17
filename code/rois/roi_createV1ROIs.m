
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
visfatlasV1Masks = dir('masks/*V1*');

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

end


