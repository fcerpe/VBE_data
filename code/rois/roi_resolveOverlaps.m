%% Solve overlapping ROIS
% TODO
% - improve distance
% - create small report: which ROIs had overlaps, how big, was it over the
%   peaks, where there ties, how many, how were they resolved

clear;
clc;

%% Preparations

% add cpp repo
addpath '/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/code/lib/bidspm'
bidspm;

% get options
opt = roi_option();

opt.peaks = struct('sub','001','method','center','area','none','coords',[0,0,0]);

iPeak = 1;

% N.B. We are checking only FR defiend VWFA. We will use that in the MVPA
% under the accumption that, if we find a similar activation pattern in an
% area not defined by the BR contrast, it's better
opt.overlapsToCheck = {'VWFAfr-lLO'};

for iSub = 1:numel(opt.subjects)

    subName = ['sub-', opt.subjects{iSub}];

    % Keep the user updated
    fprintf(['Analysing ' subName '\n']);

    % ROIs to load
    roi1name = ['r',subName,'_hemi-L_space-MNI_atlas-neurosynth_method-expansionIntersection_label-VWFAfr_mask.nii'];
    roi2name = ['r',subName,'_hemi-L_space-MNI_atlas-neurosynth_method-expansionIntersection_label-lLO_mask.nii'];

    % load ROIs
    roi1 = load_nii(fullfile(opt.dir.rois, subName, roi1name));
    roi2 = load_nii(fullfile(opt.dir.rois, subName, roi2name));

    % load relative contrasts in case of equal distance from peaks.
    % Works only for different contrasts (VWFA v. lLO or lpFS)
    % based on the sub (contrasts nb differ, response issues)
    spmT_words = dir(fullfile(opt.dir.stats, subName, 'task-visualLocalizer_space-IXI549Space_FWHM-6', ...
                [subName, '_*_desc-frenchGtScrambled_*_p-0pt001_*_mask.nii']));
    spmT_objects = dir(fullfile(opt.dir.stats, subName, 'task-visualLocalizer_space-IXI549Space_FWHM-6', ...
                [subName, '_*_desc-drawingGtScrambled_*_p-0pt001_*_mask.nii']));

    contrastWords = fullfile(spmT_words.folder, spmT_words.name);
    contrastObjects = fullfile(spmT_objects.folder, spmT_objects.name);

    %% Preliminary calculations

    % call roi_getMNIcoords to know the peaks of each subject and area
    mni = roi_getMNIcoords(opt.subjects);

    % sum the masks: 0 is neither, 1 is either, 2 is both (overlap)
    overlapMask = roi1.img + roi2.img;
    
    % VWFA peak - always first coords
    peakWords = mni{iSub}(1,:);

    % lLO peak - always third coords
    peakObjects = mni{iSub}(3,:);

    % get areas and peaks positions for both ROIs
    roi1area = find(roi1.img > 0);
    roi2area = find(roi2.img > 0);

    % take the indexes of the overlapping cells (voxels)
    overlap = find(overlapMask == 2);
    [overlap(:,1), overlap(:,2), overlap(:,3)] = ind2sub([61,73,61],overlap);

    if not(isempty(overlap))
        % Tell the user
        fprintf(['Overlap between VWFA and lLO: ' num2str(size(overlap,1)) ' voxels\n']);

        % Assign voxels to either ROI
        % go through all the overlap voxels, look at which peak is closest 
        % and assign the voxel to that ROI (cancel it from the other ROI)
        % If they are at the same distance, look at univariate activation 
        % and assign the voxel to the highest bidder

        % nbIstances indicates how many ties there are, for reference
        nbIstances = 0;

        for ov = 1:size(overlap,1)
            currVoxelCoords = overlap(ov,:);

            % distance from the peaks
            distanceFromWords = abs(currVoxelCoords - peakWords);
            distanceFromWords = sum(distanceFromWords);

            distanceFromObjects = abs(currVoxelCoords - peakObjects);
            distanceFromObjects = sum(distanceFromObjects);

            if distanceFromWords < distanceFromObjects
                roi2.img(currVoxelCoords(1),currVoxelCoords(2),currVoxelCoords(3)) = 0;

            elseif distanceFromWords > distanceFromObjects
                roi1.img(currVoxelCoords(1),currVoxelCoords(2),currVoxelCoords(3)) = 0;

            else
                nbIstances = nbIstances +1;

                % We can compare activations between two different contrasts
                % decide based on univariate response 

                % If in that voxel, activation for words is higher than
                % activation for objects
                if contrastWords.img(currVoxelCoords(1), currVoxelCoords(2), currVoxelCoords(3)) >  ...
                        contrastObjects.img(currVoxelCoords(1), currVoxelCoords(2), currVoxelCoords(3))

                    roi2.img(currVoxelCoords(1),currVoxelCoords(2),currVoxelCoords(3)) = 0;

                else
                    roi1.img(currVoxelCoords(1),currVoxelCoords(2),currVoxelCoords(3)) = 0;
                end
            end
        end

        % Tell the user
        fprintf(['Re-assigned ' num2str(size(overlap,1)) ' voxels, of which ' num2str(nbIstances) ' based on activation\n']);

        % Control afterwards

        % sum the masks: 0 is neither, 1 is either, 2 is both (overlap)
        overlapMask = roi1.img + roi2.img;
        roi1area = find(roi1.img > 0);
        roi2area = find(roi2.img > 0);

        % take the indexes of the overlapping cells (voxels)
        overlap = find(overlapMask == 2);
        [overlap(:,1), overlap(:,2), overlap(:,3)] = ind2sub([61,73,61],overlap);

        % Tell the user
        fprintf(['There are now ' num2str(size(overlap,1)) ' overlapping voxels between VWFA and lLO\n\n\n']);

        % Save the new ROIs (overwrites previous ones)

        % delete previous ones (necessary for voxel expansions)
        %                 delete(fullfile(opt.dir.rois,subBidsName,roi1_name));
        %                 delete(fullfile(opt.dir.rois,subBidsName,roi2_name));

        % save new ROIs
        save_nii(roi1,fullfile(opt.dir.rois, subName, roi1name));
        save_nii(roi2,fullfile(opt.dir.rois, subName, roi2name));

    else
        % Tell the user
        fprintf('No overlap between VWFA and lLO\n\n\n');

    end

end




