%% PPI - run GLM analysis with interaction as regressor
% 
% Create and run GLM batch for the interaction of the PPI variable 
%
% Will use opt.ppi.glmStep = 'interaction' to choose the right batch to 
% mimick and load the right number of regressors
%
% Uses modified versions of bidsFFX, setBatchSubjectLevelGLMSpec, bidsResults
% from bidspm, until it is integrated in a proper way
%
% TO DO:
% - can I put regressors in bids stats model?
% - add overwriting if folder is not empty


% load these GLM-specific options
opt = interactionOption(opt);

% Get subject number
subName = ['sub-', opt.thisSub];

% Load the PPI.mat file and assign the values as regressors:
% Regressor 1: Name = PPI-interaction, Value = PPI.ppi
% Regressor 2: Name = VWFA-BOLD, Value = PPI.Y
% Regressor 3: Name = Psych_FW-SFW, Value = PPI.P
% Regressor 4: Name = Block 1, Value = block1
opt = ppi_loadPpiAndRegressors(opt);

%% Create the GLM batches 
%
% GLM Specific requirements are loaded, we can move on to the results
%
% Uses modified versions of bidsFFX, setBatchSubjectLevelGLMSpec, bidsResults
% from bidspm, until it is integrated in a proper way

matlabbatch = ppi_fillBatch(opt, 'GLM');

% Save and run batch bidspm-style
batchName = ['PPI-GLM_task-', char(opt.taskName), '_space-', char(opt.space), '_FWHM-', num2str(opt.fwhm.func)];

status = saveAndRunWorkflow(matlabbatch, batchName, opt, opt.thisSub);

%% Update the step

opt.ppi.step = 2;



%% Step-specific options
function opt = interactionOption(opt)
    
% if there is already a model and results information, delete them to avoid
% overlapping
opt.model = [];
opt.results = [];

% Specify the GLM step we are performing, to add the correct regressors
opt.ppi.glmStep = 'interaction';

% Model specifies all the contrasts
opt.model.file = fullfile(opt.dir.root, 'code', ...
    'models', ['model-PPI-interaction-' opt.ppi.dataset '_smdl.json']);

switch opt.ppi.dataset

    case 'localzier'
        opt.results(1).nodeName = 'subject_level';
        opt.results(1).name = {'fw-sfw'};
        opt.results(1).png = true();    opt.results(1).csv = true();
        opt.results(1).p = 0.001;       opt.results(1).MC = 'none';
        opt.results(1).k = 0;
        opt.results(1).binary = true(); opt.results(1).montage.do = false();
        opt.results(1).nidm = true();   opt.results(1).threshSpm = true();
        
        opt.results(2).nodeName = 'subject_level';
        opt.results(2).name = {'bw-sbw'};
        opt.results(2).png = true();    opt.results(2).csv = true();
        opt.results(2).p = 0.001;       opt.results(2).MC = 'none';
        opt.results(2).k = 0;
        opt.results(2).binary = true(); opt.results(2).montage.do = false();
        opt.results(2).nidm = true();   opt.results(2).threshSpm = true();

    case 'mvpa'

end

%% DO NOT TOUCH
opt = checkOptions(opt);
saveOptions(opt);

end

%% 
function opt = ppi_loadPpiAndRegressors(opt)

subName = ['sub-', opt.thisSub];

ppiFiles = dir(fullfile(opt.dir.ppi, subName, 'PPI-analysis', ['PPI_*label-VWFAfr_x_(' opt.ppi.contrast{1} ')*']));
load(fullfile(ppiFiles(1).folder, ppiFiles(1).name));

% Pre-load regressors
opt.ppi.interaction.regress1.name = 'PPI-interaction';
opt.ppi.interaction.regress1.val = PPI.ppi;

opt.ppi.interaction.regress2.name = 'VWFA-BOLD';
opt.ppi.interaction.regress2.val = PPI.Y;

opt.ppi.interaction.regress3.name = 'Psych_FW-SFW';
opt.ppi.interaction.regress3.val = PPI.P;

% Same regressor as opt.ppi.concat.regressor.R 
oldReg = load(fullfile(opt.dir.ppi, subName, '1stLevelConcat' ,[subName '_block-regressor.mat']));

opt.ppi.interaction.regress4.name = 'Block 1';
opt.ppi.interaction.regress4.val = oldReg.R;

end