function opt = ppi_option()
% returns a structure that contains the options chosen by the user to run
% PPI analysis (called trhough ppi_main)

if nargin < 1
    opt = [];
end

% suject to run in each group
opt.subjects = {'006'}; 
% Participants: '006', '007', '008', '009', '010', '011', '012', '013', '018', '019', '020', '021', '022', '023', '024'

% ROIs to consider for the expansion intersection
% (18/07/2023) only few areas for MVPA
opt.roiList = {'VWFA-Fr', 'LOC-Left', 'LOC-Right'}; % , 'PFS-Left', 'PFS-Right'};

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
opt.pipeline.type = 'ppi';

% The functional smoothing 
opt.fwhm.func = 6;
opt.fwhm.contrast = 0;

% Model specifies all the contrasts
opt.model.file = fullfile(opt.dir.root, 'code', ...
    'models', 'model-PPI-1stLevelConcat_smdl.json');

%% DO NOT TOUCH
opt = checkOptions(opt);
saveOptions(opt);

end
