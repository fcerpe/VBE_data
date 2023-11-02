function [opt] = mvpa_chooseMask(opt)

opt.maskName = [];

for iSub = 1:numel(opt.subjects)

    subID = opt.subjects{iSub};

    % default one is expansion then intersected with neurosynth
    if isempty(opt.roiMethod)
        opt.roiMethod = 'expansionIntersection';
    end

    % based on the type of analysis we are interested in, pick the ROIs
    % expansionIntersection: basic way. Takes only VWFA, lLO, rLO
    % fedorenko: VWFA + AntTemp, PosTemp, AngG, IFG, IFGorb, MFG. All both
    %            Left and Right
    % vwfaSplit: takes the splitted VWFAs based on the raw chopping of the
    %            ROI in half
    % vwfaSplitAtlas: uses VWFA splitted according to atlas (undefined)
    switch opt.roiMethod
        case 'expansionIntersection' 

            % get the actual filename (may change is numVoxels is specified in the name)
            atlas_filename = [opt.dir.rois, '/sub-',num2str(subID),...
                              '/rsub-',num2str(subID),'_hemi-*_space-MNI_atlas-neurosynth_method-expansionIntersection*.nii'];
            atlas_files = dir(atlas_filename);
            opt.maskName = horzcat(opt.maskName, {atlas_files.name});
            
            opt.maskLabel = {'VWFAfr', 'lLO', 'rLO'};


        case 'fedorenko'
            atlas_filename = [opt.dir.rois, '/sub-',num2str(subID),...
                              '/rsub-',num2str(subID),'_hemi-*_space-MNI_atlas-fedorenko_contrast-french*.nii'];
            atlas_files = dir(atlas_filename);
            
            % Check that, among all the fedorenko masks,
            % we only add those relevant for the analyses
            opt.maskLabel = {'lPosTemp'};
            okArea = [];
    
            % get hemispheres and masks allowed
            for ml = 1:numel(opt.maskLabel)
                okArea = horzcat(okArea, {upper(opt.maskLabel{ml}(1)), opt.maskLabel{ml}(2:end)});
            end

            for af = 1:numel(atlas_files)
                parseFile = strsplit(atlas_files(af).name, {'hemi-','_space','label-','_mask'});
                parseHemi = parseFile{2};
                parseArea = parseFile{4};

                okIdx = 1;
                notMatched = true;
                while notMatched && okIdx <= size(okArea,1)
                    if strcmp(parseHemi, okArea{okIdx,1}) && strcmp(parseArea, okArea{okIdx,2})
                        opt.maskName = horzcat(opt.maskName, {atlas_files(af).name});
                        notMatched = false;
                    else
                        okIdx = okIdx +1;
                    end
                end
            end
            

        case 'vwfaSplit'
            atlas_filename = [opt.dir.rois, '/sub-',num2str(subID),...
                              '/rsub-',num2str(subID),'_hemi-*_space-MNI_atlas-neurosynth_method-splitting*.nii'];
            atlas_files = dir(atlas_filename);
            opt.maskName = horzcat(opt.maskName, {atlas_files.name});

            opt.maskLabel = {'antVWFA', 'posVWFA'};


        case 'earlyVisual'
            atlas_filename = [opt.dir.rois, '/sub-',num2str(subID),...
                              '/rsub-',num2str(subID),'_hemi-*_space-MNI_atlas-JUBrain_contrast-allFrench_label-V1*.nii'];
            atlas_files = dir(atlas_filename);
            opt.maskName = horzcat(opt.maskName, {atlas_files.name});

            opt.maskLabel = {'v1'};   

        % Old methods 
