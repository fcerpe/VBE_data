%% Split VWFAs according to different methods
%
% From expansions ROIs created through roi_createROIs.m, 
% split the individual VWFAs into anterior / posterior
% 
% Outputs:
% - 2 ROIs for each VWFA
%
% Methods:
% 1) Hans' way: divide (et impera) the mask according to the two poles
% 2) Lerma-Usabiaga's division: perceptual-VWFA and lexical-VWFA 
% 
%
% TO-DO (18/07/2023)
%   - take  ROIs (maybe mek this a function?)
%   - create spheres for vwfas
%   - overlap spheres and masks
%   - calculate overlap of voxels between subjects

%% Atlases coordinates

% Coordinates extracted by Jacek Matuszewski, a big help in this 
% - anterior and posterior VWFAs (aVWFA, pVWFA) coordinates from visf atlas
%   (Rosenke et al., 2020)
% - canonical VWFA (cVWFA) from Cohen et al
% - perceptual and lexical VWFAs (perVWFA, lexVWFA) coordinates from
%   Lerma-Usabiaga et al., 2018

vwfa.locations = {[-45 -51 -12], ... 
                  [-45 -57 -12],...
                  [-45 -72 -10],...
                  [-39 -71 -8],...
                  [-42 -58 -10]};

vwfa.names = {'aVWFA','cVWFA','pVWFA','lexVWFA','perVWFA'};

% TL;DR
% - take VWFA from each subject's folder 
% - overlap it with spheres created around perVWFA and lexVWFA
% - save the result
for iSub = 1:length(opt.subjects)

    % Get subject number
    subName = ['sub-', num2str(opt.subjects{iSub})];

    % Get the subject's VWFA mask
    % brain mask is ROI created with expansion around VWFA, see
    % roi_createROIs for more details 
    % TO-DO: alternatively, can also be created around localizer data 
    brainMask = fullfile(opt.dir.rois, subName, ...
                             ['r' subName '_hemi-L_space-MNI_atlas-neurosynth_method-expansionIntersection_label-VWFAfr_mask.nii']);

    % for each sub-VWFA coming from Lerma-Usabiaga 
    for iReg = 4:5

        % Get the center and the corresponding name
        ROI_center = vwfa.locations{iReg};
        regName = vwfa.names{iReg};

        % Set up bids-like name
        bidslikeName = [subName, '_hemi-L_space-MNI_atlas-none_method-LUCoordinates_label-' regName '_mask'];

        % Get reference image for reslicing
        betaReference = fullfile(opt.dir.stats, subName, 'task-wordsDecoding_space-IXI549Space_FWHM-2', 'beta_0001.nii');

        % specify the sphere characteristics for each of them
        sphereParams = struct;
        sphereParams.location = ROI_center;
        sphereParams.radius = 10;

        % % specify the object to pass: mask + sphere
        specification = struct('mask1', brainMask, ...
                               'mask2', sphereParams);

        % specify the path for each subject
        outputPath = fullfile(opt.dir.rois,subName);

        sphereMask = createRoi('intersection', specification, betaReference, outputPath, opt.saveROI);

        % Rename the intersection mask
        % highly convoluted
        % TO-DO, could be improved by:
        % - giving up on a personalized name (never)
        % - modifying createRoi to pick a cutomized name
        path = '../../outputs/derivatives/cpp_spm-rois/';
        nativeName = ['r' subName '_hemi-L_space-MNI_atlas-neurosynth_label-VWFAfrIntersection_method-expansionIntersection_mask'];
        movefile(fullfile(path, subName, [nativeName,'.nii']), fullfile(path, subName, [bidslikeName,'.nii']),'f')
        movefile([path, subName, '/', nativeName,'.json'], [path, subName, '/', bidslikeName,'.json'],'f')

        % reslice
        roiPath = fullfile(opt.dir.rois, subName, [bidslikeName, '.nii']);
        sphereMask = resliceRoiImages(betaReference,roiPath);

    end
end


%% Individual split

% Divide each participant's ROI into two halves along the Y axis: one more
% anterior and one more posterior
%
% TBD as of 18/07/2023

% Take the highest and lowest Y coordinates
% split the difference in two parts:
% - if even, assign top x coords to anterior and bottom x coords to posterior
% - if odd, leave middle one out

%% BONUS: calculate VWFA overlap between-subjects

% Take the ROIs for each subject and sum them
% Look at roi_resolveOverlaps to do that













