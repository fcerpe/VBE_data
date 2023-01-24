%% Solve overlapping ROIS
% TODO
% - improve distance
% - create small report: which ROIs had overlaps, how big, was it over the
%   peaks, where there ties, how many, how were they resolved

clear;

%% Preparations

% add cpp repo
addpath '/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/code/lib/bidspm'
bidspm;

% get options
opt = roi_option();

opt.peaks = struct;
opt.peaks(1).sub = '001';
opt.peaks(1).method = 'center';
opt.peaks(1).area = 'none';
opt.peaks(1).coords = [0,0,0];

iPeak = 1;

% N.B. We are checking only FR defiend VWFA. We will use that in the MVPA
% under the accumption that, if we find a similar activation pattern in an
% area not defined by the BR contrast, it's better
opt.overlapsToCheck = {'VWFAfr-lpFS', 'VWFAfr-lLO', 'lpFS-lLO', 'rpFS-rLO'};

opt.roiMethods = {'general_coords_10mm','individual_coords_10mm','individual_coords_8mm','anatomical_intersection_8mm','anatomical_intersection_10mm','individual_coords_50vx'};

for iSub = 1:numel(opt.subjects)
    % get current sub, used later
    thisSub = opt.subjects{iSub};

    % Tell the user
    fprintf(['ANALYZING SUB-' thisSub '\n\n\n']);

    for iMethod = 1:numel(opt.roiMethods)
        % get current method, used later
        thisMethod = opt.roiMethods{iMethod};

        % Tell the user
        fprintf(['ANALYZING METHOD: ' thisMethod '\n\n']);

        for iOverlap = 1:numel(opt.overlapsToCheck)
            % Load the relative ROIs
            % which ones
            thisOverlap = opt.overlapsToCheck{iOverlap};
            roisToLoad = split(thisOverlap,'-');

            % skip the right hemisphere (for now)
            if startsWith(thisMethod,'anatomical') && startsWith(thisOverlap,'rpFS') || ...
                    startsWith(roisToLoad{2},'lLO')
                continue;
            end

            % in which method
            method = split(thisMethod,'_');
            if thisMethod(1) == 'i' % individual
                methodType = 'IndividualCoords';

                if thisMethod(end) == 'x'
                    % Expansion method: voxels
                    methodVolume = '_voxels-';
                    vwfafr_str = [opt.dir.rois,'/sub-',thisSub,'/rsub-',thisSub,'_space-MNI_trial-IndividualCoords_label-VWFAfr_voxels-*.nii'];
                    VWFAfr = dir(vwfafr_str);
                    llo_str = [opt.dir.rois,'/sub-',thisSub,'/rsub-',thisSub,'_space-MNI_trial-IndividualCoords_label-lLO_voxels-*'];
                    lLO = dir(llo_str);
                    lpfs_str = [opt.dir.rois,'/sub-',thisSub,'/rsub-',thisSub,'_space-MNI_trial-IndividualCoords_label-lpFS_voxels-*.nii'];
                    lpFS = dir(lpfs_str);
                    rlo_str = [opt.dir.rois,'/sub-',thisSub,'/rsub-',thisSub,'_space-MNI_trial-IndividualCoords_label-rLO_voxels-*.nii'];
                    rLO = dir(rlo_str);
                    rpfs_str = [opt.dir.rois,'/sub-',thisSub,'/rsub-',thisSub,'_space-MNI_trial-IndividualCoords_label-rpFS_voxels-*.nii'];
                    rpFS = dir(rpfs_str);

                else
                    % Sphere method: radius
                    methodVolume = '_radius-';
                    methodSize = method{end};
                end

            elseif thisMethod(1) == 'g' % general
                methodType = 'NeurosynthCoords';
                methodVolume = '_radius-';
                methodSize = method{end};

            else % anatomically constrained
                methodType = 'AnatIntersection';
                methodVolume = '_radius-';
                methodSize = method{end};
            end

            % sub name
            subBidsName = ['sub-', thisSub];

            % compose the names of the ROIs to load
            if iMethod <= 5
                roi1_name = ['r', subBidsName, '_space-MNI_trial-', methodType, '_label-', roisToLoad{1}, ...
                             methodVolume, methodSize, '_mask.nii'];
                roi2_name = ['r', subBidsName, '_space-MNI_trial-', methodType, '_label-', roisToLoad{2}, ...
                             methodVolume, methodSize, '_mask.nii'];
            else 
                % expansion and voxels hange from one ROI to another, a
                % personal name is needed
                eval(['roi1_name = ' roisToLoad{1} '.name;']); 
                eval(['roi2_name = ' roisToLoad{2} '.name;']); 
            end

            % load ROIs
            roi1 = load_nii(fullfile(opt.dir.rois, subBidsName, roi1_name));
            roi2 = load_nii(fullfile(opt.dir.rois, subBidsName, roi2_name));

            % load relative contrasts in case of equal distance from peaks.
            % Works only for different contrasts (VWFA v. lLO or lpFS)
            % based on the sub (contrasts nb differ, response issues)
            if startsWith(roisToLoad{1},'V')
                switch thisSub
                    case {'006', '009'}
                        conWords = load_nii(fullfile(opt.dir.stats, subBidsName, ...
                            'task-visualLocalizer_space-IXI549Space_FWHM-6', 'con_0032.nii'));
                        conDraw = load_nii(fullfile(opt.dir.stats, subBidsName, ...
                            'task-visualLocalizer_space-IXI549Space_FWHM-6', 'con_0034.nii'));

                    case {'007', '008'}
                        conWords = load_nii(fullfile(opt.dir.stats, subBidsName, ...
                            'task-visualLocalizer_space-IXI549Space_FWHM-6', 'con_0029.nii'));
                        conDraw = load_nii(fullfile(opt.dir.stats, subBidsName, ...
                            'task-visualLocalizer_space-IXI549Space_FWHM-6', 'con_0031.nii'));
                end
            end

            %% Preliminary calculations