%         case 'general_coords_10mm'
%             opt.maskName = horzcat(opt.maskName, ...
%                 { ...
%                 strcat('rsub-', num2str(subID), '_space-MNI_trial-NeurosynthCoords_label-VWFAfr_radius-10mm_mask.nii'), ...
%                 strcat('rsub-', num2str(subID), '_space-MNI_trial-NeurosynthCoords_label-lLO_radius-10mm_mask.nii'), ...
%                 strcat('rsub-', num2str(subID), '_space-MNI_trial-NeurosynthCoords_label-rLO_radius-10mm_mask.nii'), ...
%                 });
% 
%         case 'individual_coords_marsbar'
%             opt.maskName = horzcat(opt.maskName, ...
%                 { ...
%                 strcat('rsub-', num2str(subID), '_space-MNI_label-VWFAfr_radius-10mm_mask.nii'), ...
%                 strcat('rsub-', num2str(subID), '_space-MNI_label-lLO_radius-10mm_mask.nii'), ...
%                 strcat('rsub-', num2str(subID), '_space-MNI_label-rLO_radius-10mm_mask.nii'), ...
%                 });
% 
%         case 'individual_coords_10mm'
%             opt.maskName = horzcat(opt.maskName, ...
%                 { ...
%                 strcat('rsub-', num2str(subID), '_space-MNI_trial-IndividualCoords_label-VWFAfr_radius-10mm_mask.nii'), ...
%                 strcat('rsub-', num2str(subID), '_space-MNI_trial-IndividualCoords_label-lLO_radius-10mm_mask.nii'), ...
%                 strcat('rsub-', num2str(subID), '_space-MNI_trial-IndividualCoords_label-rLO_radius-10mm_mask.nii'), ...
%                 });
% 
%         case 'individual_coords_8mm'
%             opt.maskName = horzcat(opt.maskName, ...
%                 { ...
%                 strcat('rsub-', num2str(subID), '_space-MNI_trial-IndividualCoords_label-VWFAfr_radius-8mm_mask.nii'), ...
%                 strcat('rsub-', num2str(subID), '_space-MNI_trial-IndividualCoords_label-lLO_radius-8mm_mask.nii'), ...
%                 strcat('rsub-', num2str(subID), '_space-MNI_trial-IndividualCoords_label-rLO_radius-8mm_mask.nii'), ...
%                 });
% 
%         case 'anatomical_intersection_8mm'
%                 opt.maskName = horzcat(opt.maskName, ...
%                 { ...
%                 strcat('rsub-', num2str(subID), '_space-MNI_trial-AnatIntersection_label-VWFAfr_radius-8mm_mask.nii'), ...
%                 strcat('rsub-', num2str(subID), '_space-MNI_trial-AnatIntersection_label-lLO_radius-8mm_mask.nii'), ...
%                 strcat('rsub-', num2str(subID), '_space-MNI_trial-AnatIntersection_label-rLO_radius-8mm_mask.nii'), ...
%                 });
% 
%         case 'individual_coords_50vx'
% 
%             % name contains final voxel size, unpredictable. So go fetch whatever name it has
%             vwfafr_str = ['../../outputs/derivatives/cpp_spm-rois/sub-',num2str(subID),'/rsub-',num2str(subID),'_space-MNI_trial-Expansion_label-VWFAfr_voxels-*.nii'];
%             vwfafr = dir(vwfafr_str);
% %             llo_str = ['../../outputs/derivatives/cpp_spm-rois/sub-',num2str(subID),'/rsub-',num2str(subID),'_space-MNI_trial-Expansion_label-lLO_voxels-*.nii'];
% %             llo = dir(llo_str);
% %             rlo_str = ['../../outputs/derivatives/cpp_spm-rois/sub-',num2str(subID),'/rsub-',num2str(subID),'_space-MNI_trial-Expansion_label-rLO_voxels-*.nii'];
% %             rlo = dir(rlo_str);
% 
%             % add the names to the list
%             opt.maskName = horzcat(opt.maskName, ...
%                 { ...
%                 vwfafr.name, ...
% %                 llo.name, ...
% %                 rlo.name, ...
%                 });
    end
end

end
