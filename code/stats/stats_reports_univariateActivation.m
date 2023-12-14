%% Calculate univariate activation
%
% Given a set of masks to use, will load the contrasts of each
% wordsDecoding condition and calculate the univariate activation in that
% area

% Will work iteratively on all the follwing areas and the relative
% sub-groups of subjects:
% - vwfa: one big area
% - split: anterior and posterior vwfa
% - postemp: check that opt.subject is correct. Not all of them are
%            included in the language analysis. There will be errors
% - loc: both L and R
% - v1
% do all the areas one after the other
opt.masks = {'VWFA', 'lLO', 'rLO', 'lPosTemp', 'V1'};

% Start a new report - to be transferred to R for data viz
report = {'subject', 'group', 'area', 'condition', 'mean_activation'};


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
end

% save report
writecell(report,'reports/stats_univariateReport.txt');



