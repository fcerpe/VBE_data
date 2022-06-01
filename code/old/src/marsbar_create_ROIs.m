% clear all; clc;

% set spm
% warning('off');
% addpath(genpath('/Users/battal/Documents/MATLAB/spm12'));
% bspm fmri
% addpath(genpath('/Users/shahzad/Documents/MATLAB/bspmview'));
% add xjview
% addpath(genpath('/Users/battal/Documents/MATLAB/xjview'));

% add cpp repo
run ../../lib/CPP_SPM/initCppSpm.m;

% CHOOSE FROOM THE TWO BELOW
load('visROI_mni_coordinates.mat');
% load('tacROI_mni_coordinates.mat')

radius = 10;

% DO THIS MANUALLY
marsbar('on');
% % MARS.OPTIONS.spacebase.fname =  fullfile(pwd,'template.nii');
% MARS.OPTIONS.spacebase.fname =  '/Users/shahzad/Documents/MATLAB/MotionLocalizerAnalysis/derivatives/cpp_spm/sub-001/ses-001/func/wmeanuasub-001_ses-001_task-tactileLocalizer_run-001_bold.nii';

for iROI = 1:length(mni)

    region_name = ROI_names{iROI};

    for iSub = 1:size(mni{iROI}, 1)

        %         SubName = SubNames{iSub,iROI};
        %         SubName = ['Sub',num2str(iSub)];
        SubName = ['Sub00', num2str(iSub)];

        if ~isnan(mni{iROI}(iSub, 1))
            ROI_center = mni{iROI}(iSub, :);
            ROI_name = [region_name, '_', SubName, '_', num2str(radius), 'mm'];
            %             ROI_name = [SubName,'_','space-MNI','_','tac','hemi-' region_name,'_', SubName,'_',num2str(radius),'mm'];
            % create the sphere with marsbar
            params = struct('centre', ROI_center, 'radius', radius);
            roi = maroi_sphere(params);
            saveroi(roi, [ROI_name, '.mat']);
            mars_rois2img([ROI_name, '.mat'], [ROI_name, '.nii']);

            delete([ROI_name, '_labels.mat']);
            delete([ROI_name, '.mat']);

        else

        end

    end
end

% sub-01_space-individual_hemi-L_label-V1d_desc-wang_mask.nii