%             % cheap hack 
%             roi1 = load_nii('/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/outputs/derivatives/cpp_spm-rois/sub-009/rsub-009_space-MNI_trial-IndividualCoords_label-VWFAfr_radius-10mm_mask.nii');
%             roi2 = load_nii('/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/outputs/derivatives/cpp_spm-rois/sub-009/rsub-009_space-MNI_trial-AnatIntersection_label-lpFS_radius-10mm_mask.nii');
%             thisSub = '009';    roisToLoad{1} = 'VWFAfr';   roisToLoad{2} = 'lpFS';
%             thisMethod = 'individual_coords_10mm';
%             conWords = load_nii(fullfile(opt.dir.stats, subBidsName,'task-visualLocalizer_space-IXI549Space_FWHM-6', 'con_0032.nii'));
%             conDraw = load_nii(fullfile(opt.dir.stats, subBidsName,'task-visualLocalizer_space-IXI549Space_FWHM-6', 'con_0034.nii'));
%             opt.peaks = savedPeaks;     iPeak = length(savedPeaks);     subBidsName = 'sub-009';
%             methodType = 'IndividualCoords';    methodVolume = '10mm';  iMethod = 2;
%             thisOverlap = [roisToLoad{1} '-' roisToLoad{2}];
%             roi1_name = ['r',subBidsName,'_space-MNI_trial-',methodType,'_label-',roisToLoad{1},methodVolume,'_mask.nii'];
%             roi2_name = ['r',subBidsName,'_space-MNI_trial-',methodType,'_label-',roisToLoad{2},methodVolume,'_mask.nii'];

            % get areas and peaks positions for both ROIs
            roi1_area = find(roi1.img > 0);
            roi2_area = find(roi2.img > 0);

            fprintf([thisOverlap, '\n']);

            % first three methods use spheres, we can extract centers from
            % them (potentially one individual is fine)
            if ismember(iMethod,[1 2 3])

                % if already exists, fetch it. Otherwise, find it and save it
                roi1presence = find(startsWith({opt.peaks(:).sub}, thisSub) & ...
                                    startsWith({opt.peaks(:).method}, thisMethod) & ...
                                    startsWith({opt.peaks(:).area}, roisToLoad{1}));

                if isempty(roi1presence) % not present yet
                    
                    peak1 = roi1_area(round(length(roi1_area)/2));
                    [peak1(1,1), peak1(1,2), peak1(1,3)] = ind2sub([61,73,61],peak1);

                    % save it
                    opt.peaks(iPeak).sub = thisSub;
                    opt.peaks(iPeak).method = thisMethod;
                    opt.peaks(iPeak).area = roisToLoad{1};
                    opt.peaks(iPeak).coords = peak1;

                    iPeak = iPeak + 1;
                    
                else  
                    peak1Pos = find(startsWith({opt.peaks(:).sub}, thisSub) & ...
                                    startsWith({opt.peaks(:).method}, thisMethod) & ...
                                    startsWith({opt.peaks(:).area}, roisToLoad{1}));
                    peak1 = opt.peaks(peak1Pos).coords;

                end

                % same for second ROI
                roi2presence = find(startsWith({opt.peaks(:).sub}, thisSub) & ...
                                    startsWith({opt.peaks(:).method}, thisMethod) & ...
                                    startsWith({opt.peaks(:).area}, roisToLoad{2}));

                if isempty(roi2presence)        % peak is not present yet
                    peak2 = roi2_area(round(length(roi2_area)/2));
                    [peak2(1,1), peak2(1,2), peak2(1,3)] = ind2sub([61,73,61],peak2);

                    % save it
                    opt.peaks(iPeak).sub = thisSub;
                    opt.peaks(iPeak).method = thisMethod;
                    opt.peaks(iPeak).area = roisToLoad{2};
                    opt.peaks(iPeak).coords = peak2;

                    iPeak = iPeak + 1;
                    
                else % already present  
                    peak2Pos = find(startsWith({opt.peaks(:).sub}, thisSub) & ...
                                    startsWith({opt.peaks(:).method}, thisMethod) & ...
                                    startsWith({opt.peaks(:).area}, roisToLoad{2}));
                    peak2 = opt.peaks(peak2Pos).coords;

                end
            else % antomical_intersection and expasnion: take centers from individual coords

                % take the peaks from the corresponding areas of
                % individual_coords_8mm
                peak1Pos = find(startsWith({opt.peaks(:).sub}, thisSub) & ...
                                startsWith({opt.peaks(:).method}, 'individual_coords_8mm') & ...
                                startsWith({opt.peaks(:).area}, roisToLoad{1}));
                peak1 = opt.peaks(peak1Pos).coords;
                peak2Pos = find(startsWith({opt.peaks(:).sub}, thisSub) & ...
                                startsWith({opt.peaks(:).method}, 'individual_coords_8mm') & ...
                                startsWith({opt.peaks(:).area}, roisToLoad{2}));
                peak2 = opt.peaks(peak2Pos).coords;
                
            end

            % sum the masks: 0 is neither, 1 is either, 2 is both (overlap)
            overlap_mask = roi1.img + roi2.img;

            % take the indexes of the overlapping cells (voxels)
            overlap = find(overlap_mask == 2);
            [overlap(:,1), overlap(:,2), overlap(:,3)] = ind2sub([61,73,61],overlap);

            if not(isempty(overlap))
                % Tell the user
                fprintf(['Overlap between '  roisToLoad{1} ' and ' roisToLoad{2} ': ' num2str(size(overlap,1)) ' voxels\n']);

                % Assign voxels to either ROI
                % go through all the overlap voxels, look at which peak is
                % closest and assign the voxel to that ROI
                % (cancel it from the other ROI)

                % Look for least difference in coordinates.
                % If they are at the same distance, look at univariate activation for the
                % condition that produces the highest activation

                % nbIstances indicates how many ties there are, for reference
                nbIstances = 0;

                for ov = 1:size(overlap,1)
                    currVoxelCoords = overlap(ov,:);

                    % distance from the peaks
                    distanceFrom1 = abs(currVoxelCoords - peak1);
                    distanceFrom1 = sum(distanceFrom1);

                    distanceFrom2 = abs(currVoxelCoords - peak2);
                    distanceFrom2 = sum(distanceFrom2);

                    if distanceFrom1 < distanceFrom2
                        roi2.img(currVoxelCoords(1),currVoxelCoords(2),currVoxelCoords(3)) = 0;

                    elseif distanceFrom1 > distanceFrom2
                        roi1.img(currVoxelCoords(1),currVoxelCoords(2),currVoxelCoords(3)) = 0;

                    else
                        nbIstances = nbIstances +1;

                        % We can compare activations between two different
                        % contrasts, to see which is higher. But only in
                        % the case of VWFA and LOC, not within LOC (same
                        % contrast)
                        if startsWith(roisToLoad{1},'V')
                            % decide based on univariate response (to contrast, not to single
                            % stimuli)
                            if conWords.img(currVoxelCoords(1),currVoxelCoords(2),currVoxelCoords(3)) >  ...
                                    conDraw.img(currVoxelCoords(1),currVoxelCoords(2),currVoxelCoords(3))
                                roi2.img(currVoxelCoords(1),currVoxelCoords(2),currVoxelCoords(3)) = 0;

                            else
                                roi1.img(currVoxelCoords(1),currVoxelCoords(2),currVoxelCoords(3)) = 0;
                            end
                        else % pFS v. LO
                            % Arbitrary: give the voxels to LO, should be
                            % bigger than pFS. pFS is first ROI in both
                            % cases
                            roi1.img(currVoxelCoords(1),currVoxelCoords(2),currVoxelCoords(3)) = 0;
                        end
                    end
                end

                % Tell the user
                fprintf(['Re-assigned ' num2str(size(overlap,1)) ' voxels, of which ' num2str(nbIstances) ' based on activation\n']);

                % Control afterwards

                % sum the masks: 0 is neither, 1 is either, 2 is both (overlap)
                overlap_mask = roi1.img + roi2.img;
                roi1_area = find(roi1.img > 0);
                roi2_area = find(roi2.img > 0);

                % take the indexes of the overlapping cells (voxels)
                overlap = find(overlap_mask == 2);
                [overlap(:,1), overlap(:,2), overlap(:,3)] = ind2sub([61,73,61],overlap);

                % Tell the user
                fprintf(['There are now ' num2str(size(overlap,1)) ' overlapping voxels between ' ...
                    roisToLoad{1} ' and ' roisToLoad{2} '\n\n']);

                % Save the new ROIs (overwrites previous ones)
                
                % delete previous ones (necessary for voxel expansions)
%                 delete(fullfile(opt.dir.rois,subBidsName,roi1_name));
%                 delete(fullfile(opt.dir.rois,subBidsName,roi2_name));

                % save new ROIs
                if iMethod == 6
                    % re-name the ROI with the updated nb of voxels 
                    roi1_name = ['r', subBidsName, '_space-MNI_trial-', methodType, '_label-', roisToLoad{1}, ...
                                 methodVolume, num2str(size(roi1_area,1)), 'vx_mask.nii'];
                    roi2_name = ['r', subBidsName, '_space-MNI_trial-', methodType, '_label-', roisToLoad{2}, ...
                                 methodVolume, num2str(size(roi2_area,1)), 'vx_mask.nii'];
                end

%                 % cheap hack
%                 roi1_name = ['new_', roi1_name];
%                 roi2_name = ['new_', roi2_name];

                save_nii(roi1,fullfile(opt.dir.rois, subBidsName, roi1_name));
                save_nii(roi2,fullfile(opt.dir.rois, subBidsName, roi2_name));

            else
                % Tell the user
                fprintf(['No overlap between '  roisToLoad{1} ' and ' roisToLoad{2} '\n\n']);

            end

        end
    end
end




