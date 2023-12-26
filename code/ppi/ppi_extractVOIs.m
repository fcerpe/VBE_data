%% PPI - Extracction of VOIs from PPI-GLM Results
% For a given subject and area, extract a VOI.mat file containing the time
% course of BOLD reponse in that area.
% Uses a pre-made batch (using GUI) as template and fills in the
% subject-specific parameters

%% Determine case-scpecifc sript and areas
% script: french or braille depending on 'ppi_option'
switch opt.ppi.script 

    case 'french'
        opt.ppi.contrast = {'fw-sfw'};

    case 'braille'
        opt.ppi.contrast = {'bw-sbw'};
end

% analysis step: 1- VOI extraction on contrast, 2- on single conditions
switch opt.ppi.step

    case 1
        opt.ppi.contrast = opt.ppi.contrast;
        % Assumes that the first region is the seed
        voiList = opt.ppi.voiList(1);

    case 2
        % Split the contrast to obtain the two single conditions
        opt.ppi.contrast = strsplit(opt.ppi.contrast{1},'-');
        voiList = opt.ppi.voiList;
end


%% Extract VOIs 
% For all the specified areas
for iVoi = 1:numel(voiList)

    % Iterative function will use a more lax contrast if areas are empty
    % Initialize check variable
    emptyVOI = true;

    % Specify which threshold to use for the VOI extraction
    % 3- 0.001 
    % 2- 0.01 
    % 1- 0.05
    opt.ppi.voiThreshold = 3;

    while emptyVOI && opt.ppi.voiThreshold > 0

        % Choose the specificed VOI based on sub and area
        currentVoi = pickMask(opt, voiList{iVoi});

        % Make the batch, picking the selected threshold
        matlabbatch = ppi_fillBatch(opt, 'VOI', currentVoi);

        % Save and run batch bidspm-style
        batchName = ['VOI-extraction-',voiList{iVoi},'_task-',char(opt.taskName), ...
                     '_space-',char(opt.space),'_FWHM-',num2str(opt.fwhm.func)];

        status = saveAndRunWorkflow(matlabbatch, batchName, opt, opt.subjects{1});

        % Check VOI, if empty launch it again with different threshold
        if ~isempty(xY.y)
            emptyVOI = false;
        else
            opt.ppi.voiThreshold = opt.ppi.voiThreshold -1;
        end
    end
end


%% Move all the created VOIs and figures to derivatives/spm-PPI/sub/VOIs

% For one VOI, there actually are:
% - one .mat file
% - one mask.nii file
% - one eigen.nii file

% Get folder and files
statsFolder = dir(fullfile(opt.dir.stats, opt.subName, ['*ppi*']));
voisInFolder = dir(fullfile(statsFolder.folder, statsFolder.name, ['VOI_*']));

% If destination folder does not exists, make it
destinationPath = fullfile(opt.dir.ppi, opt.subName, 'VOIs');
if ~exist(destinationPath)
    mkdir(destinationPath)
end

% Move files
for vp = 1:numel(voisInFolder)
    voiPath = fullfile(voisInFolder(vp).folder, voisInFolder(vp).name);
    movefile(fullfile(voiPath), fullfile(destinationPath, voisInFolder(vp).name),'f');
end
    



%% SUPPORT FUNCTIONS

function mask = pickMask(opt, voiName)

% Check validity of input VOI
if ~ismember(voiName, opt.ppi.voiList)
    warning('Name of area is incorrect. Check spelling');
    return
end

% Go to subject's ROI folder
subRoiPath = fullfile(opt.dir.rois, opt.subName);

% Pick existing masks
% language areas should be 6-12, vwfa should only be 1
switch voiName 

    case 'VWFAfr'
        vwfaRoi = dir(fullfile(subRoiPath, ...
            ['r',opt.subName,'*space-',opt.space{1},'*_method-expansionIntersection_label-VWFAfr_mask.nii']));

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

        % If the number of masks is correct, use it
        mask = fullfile(vwfaRoi.folder, vwfaRoi.name);

    % Only considers left hemisphere
    case {'LH_IFGorb', 'LH_IFG', 'LH_MFG', 'LH_AntTemp', 'LH_PosTemp', 'LH_AngG'}

        % Among the many areas, pick the one corresponding to the mask 
        % specified in 'ppi_option' and to the [FW > SFW] contrast
        languageRoi = dir(fullfile(subRoiPath, ...
                           ['r',opt.subName,'_hemi-L_*space-',opt.space{1}, ...
                            '*_atlas-language_contrast-french_label-',voiName(4:end),'_mask.nii']));

        % Check contents of dir. There should be only one
        if isempty(languageRoi) || numel(languageRoi) > 1
            warning(['Not the right amount of ROIs for ' voiName '. There should be only one, check the folder']);
            return
        end
        
        % If they're correct, use the mask
        mask = fullfile(languageRoi.folder, languageRoi.name);

end

end
