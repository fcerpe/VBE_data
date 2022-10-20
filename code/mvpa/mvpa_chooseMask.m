function [opt] = mvpa_chooseMask(opt)

    opt.maskName = [];

    for iSub = 1:numel(opt.subjects)

        subID = opt.subjects{iSub};
        % %         % get subject folder name
        %         subFolder = ['sub-', subID];
        %
        %         opt.maskPath = fullfile(fileparts(mfilename('fullpath')), '..', 'outputs','derivatives' ,'cpp_spm-rois',subFolder);

        % masks to decode/use

        opt.maskName = horzcat(opt.maskName, ...
                        { ...
                          strcat('sub-', num2str(subID), '_space-MNI_label-VWFAfr_radius-10mm_mask.nii'), ...
                          strcat('sub-', num2str(subID), '_space-MNI_label-VWFAbr_radius-10mm_mask.nii'), ...
                          strcat('sub-', num2str(subID), '_space-MNI_label-lLOC_radius-10mm_mask.nii'), ...
                          strcat('sub-', num2str(subID), '_space-MNI_label-lpFS_radius-10mm_mask.nii'), ...
                          strcat('sub-', num2str(subID), '_space-MNI_label-rLOC_radius-10mm_mask.nii'), ...
                          strcat('sub-', num2str(subID), '_space-MNI_label-rpFS_radius-10mm_mask.nii') ...
%                           strcat('sub-', num2str(subID), '_hemi-R_space-MNI_label-pSTG_radius-10mm_mask.nii') ...
                          });

        % use in output roi name
        opt.maskLabel = {'VWFAfr', 'VWFAbr', 'lLOC', 'lPFS', 'rLOC', 'rPFS'};
    end

end
