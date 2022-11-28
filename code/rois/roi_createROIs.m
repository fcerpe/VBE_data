%% Create ROIs based on peak coordinates from thesingle subjects
%
% Script from Iqra: tmpCreateROIs and marsbar_create_ROIs merged together
%
% Steps:
% 1 - open spm for each sub and contrast to get the peak coordinates in each subject
%
% 2 - in the right contrast, get to the neurosynth coords for the
%     corresponding area(s)
%     VWFA = -44 -56 -16    LOC = -46 -70 -5 and +46 -70 -5
%     PFS = -40 -54 -18 and 42 -50 -20 (beware of proximity with vwfa)
%
% 3 - draw a 10mm sphere around these coordinates and get the highest peak
%
% 4 - save coordinates in "roi_getMNIcoords.m"
%
% 5 - run section-by-section

%% clear
clear;
clc;

%% Let's get started

% add cpp repo
initCppSpm;

% marsbar;
% options > edit options > base space for ROIs > get your spmT.nii > accept

% get options
opt = roi_option();

% get their coordinates
mni = roi_getMNIcoords(opt.subjects);

roiNames = opt.roiList;

save('ROIs_mni_coordinates.mat', 'roiNames', 'mni');

%% Get the ROIs (actually just the spheres)

for iSub = 1:length(opt.subjects)

    % Get subject number
    subName = ['sub-', num2str(opt.subjects{iSub})];
    
    % for each region this subject has
    for iReg = 1:size(mni{iSub}, 1) 

        % if the region is defined (vwfa-br for all, but in some is not present)
        if not(isnan(mni{iSub}(iReg, :)))

            % Get the center
            ROI_center = mni{iSub}(iReg, :);

            % Get the name of the roi for filename
            switch iReg
                case 1
                    regName = 'VWFAfr';
                case 2
                    regName = 'VWFAbr';
                case 3
                    regName = 'lLOC';
                case 4
                    regName = 'lpFS';
                case 5
                    regName = 'rLOC';
                case 6
                    regName = 'rpFS';
            end

            % Set up bids-like name
            ROI_save_name = [subName,'_','space-MNI','_', ...
                             'label-',regName,'_','radius-',num2str(opt.radius),'mm','_mask'];

            betaReference = fullfile(opt.dir.stats, subName, ...
                                 'task-wordsDecoding_space-IXI549Space_FWHM-2', ...
                                 'spmT_0001.nii');
            
            % specify the sphere characteristics for each of them
            sphereParams = struct;
            sphereParams.location = ROI_center;
            sphereParams.radius = opt.radius;

            % specify the path for each subject
            outputPath = [opt.dir.rois,'/',subName];

            mask = createRoi('sphere', sphereParams, betaReference, outputPath, opt.saveROI);
            mask = spm_summarise(betaReference, mask);

            % rename the mask to a bids-like name
            % movefile oldName newName
            % - find folder and name
            % - rename

%             % create the sphere with marsbar and save it
%             params = struct('centre', ROI_center, 'radius', opt.radius);
%             roi = maroi_sphere(params);
%             saveroi(roi, [ROI_save_name, '.mat']);
%             mars_rois2img([ROI_save_name, '.mat'], [ROI_save_name, '.nii']);
% 
%             % Delete .mat files, not necessary
%             delete([ROI_save_name, '_labels.mat']);
%             delete([ROI_save_name, '.mat']);

        end
    end
end



% end

% sub-01_space-individual_hemi-L_label-V1d_desc-wang_mask.nii
