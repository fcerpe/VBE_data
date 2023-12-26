function matlabbatch = ppi_fillBatch(opt, batchID, voiID, conID)

% Choose the appropriate batch to prepare
switch batchID

    case 'VOI'
        matlabbatch = fillBatchVOI(opt, voiID);

    case 'PPI'
        matlabbatch = fillBatchPPI(opt, voiID, conID);

    case 'GLM'
        matlabbatch = fillBatchGLM(opt);

end

end




%% Case VOI 
function matlabbatch = fillBatchVOI(opt, voiID)

% Initialize the batch 
batchParams = struct;

% - SPM.mat file on which to work
% Pick the stats folders with a PPI node
stats = dir(fullfile(opt.dir.stats, opt.subName, ['*ppi*']));
spmPath = fullfile(stats.folder, stats.name, 'SPM.mat');
batchParams.spmmat = {spmPath};

% - F-contrast adjustment
% Load SPM.mat file
load(spmPath);

% Pick position of F, the only F-contrast ("effects of interest")
listOfContrasts = [SPM.xCon.STAT];
fContrastIdx = find(listOfContrasts == 'F');
batchParams.adjust = fContrastIdx;

% - Session number
% Fixed: runs are concatenated, there is only one
batchParams.session = 1;

% - Name of the VOI
% Trim the file to obtain the name of the area
trimName = strsplit(voiID, {'_hemi-','_space-','_atlas-','_method-','_label-','_mask'});
voiHemi = trimName{2};
voiName = trimName{end-1};

% generate a 'VOI_sub-XXX_hemi-X_label-AREA' filename
batchParams.name = [opt.subName '_hemi-' voiHemi '_label-' voiName];

% - ROI 1: Thresholded SPM
% SPM.mat file is the same as above
batchParams.roi{1}.spm.spmmat = {spmPath};

% Find the FW-SFW contrast 
conIdx = find(strcmp({SPM.xCon.name},'fw-sfw'));
batchParams.roi{1}.spm.contrast = conIdx;       
batchParams.roi{1}.spm.conjunction = 1;
batchParams.roi{1}.spm.threshdesc = 'none';

% Change the threshold based on the iterative search
switch opt.ppi.voiThreshold
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

% Optional parameters to generate and save a figure
% Add those parameters as matlabbatch{2}
% batchFig = struct;
% batchFig.fname = [subName + "_VOI_" + batchParams.name + "_figure"];
% batchFig.figname = 'Graphics';
% batchFig.opts = 'png';

matlabbatch{1}.spm.util.voi = batchParams;
% matlabbatch{2}.spm.util.print = batchFig;

end




%% Case PPI
function matlabbatch = fillBatchPPI(opt, voiID, conID)

% Initialize the batch 
batchParams = struct;

% - SPM.mat file on which to work
% Pick the stats folders with a PPI node
stats = dir(fullfile(opt.dir.stats, opt.subName, ['*ppi*']));
spmPath = fullfile(stats.folder, stats.name, 'SPM.mat');
batchParams.spmmat = {spmPath};

% - VOI 
% From the list of VOIs, take the one specified
% In the case of language parcels, split the hemisphere and name
if startsWith(voiID, 'LH_')
    voiName = voiID(4:end);
else
    voiName = voiID;
end

voiFolder = dir(fullfile(opt.dir.ppi, opt.subName, 'VOIs', ['VOI_*_label-' voiName '_*.mat']));
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
batchParams.name = [opt.subName '_hemi-L_label-' voiName '_x_(' contrast ')'];

% - display result graphs?
batchParams.disp = 1;

matlabbatch{1}.spm.stats.ppi = batchParams;

end




%% Case GLM
function matlabbatch = fillBatchGLM(opt)

% Only for interaction, GLM in the concatenation is taken care by bidspm-stats

% Specify the folder path
concatFolder = fullfile(opt.dir.ppi, opt.subName, '1stLevelConcat');
glmFolder = fullfile(opt.dir.ppi, opt.subName, ...
    ['task-',opt.taskName{1},'_space-',opt.space{1}, ...
     '_FWHM-',num2str(opt.fwhm.func),'_script-',opt.ppi.script,'_node-ppiInteractionGLM']);

% Initialize batches structures
batchSpec = struct;
batchEst = struct;
batchCon = struct;


% 1) fMRI specification batch
batchSpec.dir = {glmFolder};

% load the concatenated runs
load(fullfile(concatFolder, [opt.subName,'_task-',opt.taskName{1},'_concatenated-scans-list.mat']));
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

% Acquitistion parameters
batchSpec.timing.units = 'secs';
batchSpec.timing.RT = 1.75;
batchSpec.fmri_t = 29;
batchSpec.fmri_t0 = 14;

batchSpec.sess.multi_reg = {fullfile(concatFolder, [opt.subName,'_task-',opt.taskName{1},'_motion-regressors.mat'])};
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


% 2) fMRI estimaion batch
batchEst.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', ...
                             substruct('.','val', '{}',{1}, '.','val', '{}',{1}, ...
                                       '.','val', '{}',{1}), substruct('.','spmmat'));
batchEst.write_residuals = 0;
batchEst.method.Classical = 1;

% Assign values to batch
matlabbatch{2}.spm.stats.fmri_est = batchEst;


% 3) Contrasts manager batch
batchCon.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', ...
                             substruct('.','val', '{}',{2}, '.','val', '{}',{1}, ...
                                       '.','val', '{}',{1}), substruct('.','spmmat'));
batchCon.consess{1}.tcon.name = 'PPI-interaction';
batchCon.consess{1}.tcon.weights = [1 0 0 0 0 0 0 0 0 0 0];
batchCon.consess{1}.tcon.sessrep = 'none';
batchCon.delete = 0;

% Assign values to batch
matlabbatch{3}.spm.stats.con = batchCon;

end


