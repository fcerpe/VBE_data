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

switch opt.ppi.step
    case 1
        if strcmp(opt.ppi.dataset, 'mvpa'), opt.ppi.contrast = {'frw-ffs'};
        else, opt.ppi.contrast = {'fw-sfw'};
        end
        voiList = {'VWFAfr'};
    case 2
        if strcmp(opt.ppi.dataset, 'mvpa')
            if strcmp(opt.ppi.script, 'french'), opt.ppi.contrast = {'frw','fpw','fnw','ffs'};
            else, opt.ppi.contrast = {'brw','bpw','bnw','bfs'};
            end
        else
            opt.ppi.contrast = strsplit(opt.ppi.contrast{1},'-');
        end

        % VOIs stay the same
        voiList = opt.ppi.voiList;

end

for iSub = 1:numel(opt.subjects)

    % (18/08/2023)
    % Just manual additions hidden from sight. No generalization to
    % different contrasts, area, particular cases

    % Start from which step we are in
    % step == 1, do VWFAfr
    % step == 2, skip VWFAfr (it was already created anyway)
    for iVoi = 1:numel(voiList)
        
        % Iterative function: If the batch results empty, re-do it with a
        % more lax threshold
        emptyVOI = true;

        % Index representing which threshold to use for the VOI extraction
        % 3 = 0.001; 2 = 0.01; 1 = 0.05
        opt.ppi.voiThres = 3; 

        while emptyVOI && opt.ppi.voiThres > 0

            % Choose the specificed VOI to extract from the 1st Level GLM
            currentVoi = pickMask(opt, voiList{iVoi});
            
            % Make the batch
            matlabbatch = ppi_fillBatch(opt, 'VOI', currentVoi);

            % Save and run batch bidspm-style
            batchName = ['VOI-extraction-' voiList{iVoi} '_task-', char(opt.taskName), '_space-', char(opt.space)];
            status = saveAndRunWorkflow(matlabbatch, batchName, opt, opt.thisSub);
            
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



function mask = pickMask(opt, voiName)

% Check validity of input VOI
if ~ismember(voiName, opt.ppi.voiList)
    warning('Name of area is incorrect. Check spelling');
    return
end

% Go to subject's ROI folder
subName = ['sub-' opt.thisSub];
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

        % In cpp_spm-rois, there should be many fedorenko ROIs. 
        % Use masks intersected with [FW-SFW] contrast, it will used to 
        % probe for [BW-SBW] interactions
        fedorenkoRoi = dir(fullfile(subRoiPath, ['r' subName '_hemi-L_*_atlas-Fedorenko_contrast-french_label-' voiName(4:end) '_mask.nii']));

        % Check contents of dir. It should not be empty ...
        if isempty(fedorenkoRoi)
            warning(['No ROI found for ' voiName '. That''s not right, check the folder']);
            return
        end
        % ... and there should only be one mask
        if numel(fedorenkoRoi) > 1
            warning(['Too many ROIs found for ' voiName '. That''s not right, check the folder']);
            return
        end
        
        % If they're correct, use the mask
        mask = fullfile(fedorenkoRoi.folder, fedorenkoRoi.name);

end


end
