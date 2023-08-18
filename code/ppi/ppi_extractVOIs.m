%% PPI - Extracction of VOIs from PPI-GLM Results
%
% For each subject and area (only VWFA), will extract a VOI.mat file
% that contains the time course of BOLD reponse in that area.
% Uses a pre-made batch (using GUI) as template and fills in the 
% subject-specific parameters 
%
% TO-DO (18/08/2023)
% - find out which spmt contrast to use, neuroscientific problem
% - add figures to batch
% - extend to RH_ fedoerenko masks
% - make it a function and take which ROIs as param


for iSub = 1:numel(opt.subjects)

    % (18/08/2023)
    % Just manual additions hidden from sight. No generalization to
    % different contrasts, area, particular cases
    for iVoi = 1:numel(opt.voiList)

        % Choose the specificed VOI to extract from the 1st Level GLM
        currentVoi = pickMask(opt, iSub, opt.voiList{iVoi});

        matlabbatch = ppi_fillBatch(opt, iSub, 'VOI', currentVoi);

        % Save and run batch bidspm-style
        batchName = ['VOI-extraction-' opt.voiList{iVoi} '_task-', char(opt.taskName), '_space-', char(opt.space), '_FWHM-', num2str(opt.fwhm.func)];

        status = saveAndRunWorkflow(matlabbatch, batchName, opt, opt.subjects{iSub});

    end 

    %% Move all the created VOIs and figures to derivatives/spm-PPI/sub/VOIs
    % Find them
    % One VOI actually has:
    % - one .mat file
    % - one mask.nii file
    % - one eigen.nii file
    statsFolder = dir(fullfile(opt.dir.stats, subName, ['*ppi*']));
    voisInFolder = dir(fullfile(statsFolder.folder, statsFolder.name, ['VOI_' matlabbatch{1}.spm.util.voi.name '*']));

    % If destination folder does not exists, make it
    destinationPath = fullfile(opt.dir.ppi, subName, 'VOIs');
    if ~exist(destinationPath)
        mkdir(destinationPath)
    end

    % Move them
    for vp = 1:numel(voisInFolder)
        voiPath = fullfile(voisInFolder(vp).folder, voisInFolder(vp).name);
        movefile(fullfile(voiPath), fullfile(destinationPath, voisInFolder(vp).name),'f');
    end
    
end



function mask = pickMask(opt, iSub, voiName)

% Check validity of input VOI
if ~ismember(voiName, opt.voiList)
    warning('Name of area is incorrect. Check spelling');
    return
end

% Go to subject's ROI folder
subName = ['sub-', opt.subjects{iSub}];
subRoiPath = fullfile(opt.dir.rois, subName);

% Pick existing masks
% fedorenko should be 6-12, vwfa should only be 1
switch voiName 
    case 'VWFAfr'
        vwfaRoi = dir(fullfile(subRoiPath, ['r' subName '*_method-expansionIntersection_label-VWFAfr_mask.nii']));

        % Check contents of dir. It should not be empty ...
        if isempty(vwfaRoi)
            warning('No ROI found for VWFA. That''s not right, check the folder');
            return
        end
        % ... and there should only be one mask
        if numel(vwfaRoi) > 1
            warning('Too many ROIs found for VWFA. That''s not right, check the folder');
            return
        end

        % If there is only one, the one created in roi_createROIs, add it.
        mask = fullfile(vwfaRoi.folder, vwfaRoi.name);

    % For now we only consider Left hemisphere for now
    case {'LH_IFGorb', 'LH_IFG', 'LH_MFG', 'LH_AntTemp', 'LH_PosTemp', 'LH_AngG'}

        % In cpp_spm-rois, there should be many fedorenko ROIs. Pick the
        % original ones, coming from the atlas and resized on the
        % participant. Avoid those intersected with [FW-SFW] or [BW-SBW]
        % contrasts
        fedorenkoRois = dir(fullfile(subRoiPath, ['r' subName '_hemi-L_*_atlas-fedorenko_label-*.nii']));

        % Check contents of dir. They should be the right number 
        if numel(fedorenkoRois) ~= 6
            warning('The number of Fedorenko''s parcels is not correct. There should be six ROIs for each participant, check the folder');
            return
        end

        % If they're correct, fetch the one we were asked for
        voiFilename = ['r' subName '_hemi-L_space-MNI_atlas-fedorenko_label-' voiName(4:end) '_mask.nii'];
        voiIdx = find(ismember(voiFilename, {fedorenkoRois.name}));

        mask = fullfile(fedorenkoRois(voiIdx).folder, fedorenkoRois(voiIdx).name);

end

% check that the mask exists
% if not, warn
% if so, return it


end
