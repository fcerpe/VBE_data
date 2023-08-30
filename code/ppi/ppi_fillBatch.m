function matlabbatch = ppi_fillBatch(opt, iSub, batchID, voiID, conID)


switch batchID

    case 'VOI'
        matlabbatch = fillBatchVOI(opt, iSub, voiID);

    case 'PPI'
        matlabbatch = fillBatchPPI(opt, iSub, voiID, conID);

    case 'GLM'
        matlabbatch = fillBatchGLM(opt, iSub);

end

end


%% VOI 
function matlabbatch = fillBatchVOI(opt, iSub, voiID)

% Get subject number
subName = ['sub-', num2str(opt.subjects{iSub})];

% Get to work, the matlab batch needs:
batchParams = struct;

% - SPM.mat file on which to work
% Among the stats folders created so far, get the one with a PPI node
% (hoping there is only one)
stats = dir(fullfile(opt.dir.stats, subName, ['*ppi*']));
spmPath = fullfile(stats.folder, stats.name, 'SPM.mat');
batchParams.spmmat = {spmPath};

% - F-contrast adjustment
% Load the SPM.mat file, the number of the F-contrast may vary but it's in there
load(spmPath);
% List all the stats as a string of characters: T or F
% the only contrast F is "effects of interest", so its position is the
% position of the contrast used as adjustment
listOfContrasts = [SPM.xCon.STAT];
fContrastIdx = find(listOfContrasts == 'F');
batchParams.adjust = fContrastIdx;

% - Session number
% Fixed, we concatenated the runs so there is only one
batchParams.session = 1;

% - Name of the VOI
% Trim the file to obtain the name of the area
trimName = strsplit(voiID, {'_hemi-','_space-','_atlas-','_method-','_label-','_mask'});
voiHemi = trimName{2};
voiName = trimName{end-1};
% Will add VOI automatically at the beginning of the name
batchParams.name = [subName '_hemi-' voiHemi '_label-' voiName];

% - ROI 1: Thresholded SPM
% SPM.mat file is the same as above
batchParams.roi{1}.spm.spmmat = {spmPath};

% Find the FW-SFW contrast (TBD, don't know which is best to use (16/8))
conIdx = find(strcmp({SPM.xCon.name},'fw-sfw_1'));
batchParams.roi{1}.spm.contrast = conIdx;       
batchParams.roi{1}.spm.conjunction = 1;
batchParams.roi{1}.spm.threshdesc = 'none';

% Change the threshold based on the iterative search
switch opt.ppi.voiThres
    case 3, pval = 0.001; 
    case 2, pval = 0.01;
    case 1, pval = 0.05;
end
batchParams.roi{1}.spm.thresh = pval;
batchParams.roi{1}.spm.extent = 0;
batchParams.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});

% - ROI 2: mask
% Find the mask to use, the only one that is
% * resliced
% * made with the state-of-the-art method
% * made around VWFA
roiMask = voiID;
batchParams.roi{2}.mask.image = {roiMask};
batchParams.roi{2}.mask.threshold = 0;

% - expression
% How to treat the ROIs. In our case, intersecate
% iX referes to the order in which the rois are created
batchParams.expression = 'i1 & i2';

% By serendipity (I press extra buttons while generating the batch),
% the batch includes a figure
% Add those parameters as matlabbatch{2}
% batchFig = struct;
% batchFig.fname = [subName + "_VOI_" + batchParams.name + "_figure"];
% batchFig.figname = 'Graphics';
% batchFig.opts = 'png';

matlabbatch{1}.spm.util.voi = batchParams;
% matlabbatch{2}.spm.util.print = batchFig;

end

%% PPI
function matlabbatch = fillBatchPPI(opt, iSub, voiID, conID)

% Get subject number
subName = ['sub-', num2str(opt.subjects{iSub})];

% Create temp struct
batchParams = struct;

% - SPM.mat file on which to work
% Among the stats folders created so far, get the one with a PPI node
% (hoping there is only one)
stats = dir(fullfile(opt.dir.stats, subName, ['*ppi*']));
spmPath = fullfile(stats.folder, stats.name, 'SPM.mat');
batchParams.spmmat = {spmPath};

% - VOI 
% From the list of VOIs, take the one specified
% In the case of Fedorenko parcels, split the hemisphere and name
if startsWith(voiID, 'LH_'), voiName = voiID(4:end);
else, voiName = voiID;
end

