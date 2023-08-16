function matlabbatch = ppi_customizeBatch(opt, iSub)

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
% Will add VOI automatically at the beginning of the name
batchParams.name = [subName '_vwfa'];

% - ROI 1: Thresholded SPM
% SPM.mat file is the same as above
batchParams.roi{1}.spm.spmmat = {spmPath};
batchParams.roi{1}.spm.contrast = 14;       % TBD, don't know which is best to use (16/8)
batchParams.roi{1}.spm.conjunction = 1;
batchParams.roi{1}.spm.threshdesc = 'none';
batchParams.roi{1}.spm.thresh = 0.001;
batchParams.roi{1}.spm.extent = 0;
batchParams.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});

% - ROI 2: mask
% Find the mask to use, the only one that is
% * resliced
% * made with the state-of-the-art method
% * made around VWFA
vwfaMask = dir(fullfile(opt.dir.rois, subName, 'r*_method-expansionIntersection_label-VWFAfr*'));
batchParams.roi{2}.mask.image = {fullfile(vwfaMask.folder, vwfaMask.name)};
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

