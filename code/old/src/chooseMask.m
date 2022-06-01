function [opt] = chooseMask(opt)

    opt.maskName = [];

    for iSub = 1:numel(opt.subjects)

        subID = opt.subjects{iSub};
        % %         % get subject folder name
        %         subFolder = ['sub-', subID];
        %
        %         opt.maskPath = fullfile(fileparts(mfilename('fullpath')), '..', 'outputs','derivatives' ,'cpp_spm-rois',subFolder);

        % masks to decode/use

        opt.maskName = horzcat(opt.maskName, { ...
                                              strcat('sub-', num2str(subID), '_hemi-L_space-MNI_label-VWFA_radius-10mm_mask.nii'), ...
                                              strcat('sub-', num2str(subID), '_hemi-L_space-MNI_label-LOC_radius-10mm_mask.nii'), ...
                                              strcat('sub-', num2str(subID), '_hemi-L_space-MNI_label-pFS_radius-10mm_mask.nii'), ...
                                              strcat('sub-', num2str(subID), '_hemi-R_space-MNI_label-LOC_radius-10mm_mask.nii'), ...
                                              strcat('sub-', num2str(subID), '_hemi-R_space-MNI_label-pFS_radius-10mm_mask.nii'), ...
                                              strcat('sub-', num2str(subID), '_hemi-R_space-MNI_label-pSTG_radius-10mm_mask.nii')});

        % use in output roi name
        opt.maskLabel = {'VWFA-Left', 'LOC-Left', 'PFS-Left', 'LOC-Right', 'PFS-Right'};
    end

end