voiFolder = dir(fullfile(opt.dir.ppi, subName, 'VOIs', ['VOI_*_label-' voiName '_*.mat']));
voiPath = fullfile(voiFolder.folder, voiFolder.name);
batchParams.type.ppi.voi = {voiPath};

% Specify contrasts and weights
% Must be specified as an n (number of conditions in PPI) x 3 matrix
% * first column indexes SPM.Sess.U(i) -> number of contrast in SPM.xCon
% * second column indexes SPM.Sess.U(i).name{ii} -> leave at '1' 
% * third column is the contrast weight

% switch contrast: FW SFW BW SBW FW-SFW BW-SBW
contrast = conID;
switch contrast
    case 'fw',      weights = [1 1 1];
    case 'sfw',     weights = [2 1 1];
    case 'fw-sfw',  weights = [1 1 1; 2 1 -1];
    case 'bw',      weights = [3 1 1];
    case 'sbw',     weights = [4 1 1];
    case 'bw-sbw',  weights = [3 1 1; 4 1 -1];
end
batchParams.type.ppi.u = weights;

% - output name
% standard seems to be VOIx(contrast)
batchParams.name = [subName '_hemi-L_label-' voiName '_x_(' contrast ')'];

% - display result graphs?
batchParams.disp = 1;

matlabbatch{1}.spm.stats.ppi = batchParams;

end

%% GLM - only PPI-interaction
% GLM in the concatenation is taken care by bidspm-stats
function matlabbatch = fillBatchGLM(opt, iSub)

% Get subject number
subName = ['sub-', num2str(opt.subjects{iSub})];

% Specify the folers of each subject, to ease path names
concatFolder = fullfile(opt.dir.ppi, subName, '1stLevelConcat');
glmFolder = fullfile(opt.dir.ppi, subName, 'task-visualLocalizer_space-IXI549Space_FWHM-6_node-ppiInteractionGLM');

% Create temp struct
batchSpec = struct;
batchEst = struct;
batchCon = struct;

% 1. fMRI specification batch
batchSpec.dir = {glmFolder};
batchSpec.timing.units = 'secs';
batchSpec.timing.RT = 1.75;
batchSpec.fmri_t = 29;
batchSpec.fmri_t0 = 14;

% load the concatenated runs
load(fullfile(concatFolder, [subName, '_concatenated-scans-list.mat']));
batchSpec.sess.scans = runs.scans;

batchSpec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
batchSpec.sess.multi = {''};
% Regressor 1: PPI-interaction
batchSpec.sess.regress(1).name = opt.ppi.interaction.regress1.name;
batchSpec.sess.regress(1).val = [opt.ppi.interaction.regress1.val];
% Regressor 2: VWFA-BOLD
batchSpec.sess.regress(2).name = opt.ppi.interaction.regress2.name;
batchSpec.sess.regress(2).val = [opt.ppi.interaction.regress2.val];
% Regressor 3: Interaction
batchSpec.sess.regress(3).name = opt.ppi.interaction.regress3.name;
batchSpec.sess.regress(3).val = [opt.ppi.interaction.regress3.val];
% Regressor 4: block
batchSpec.sess.regress(4).name = opt.ppi.interaction.regress4.name;
batchSpec.sess.regress(4).val = [opt.ppi.interaction.regress4.val];

batchSpec.sess.multi_reg = {fullfile(concatFolder, [subName '_motion-regressors.mat'])};
batchSpec.sess.hpf = 277.777777777778;
batchSpec.fact = struct('name', {}, 'levels', {});
batchSpec.bases.hrf.derivs = [0 0];
batchSpec.volt = 1;
batchSpec.global = 'None';
batchSpec.mthresh = 0.8;
batchSpec.mask = {''};
batchSpec.cvi = 'FAST';

% Assign values to batch
matlabbatch{1}.spm.stats.fmri_spec = batchSpec;


% fMRI estiamtion batch
batchEst.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', ...
                             substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
batchEst.write_residuals = 0;
batchEst.method.Classical = 1;

% Assign values to batch
matlabbatch{2}.spm.stats.fmri_est = batchEst;


% Contrasts manager batch
batchCon.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', ...
                             substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
batchCon.consess{1}.tcon.name = 'PPI-interaction';
batchCon.consess{1}.tcon.weights = [1 0 0 0 0 0 0 0 0 0 0];
batchCon.consess{1}.tcon.sessrep = 'none';
batchCon.delete = 0;

% Assign values to batch
matlabbatch{3}.spm.stats.con = batchCon;


end


