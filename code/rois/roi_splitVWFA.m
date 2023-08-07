%% Split VWFAs according to different methods
%
% From expansions ROIs created through roi_createROIs.m, 
% split the individual VWFAs into anterior / posterior
% 
% Outputs:
% - 2 ROIs for each VWFA
%
% Methods:
% 1) Lerma-Usabiaga's division: perceptual-VWFA and lexical-VWFA 
% 2) Hans' way: divide (et impera) the mask according to the two poles
% BONUS: overlap between VWFAs
%
%
% TO-DO (07/08/2023)
%   - Solve: most areas have empty ROIs, i.e. there are no voxels in tha atlas vwfa
%   - Adjust documentation mentioning multiple objects can be passed at
%   once, that atlas does not work
%   - add aVWFA and pVWFA in atlas

for sp = 1:numel(opt.split)
   
    switch opt.split{sp}
    
        case 'atlas'
            % Atlases coordinates
            %
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
    
                    % 02/08/2023
                    % Most subjects are lacking at least one of the L-U coordinates.
                    % Try to catch the exception (emptiness) befor it throws an error
                    % and log the error
    
                    % Pre-check that intersection exists
                    % (i.e. there are voxels in the subject's VWFA that fall into the atlas / paper coordinates)
                    % In case it's empty, throw a warning and skip it
    
    
    
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
    
    
        case 'individual'
            % Individual split
            %
            % Divide each participant's ROI into two halves along the Y axis: one more
            % anterior and one more posterior
            %
            % TL;DR
            % - open the VWFA mask of each subject
            % - get the Y coordinates: the most anterior and most posterior
            % - divide the mask in two halves nad save them as masks
    
            for iSub = 1:length(opt.subjects)
    
                % Get subject number
                subName = ['sub-', num2str(opt.subjects{iSub})];
    
                fprintf(['Splitting individual ROIs of ' subName '\n']);
    
                % Get the subject's VWFA mask
                brainMask = fullfile(opt.dir.rois, subName, ...
                    ['r' subName '_hemi-L_space-MNI_atlas-neurosynth_method-expansionIntersection_label-VWFAfr_mask.nii']);
    
    
                % Load the mask
                vwfaMask = loadROI(brainMask);
    
                % get the highest and lowest Y (hY and lY)
                highestCoordsMm = max(vwfaMask.XYZmm, [], 2);
                hYmm = highestCoordsMm(2);
                hY =max(vwfaMask.XYZ(2,:));
    
                lowestCoordsMm = min(vwfaMask.XYZmm, [], 2);
                lYmm = lowestCoordsMm(2);
                lY = min(vwfaMask.XYZ(2,:));
    
                % get the mid-point: mY = hY - lY
                % if half is odd (e.g. 11 voxels long), skip them for now
                if mod(hY-lY,2) == 0 % if even
                    mY = floor((hY-lY-1)/2); % remove 1, i.e. do not assign middle Y value to any ROI
                else
                    mY = floor((hY-lY)/2);
                end
    
    
                % create masks:
                %
                % - anterior vwfa, mY to hY
                vwfaAnt = vwfaMask;
    
                % Get the Y coordinates that have values lower than our mid point, to
                % be deleted from the anterior mask, and save the coords
                invalidY = find(vwfaAnt.XYZ(2,:) < hY-mY);
    
                % Get the coordinates and the matrix indices for every invalid value
                invalidCoords = vwfaAnt.XYZ(:,invalidY);
                invalidPoints = sub2ind(size(vwfaAnt.img), invalidCoords(1,:), invalidCoords(2,:), invalidCoords(3,:));
    
                % Remove all the values form XYZ coords, XYZmm and img
                vwfaAnt.XYZ(:,invalidY) = [];
                vwfaAnt.XYZmm(:,invalidY) = [];
                vwfaAnt.img(invalidPoints) = 0;
    
                % - posterior vwfa, lY to mY
                vwfaPos = vwfaMask;
    
                % Get the Y coordinates that have values lower than our mid point, to
                % be deleted from the anterior mask, and save the coords
                invalidY = find(vwfaPos.XYZ(2,:) > lY+mY);
    
                % Get the coordinates and the matrix indices for every invalid value
                invalidCoords = vwfaPos.XYZ(:,invalidY);
                invalidPoints = sub2ind(size(vwfaPos.img), invalidCoords(1,:), invalidCoords(2,:), invalidCoords(3,:));
    
                % Remove all the values form XYZ coords, XYZmm and img
                vwfaPos.XYZ(:,invalidY) = [];
                vwfaPos.XYZmm(:,invalidY) = [];
                vwfaPos.img(invalidPoints) = 0;
    
    
                % save new masks in a bidlike name
                antName = ['r' subName '_hemi-L_space-MNI_atlas-neurosynth_method-splitting_label-antVWFA_mask.nii'];
                vwfaAnterior = saveSplitROI(vwfaAnt, brainMask, fullfile(opt.dir.rois, subName), antName);
    
                posName = ['r' subName '_hemi-L_space-MNI_atlas-neurosynth_method-splitting_label-posVWFA_mask.nii'];
                vwfaPosterior = saveSplitROI(vwfaPos, brainMask, fullfile(opt.dir.rois, subName), posName);
    
                fprintf('Done \n\n');
    
    
            end
    
    
        case 'overlap'
            % BONUS: calculate VWFA overlap between-subjects
            %
            % Take the ROIs for each subject and sum them
            % Display the overlap as % of shared space
    
            % Create a struct to store all the rois. Left empty for now and initalized
            % while loading the first roi
            vwfas = [];
    
            for iSub = 1:length(opt.subjects)
    
                % Get subject number
                subName = ['sub-', num2str(opt.subjects{iSub})];
    
                fprintf(['Adding vwfa for ' subName '\n']);
    
                % Get the subject's VWFA mask
                brainMask = fullfile(opt.dir.rois, subName, ...
                    ['r' subName '_hemi-L_space-MNI_atlas-neurosynth_method-expansionIntersection_label-VWFAfr_mask.nii']);
    
                % Load the mask
                % USe load_nii instead of our custom function because we deal with
                % multiple subjects at the same time. A more simple measure appears to
                % be more solid
                vwfaMask = load_nii(brainMask);
    
                % In case it's the first mask, use it as base to summ all the others
                % Otherwise, add this .img to the previous masks
                if isempty(vwfas)
                    vwfas = struct;
                    allImg = vwfaMask.img;
                    totalMasks = 1;
                else
                    allImg = allImg + vwfaMask.img;
                    totalMasks = totalMasks + 1;
                end
    
                % Add it to the others, for storage
                eval(['vwfas.sub' num2str(opt.subjects{iSub}) ' = vwfaMask;']);
    
            end
    
            % Create a custom mask with the overlap
            vwfaMaskName = fullfile(opt.dir.rois, 'overlap_hemi-L_space-MNI_label-VWFAfr.nii');
            vwfaMask.img = allImg;
    
            save_nii(vwfaMask, vwfaMaskName);
    
    end
end


%% CUSTOM SAVE FUNCTION FOR SPLITTING OF VWFA

function outputFile = saveSplitROI(mask, volumeDefiningImage, outputDir, roiName)

  hdr = spm_vol(volumeDefiningImage);
  if numel(hdr) > 1
    err.identifier =  'createRoi:not3DImage';
    err.message = sprintf(['the volumeDefininigImage:', '\n\t%s\n', ...
                           'must be a 3D image. It seems to be 4D image with %i volume.'], image, numel(hdr));
    error(err);
  end

  % use the marsbar toolbox
  roiObject = maroi_pointlist(struct('XYZ', mask.XYZmm, ...
                                     'mat', spm_get_space(volumeDefiningImage)));

  % use Marsbar to save as a .mat and then convert that to an image
  % in the correct space
  outputFile = fullfile(outputDir, roiName);
  save_as_image(roiObject, outputFile);

end

%% CUSTOM LOADING OF ROI

function outputStruct = loadROI(mask)

    % This part of the code has been adapted from CPP_ROI
    % (https://github.com/cpp-lln-lab/CPP_ROI)
    % Credits go to the developers

    outputStruct = struct;
    outputStruct.hdr = spm_vol(mask);
    outputStruct.img = logical(spm_read_vols(outputStruct.hdr));
    [X, Y, Z] = ind2sub(size(outputStruct.img), find(outputStruct.img));

    % XYZ format
    outputStruct.XYZ = [X'; Y'; Z'];
    outputStruct.size = size(outputStruct.XYZ, 2);
    
    % Convert XYZ format in mm
    outputStruct.XYZmm = outputStruct.hdr.mat(1:3, :) * [outputStruct.XYZ; ones(1, size(outputStruct.XYZ, 2))];

end

