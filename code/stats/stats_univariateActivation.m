% Calculate iunivariate activation 
%
% Given a set of masks to use, will load the contrasts of each
% wordsDecoding condition and calculate the univariate activation in that
% area
%
% TO-DO (18/09/2023)
% - multiple areas option (e.g. vwfa split, just one vwfa)
% - multiple calculation option (e.g. peak, average of voxels)

clear;
clc;

warning('off');

% add spm to the path
addpath(fullfile(pwd, '..', 'lib', 'bidspm'));
addpath(fullfile(pwd, '..', 'lib', 'CPP_BIDS'));
bidspm;

% check inside if everything is ok before starting the pipeline
opt = stats_blockMvpa_option();

% either
% - vwfa, for one big area
% - split, for anterior and posterior vwfa
opt.masksCondition = 'split';

% Initialize report
% Start a new report
report = {'subject','group','contrast','condition','mask','peak','mean'};


%% 

for iSub = 1:numel(opt.subjects)

    subName = ['sub-' opt.subjects{iSub}];

    % fecth vwfa mask
    switch opt.masksCondition 
        case 'vwfa'
            maskPath = {fullfile(opt.dir.roi, subName, ['r' subName '_hemi-L_space-MNI_atlas-neurosynth_method-expansionIntersection_label-VWFAfr_mask.nii'])};  
            maskName = {'VWFA'};
        case 'split'
            maskPath = {...
                        fullfile(opt.dir.roi, subName, ['r' subName '_hemi-L_space-MNI_atlas-neurosynth_method-splitting_label-antVWFA_mask.nii'])
                        fullfile(opt.dir.roi, subName, ['r' subName '_hemi-L_space-MNI_atlas-neurosynth_method-splitting_label-posVWFA_mask.nii'])};
            maskName = {'antVWFA', 'posVWFA'};
    end

    % for each mask
    for iMask = 1:numel(maskPath)
    
        % load the contrasts of the subject (from 49 to 56)
        % TO-DO: 
        % - lookup the number associated with the name of the contrast

        % load spm mat just in case
        spmMat = load(fullfile(opt.dir.stats, subName, 'task-wordsDecoding_space-IXI549Space_FWHM-2_node-mvpaGLM', 'SPM.mat'));

        % load VWFA mask
        % load .nii files and get the volume data
        maskHdr = spm_vol(maskPath{iMask});
        maskVol = spm_read_vols(maskHdr);


        for iCon = 49:56

            % get contrast
            % load .nii files and get the volume data
            conHdr = spm_vol(fullfile(opt.dir.stats, subName, 'task-wordsDecoding_space-IXI549Space_FWHM-2_node-mvpaGLM', ['spmT_00' num2str(iCon) '.nii']));
            conVol = spm_read_vols(conHdr);

            % overlap mask and contrast
            overlapVoxels = conVol(maskVol == 1);

            % calculate peak and average (I don't know which one I need)
            meanResponse = mean(overlapVoxels);
            peakResponse = max(overlapVoxels);

            % add to report
            switch iCon
                case 49, cond = 'frw';
                case 50, cond = 'fpw';
                case 51, cond = 'fnw';
                case 52, cond = 'ffs';
                case 53, cond = 'brw';
                case 54, cond = 'bpw';
                case 55, cond = 'bnw';
                case 56, cond = 'bfs';
            end

            switch subName(end-1:end)
                case {'06', '07','08','09','12','13'}
                    group = 'expert';
                otherwise
                    group = 'control';
            end


            report = vertcat(report, ...
                            {subName, group, iCon, cond, maskName{iMask}, peakResponse, meanResponse});

        end

    end

end

% save report
writecell(report,[opt.masksCondition '_unvariateReport.txt']);














