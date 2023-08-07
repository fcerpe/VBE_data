function opt = roi_option()
% returns a structure that contains the options chosen by the user to run
% createROI (extraction)

if nargin < 1
    opt = [];
end

% suject to run in each group
opt.subjects = {'006', '007', '008', '009', '010', '011', '012', '013', '018', '019', '020', '021', '022', '023', '024'}; 
% Participants: '006', '007', '008', '009', '010', '011', '012', '013', '018', '019', '020', '021', '022', '023', '024'


% ROIs to consider for the expansion intersection
% (18/07/2023) only few areas for MVPA
opt.roiList = {'VWFA-Fr', 'LOC-Left', 'LOC-Right'}; % , 'PFS-Left', 'PFS-Right'};

% Radius of the sphere around the peak
opt.radius = 10; % standard, will probably change in the individual scripts

% Number of voxels in the case of expanding ROI
opt.numVoxels = 115;

% Option to execute in vwfa split
% Can be a cell array with all the options we want
% Possible options (as of 07/08/2023)
% - 'atlas': VWFA ROI for each subject intersected with aVWFA/pVWFA
%            coordinates form visfatlas, with perVWFA adn lexVWFA from 
%            Lerma-Usabiaga et al. (2018)
% - 'individual': take each VWFA ROI and split it in anterior / posterior
%                 halves
% - 'overlap': take all the VWFA ROIs and sum them to obtain an overlap of
%              where all the areas are

opt.split = {'individual','overlap'};

% Save the ROI?
opt.saveROI = true;

% we stay in native space (that of the T1)
opt.space = 'MNI'; % 'individual', 'MNI'

% description to add to folder name, to distinguish from GLM (see other
% script)
opt.desc = 'ROI';

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

% Suffix output directory for the saved jobs
opt.jobsDir = fullfile(opt.dir.stats, 'jobs', opt.taskName);
opt.glm.QA.do = false;

% multivariate
opt.pipeline.type = 'roi';

%% DO NOT TOUCH
opt = checkOptions(opt);
saveOptions(opt);

end
