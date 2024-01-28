% Compute the temporal signal-to-noise ratio (tSNR) of the acquired raw data 
%
% For each subject, acquisiton, mask option (VWFA; whole-brain), compute
% the average tSNR for both localizer and mvpa runs

% add spm to the path
addpath(fullfile(pwd, '..', 'lib', 'bidspm'));
addpath(fullfile(pwd, '..', 'lib', 'CPP_BIDS'));
bidspm;

% Start a new report - to be transferred to R for data viz
report = {'subject', 'task', 'run', 'mask', 'tSNR'};

revertToSpace = {'IXI549Space'};

%% 

% If there is no stats folder for tsnr, launch unpacking and move files
% If there is no individual space ROI, launch reverting ROI
% Launch calculation of tSNR 

for iSub = 1:numel(opt.subjects)

    % get the subject name
    subName = ['sub-' opt.subjects{iSub}];

    % tell the user
    fprintf(['Processing ' subName '\n']);

    % Find all the files in the ses-*/anat folder
    % We just need the folder
    whenAnat = dir(fullfile(opt.dir.preproc, subName, 'ses-*/anat'));
    sesNum = strsplit(whenAnat(1).folder, {'ses-','/anat'});
    sesName = ['ses-', sesNum{2}];

    % File to load with the deformation field
    deformationField = {fullfile(opt.dir.preproc, subName, sesName, 'anat', ...
                                [subName,'_',sesName,'_from-IXI549Space_to-T1w_mode-image_xfm.nii'])};

    % get the complete lists of masks for a given subject
    % Dir should look like: '../../inputs/raw/sub-*/ses-*/func'
    maskPath = dir(fullfile(opt.dir.raw, subName, 'ses-*', 'func', [subName,'*_task-*_bold.nii'])); 

    % For each raw file
    % - extract tSNR of the whole mask 
    % - apply ROI to each run and extract local tSNR
    for iMask = 1:numel(maskPath)

        % Extract parameters of the mask
        maskParams = strsplit(maskPath(iMask).name, {'-','_'});

        % Go through only the masks that are not 'desc-tsnr'
        if ~ismember({'tsnr'}, maskParams)

            % find information to notify user
            [~, taskPos] = ismember({'task'}, maskParams);
            [~, runPos] = ismember({'run'}, maskParams);    

            maskTask = maskParams{taskPos+1};
            maskRun = maskParams{runPos+1};
    
            % tell the user
            fprintf(['\tExtracting whole-brain tSNR for task-' maskTask ' run-' maskRun '...\n']);
        
            thisMask = fullfile(maskPath(iMask).folder, maskPath(iMask).name);
    
            % Compute tSNR for the bold image, whole-brain
            [tSNRimage, tSNRvol] = computeTsnr(thisMask);
        
            % Report average whole-brain tSNR and add it to the final report
            report = vertcat(report, ...
                             {subName, maskTask, maskRun, 'whole-brain', mean(tSNRvol,'all','omitnan')});
    
    
            % Revert ROI to native space - only VWFA
            vwfaRoi = dir(fullfile(opt.dir.roi, subName, ...
                                   [subName,'_*_space-IXI549Space_*_method-expansionIntersection_label-VWFAfr_mask.nii']));
    
            roiToRevert = {fullfile(vwfaRoi(1).folder, vwfaRoi(1).name)};
    
            % tell the user
            fprintf('\tResampling the ROI to native space...\n');
    
            % Batch instructions from Marco Barilari
            matlabbatch = [];
            matlabbatch{1}.spm.spatial.normalise.write.subj.def(1) = deformationField;
            matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = nan(1, 3);
            matlabbatch{1}.spm.spatial.normalise.write.subj.resample = roiToRevert(:);
            matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = nan(2, 3);
            matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 0;
            matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'nat_';
            
            % Run the batch
            spm_jobman('run', matlabbatch);
    
    
            % Load raw bold for reference
            references = dir(fullfile(opt.dir.input, subName, 'ses-*/func/sub-*space-individual_desc-mean_bold.nii'));
            referenceBold = fullfile(references(1).folder, references(1).name);
            
            % Reslice native space ROI to be the same space as native bold
            roiReverted = resliceRoiImages(referenceBold, fullfile(vwfaRoi(1).folder, ['nat_', vwfaRoi(1).name]));
    
            % Load ROI in functional native space
            hdr = spm_vol(roiReverted);
            roiVols = spm_read_vols(hdr);
    
            % Overlap whole-brain tSNR map and ROI
            tSNRroi = tSNRvol(roiVols == 1);
    
            % Add tSNRroi to report
            report = vertcat(report, ...
                             {subName, maskTask, maskRun, 'vwfa-roi', mean(tSNRroi,'all','omitnan')});

        end
    end

    % Re-order files:
    
    % Identify source folder and files (any functional tsnr bold)
    sourcePath = dir(fullfile(opt.dir.raw, subName, ['ses-*/func/*desc-tsnr*']));

    % Choose destination and make folder if it does not exists already
    destinationPath = fullfile(opt.dir.stats, subName, 'task-computeTSNR_space-individual');
    if ~exist(destinationPath)
        mkdir(destinationPath)
    end

    % Move files
    for iS = 1:numel(sourcePath)
        movefile(fullfile(sourcePath(iS).folder, sourcePath(iS).name), ...
                 fullfile(destinationPath, sourcePath(iS).name),'f');
    end

    % Rename ROIs 
    % - from 'rnat_...' to '_space-individual_'
    % - from 'nat_...' to '_space-T1w_'
    roiToRename = dir(fullfile(opt.dir.roi, subName, '*nat_sub*'));

    for iR = 1:numel(roiToRename)
        
        % Based on the ROI being resliced or not, assign the space
        switch roiToRename(iR).name(1)
            case 'r'
                nameSplit = strsplit(roiToRename(iR).name, {'rnat_', '_space-','_atlas-'});
                newSpace = 'individual';

            case 'n'
                nameSplit = strsplit(roiToRename(iR).name, {'nat_', '_space-','_atlas-'});
                newSpace = 'T1w';
        end

        % Re-compose name with new space
        newName = [nameSplit{2}, '_space-', newSpace, '_atlas-' nameSplit{4}];

        % Rename file
        movefile(fullfile(roiToRename(iR).folder, roiToRename(iR).name), ...
                 fullfile(roiToRename(iR).folder, newName),'f');
    end


end

% inform the user
fprintf('\nDone. Saving report\n');

% save report
writecell(report,'reports/stats_compute_tSNR.txt');


%% SUBFUNCTIONS

%% Compute whole-brain tSNR 
function extractTSNR()
    
end

%% Revert ROIs to native / individual space

