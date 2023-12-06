% Calculate univariate activation in different ROIs for Braille stimuli
%
% For each subject, take the different ROIs created and extract betas
% relative to BW and SBW in the localizer.
% Masks created so far (11/10/2023):
% - VWFA
% - lLO
% - rLO
% - lPosTemp
% - V1
%
% Use visualLocalizer contrast to probe for Braille sensitivity in other areas
%
% TO-DO (11/10/2023)
% - everything

clear;
clc;

warning('off');

% add spm to the path
addpath(fullfile(pwd, '..', 'lib', 'bidspm'));
addpath(fullfile(pwd, '..', 'lib', 'CPP_BIDS'));
bidspm;

% check inside if everything is ok before starting the pipeline
opt = stats_localizer_option();

% do all the areas one after the other
opt.masks = {'VWFA', 'lLO', 'rLO', 'lPosTemp', 'V1'};

% Start a new report - to be transferred to R for data viz
report = {'subject', 'group', 'area', 'condition', 'mean_activation'};

%%

for iMask = 1:numel(opt.masks)

    % Based on the mask / area:
    % - select the corresponding mask
    % - pick the pool of subjects 
    switch opt.masks{iMask}
        case 'VWFA'
            maskName = '_hemi-L_space-MNI_atlas-neurosynth_method-expansionIntersection_label-VWFAfr_mask.nii';
            opt.subjects = {'006', '007', '008', '009', '012', '013', ...
                            '010', '011', '018', '019', '020', '021', '022', '023', '024', '026', '027', '028'};

        case 'lLO'
            maskName = '_hemi-L_space-MNI_atlas-neurosynth_method-expansionIntersection_label-lLO_mask.nii';
            opt.subjects = {'006', '007', '008', '009', '012', '013', ...
                            '010', '011', '018', '019', '020', '021', '022', '026', '027', '028'};
        
        case 'rLO'
            maskName = '_hemi-R_space-MNI_atlas-neurosynth_method-expansionIntersection_label-rLO_mask.nii';
            opt.subjects = {'006', '007', '008', '009', '012', '013', ...
                            '010', '011', '018', '019', '020', '021', '022', '026', '027', '028'};

        case 'lPosTemp'
            maskName = '_hemi-L_space-MNI_atlas-fedorenko_contrast-french_label-PosTemp_mask.nii';
            opt.subjects = {'006', '007', '008', '009', '013', ...
                            '010', '011', '018', '019', '020', '021', '022', '023', '024', '027', '028'};
        
        case 'V1'
            maskName = '_hemi-B_space-MNI_atlas-JUBrain_contrast-allFrench_label-V1_mask.nii';
            opt.subjects = {'006', '007', '008', '009', '012', '013', ...
                            '010', '011', '018', '019', '020', '021', '023', '024', '026', '027', '028'};
    end

    % tell the user
    fprintf(['\nComputing activations for contrast: ' opt.masks{iMask} '\n\n']);


    for iSub = 1:numel(opt.subjects)

        % get the subject ID
        subName = ['sub-' opt.subjects{iSub}];

        % tell the user
        fprintf(['- processing ' subName '\n']);

        % get the complete mask path:
        % ../../outputs/derivatives/roi/sub/mask
        maskPath = fullfile(opt.dir.roi, subName, ['r', subName, maskName]); 

        % load spm mat just in case
        spmMat = load(fullfile(opt.dir.stats, subName, ...
                               'task-visualLocalizer_space-IXI549Space_FWHM-6_node-eyeMovementsGLM', 'SPM.mat'));

        % load mask: load .nii files and get the volume data
        maskHdr = spm_vol(maskPath);
        maskVol = spm_read_vols(maskHdr);

        contrasts = {'bw','sbw'};

        for iCon = 1:numel(contrasts)

            % get contrast number
            conNum = find(strcmp({spmMat.SPM.xCon.name}, contrasts(iCon)));

            % load .nii files and get the volume data
            % Q: what about the beta files? 
            conHdr = spm_vol(fullfile(opt.dir.stats, subName, ...
                                      'task-visualLocalizer_space-IXI549Space_FWHM-6_node-eyeMovementsGLM', ...
                                      ['spmT_00' num2str(conNum) '.nii']));
            conVol = spm_read_vols(conHdr);

            % overlap mask and contrast
            overlapVoxels = conVol(maskVol == 1);

            % calculate peak and average (I don't know which one I need)
            meanResponse = mean(overlapVoxels,'omitnan');
            peakResponse = max(overlapVoxels,[],'omitnan');

            % add to report
            cond = spmMat.SPM.xCon(conNum).name;

            switch subName(end-1:end)
                case {'06','07','08','09','12','13'}
                    group = 'expert';
                otherwise
                    group = 'control';
            end

            report = vertcat(report, ...
                             {subName, group, opt.masks{iMask}, cond, meanResponse});
                            % subject  group  area  condition  mean_activation

        end

    end

end

% inform the user
fprintf(['\nDone. Saving report\n']);

% save report
writecell(report,'braille_sensitivity_tmaps_eyeMovements.txt');














