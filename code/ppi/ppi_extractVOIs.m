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

if strcmp(opt.ppi.script, 'french'), opt.ppi.contrast = {'fw-sfw'};
else, opt.ppi.contrast = {'bw-sbw'};
end

switch opt.ppi.step
    case 1
        opt.ppi.contrast = opt.ppi.contrast;
        voiList = {'VWFAfr'};
    case 2
        opt.ppi.contrast = strsplit(opt.ppi.contrast{1},'-');
        voiList = opt.ppi.voiList;
end

for iSub = 1:numel(opt.subjects)

    % (18/08/2023)
    % Just manual additions hidden from sight. No generalization to
    % different contrasts, area, particular cases

    % Start from which step we are in
    % step == 1, do VWFAfr
    % step == 2, skip VWFAfr (it was already created anyway)
    for iVoi = opt.ppi.step:numel(voiList)
        
        % Iterative function: If the batch results empty, re-do it with a
        % more lax threshold
        emptyVOI = true;

        % Index representing which threshold to use for the VOI extraction
        % 3 = 0.001; 2 = 0.01; 1 = 0.05
        opt.ppi.voiThres = 3; 

        while emptyVOI && opt.ppi.voiThres > 0

            % Choose the specificed VOI to extract from the 1st Level GLM
            currentVoi = pickMask(opt, iSub, voiList{iVoi});
            
            % Make the batch
            matlabbatch = ppi_fillBatch(opt, iSub, 'VOI', currentVoi);

            % Save and run batch bidspm-style
            batchName = ['VOI-extraction-' voiList{iVoi} '_task-', char(opt.taskName), '_space-', char(opt.space), '_FWHM-', num2str(opt.fwhm.func)];
            status = saveAndRunWorkflow(matlabbatch, batchName, opt, opt.subjects{iSub});
            
            % Check that the VOI is not empty. If it is, launche it again
            % and set a different threshold
            if ~isempty(xY.y)
                emptyVOI = false;
            else
                opt.ppi.voiThres = opt.ppi.voiThres -1;
            end


        end

    end 

    %% Move all the created VOIs and figures to derivatives/spm-PPI/sub/VOIs
    % Find them
    % One VOI actually has:
    % - one .mat file
    % - one mask.nii file
    % - one eigen.nii file
    subName = ['sub-' opt.subjects{iSub}];

    statsFolder = dir(fullfile(opt.dir.stats, subName, ['*ppi*']));
    voisInFolder = dir(fullfile(statsFolder.folder, statsFolder.name, ['VOI_*']));

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
if ~ismember(voiName, opt.ppi.voiList)
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
        % participant. 
        % Avoid those intersected with [FW-SFW] or [BW-SBW] contrasts
        fedorenkoRois = dir(fullfile(subRoiPath, ['r' subName '_hemi-L_*_atlas-Fedorenko_label-*.nii']));

        % Check contents of dir. They should be the right number 
        if numel(fedorenkoRois) ~= 6
            warning('The number of Fedorenko''s parcels is not correct. There should be six ROIs for each participant, check the folder');
            return
        end

        % If they're correct, fetch the one we were asked for
        voiFilename = ['r' subName '_hemi-L_space-MNI_atlas-fedorenko_label-' voiName(4:end) '_mask.nii'];
        voiIdx = find(strcmp({fedorenkoRois.name}, voiFilename));

        mask = fullfile(fedorenkoRois(voiIdx).folder, fedorenkoRois(voiIdx).name);

end

% check that the mask exists
% if not, warn
% if so, return it


end
