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
opt.pipeline.type = 'stats';

% The functional smoothing 
opt.fwhm.func = 6;
opt.fwhm.contrast = 0;

% Model specifies all the contrasts
opt.model.file = fullfile(opt.dir.root, 'code', ...
    'models', 'model-PPI-1stLevelConcat_smdl.json');

% nodeName = name of the Node in the BIDS stats model
opt.results(1).nodeName = 'subject_level';
% name of the contrast in the BIDS stats model
opt.results(1).name = {'fw-sfw'};
% Specify how you want your output (all the following are on false by default)
opt.results(1).png = true();
opt.results(1).csv = true();
opt.results(1).p = 0.001;
opt.results(1).MC = 'none';
opt.results(1).k = 0;
% those don't change across contrasts, try to put only once
opt.results(1).binary = true();
opt.results(1).montage.do = false();
opt.results(1).nidm = true();
opt.results(1).threshSpm = true();

opt.results(2).nodeName = 'subject_level';
opt.results(2).name = {'bw-sbw'};
opt.results(2).png = true();
opt.results(2).csv = true();
opt.results(2).p = 0.001;
opt.results(2).MC = 'none';
opt.results(2).k = 0;
% those don't change across contrasts, try to put only once
opt.results(2).binary = true();
opt.results(2).montage.do = false();
opt.results(2).nidm = true();
opt.results(2).threshSpm = true();

% EXTRA CONTRASTS AT DIFFERENT THRESHOLDS FOR EXPANSION
opt.results(3).nodeName = 'subject_level';
opt.results(3).name = {'fw'};
opt.results(3).png = false();   opt.results(3).csv = false();
opt.results(3).p = 0.001;       opt.results(3).MC = 'none';
opt.results(3).k = 0;
opt.results(3).binary = true(); opt.results(3).montage.do = false();
opt.results(3).nidm = true();   opt.results(3).threshSpm = true();

opt.results(4).nodeName = 'subject_level';
opt.results(4).name = {'sfw'};
opt.results(4).png = false();   opt.results(4).csv = false();
opt.results(4).p = 0.001;       opt.results(4).MC = 'none';
opt.results(4).k = 0;
opt.results(4).binary = true(); opt.results(4).montage.do = false();
opt.results(4).nidm = true();   opt.results(4).threshSpm = true();

opt.results(5).nodeName = 'subject_level';
opt.results(5).name = {'bw'};
opt.results(5).png = false();   opt.results(5).csv = false();
opt.results(5).p = 0.001;       opt.results(5).MC = 'none';
opt.results(5).k = 0;
opt.results(5).binary = true(); opt.results(5).montage.do = false();
opt.results(5).nidm = true();   opt.results(5).threshSpm = true();

opt.results(6).nodeName = 'subject_level';
opt.results(6).name = {'sbw'};
opt.results(6).png = false();   opt.results(6).csv = false();
opt.results(6).p = 0.001;       opt.results(6).MC = 'none';
opt.results(6).k = 0;
opt.results(6).binary = true(); opt.results(6).montage.do = false();
opt.results(6).nidm = true();   opt.results(6).threshSpm = true();


%% DO NOT TOUCH
opt = checkOptions(opt);
saveOptions(opt);

end
