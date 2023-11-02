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
% - vwfa: one big area
% - split: anterior and posterior vwfa
% - postemp: check that opt.subject is correct. Not all of them are
%            included in the language analysis. There will be errors
% - loc: both L and R
% - v1
opt.masksCondition = 'v1';

if strcmp(opt.masksCondition,'loc')
    % Check if '023' exists in the cell array
    if any(strcmp(opt.subjects, '023')), opt.subjects(strcmp(opt.subjects, '023')) = []; end
    if any(strcmp(opt.subjects, '024')), opt.subjects(strcmp(opt.subjects, '024')) = []; end
end
if strcmp(opt.masksCondition,'postemp')
    % overwrite for simplicity
    opt.subjects = {'006', '007', '008', '009', '010', '011', '013', '018', '019', '020', '021', '022', '023', '024', '027', '028'};
end
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
        case 'postemp'
            maskPath = {fullfile(opt.dir.roi, subName, ['r' subName '_hemi-L_space-MNI_atlas-fedorenko_contrast-french_label-PosTemp_mask.nii'])};  
            maskName = {'PosTemp'};
        case 'loc'
            maskPath = {...
                        fullfile(opt.dir.roi, subName, ['r' subName '_hemi-L_space-MNI_atlas-neurosynth_method-expansionIntersection_label-lLO_mask.nii'])
                        fullfile(opt.dir.roi, subName, ['r' subName '_hemi-R_space-MNI_atlas-neurosynth_method-expansionIntersection_label-rLO_mask.nii'])};
            maskName = {'lLO', 'rLO'};
        case 'v1'
            maskPath = {fullfile(opt.dir.roi, subName, ['r' subName '_hemi-B_space-MNI_atlas-JUBrain_contrast-allFrench_label-V1_mask.nii'])};  
            maskName = {'v1'};
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

        contrasts = {'frw','fpw','fnw','ffs','brw','bpw','bnw','bfs'};

        for iCon = 1:numel(contrasts)

            % get contrast number 
            conNum = find(strcmp({spmMat.SPM.xCon.name}, contrasts(iCon)));

            % load .nii files and get the volume data
            conHdr = spm_vol(fullfile(opt.dir.stats, subName, 'task-wordsDecoding_space-IXI549Space_FWHM-2_node-mvpaGLM', ['spmT_00' num2str(conNum) '.nii']));
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
                            {subName, group, iCon, cond, maskName{iMask}, peakResponse, meanResponse});

        end

    end

end

% save report
writecell(report,['univariateReport_' opt.masksCondition '_jubrain.txt']);














