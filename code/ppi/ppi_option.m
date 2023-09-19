function opt = ppi_option()
% returns a structure that contains the options chosen by the user to run
% PPI analysis (called trhough ppi_main)

if nargin < 1
    opt = [];
end

% suject to run in each group
opt.subjects = {'006'}; 
opt.totalSubs = {'006', '007', '008', '009', '010', '011', '013', '018', '019', '020', '021', '022', '023', '024', '027'};
% Participants: '006', '007', '008', '009', '010', '011', '013',
% '018', '019', '020', '021', '022', '023', '024', '027'

% PPI OPTIONS
% Areas to consider for the creation of VOIs: VWFA and Fedorenko's areas
opt.ppi.voiList = {'VWFAfr', 'LH_PosTemp'}; 

% Which script to consider (french, braille)
opt.ppi.script = 'french';

% Step. SPM Manual seems to do things twice: first we define one VOI and do
% PPI, and compute a GLM around it.
% Then we extract new VOIs and do other PPIs
% Step defines which, well, step we are doing at the moment. It will change
% after ppi_interactionGLM
opt.ppi.step = 1;

% we stay in native space (that of the T1)
opt.space = 'MNI'; % 'individual', 'MNI'

% description to add to folder name, to distinguish from GLM (see other
% script)
opt.desc = 'PPI';

% I like chatty outputs
opt.verbosity = 2;

% task to analyze
opt.taskName = 'visualLocalizer';

% PATHS
% The directory where the data are located
opt.dir.root = fullfile(fileparts(mfilename('fullpath')), '..', '..');

opt.dir.raw = fullfile(opt.dir.root, 'inputs', 'raw');
opt.dir.derivatives = fullfile(opt.dir.root, 'outputs', 'derivatives');
opt.dir.preproc = fullfile(opt.dir.root, 'outputs', 'derivatives', 'bidspm-preproc');
opt.dir.input = opt.dir.preproc;
opt.dir.rois = fullfile(opt.dir.root, 'outputs', 'derivatives', 'cpp_spm-rois');
opt.dir.stats = fullfile(opt.dir.root, 'outputs', 'derivatives', 'bidspm-stats');
opt.dir.cosmo = fullfile(opt.dir.root, 'outputs', 'derivatives', 'CoSMoMVPA');

% opt specific folders
opt.dir.ppi = fullfile(opt.dir.root, 'outputs', 'derivatives', 'spm-PPI');

% Suffix output directory for the saved jobs
opt.jobsDir = fullfile(opt.dir.stats, 'jobs', opt.taskName);
opt.glm.QA.do = false;

% multivariate
opt.pipeline.type = 'stats';

% The functional smoothing 
opt.fwhm.func = 6;
opt.fwhm.contrast = 0;

% Model and results options are added in the GLM scripts 
% - ppi_concatRunsAndRunGLM 
% - ppi_interactionGLM

% Model specifies all the contrasts
opt.model.file = fullfile(opt.dir.root, 'code', ...
    'models', 'model-PPI-1stLevelConcat_smdl.json');

%% DO NOT TOUCH
opt = checkOptions(opt);
saveOptions(opt);

end
