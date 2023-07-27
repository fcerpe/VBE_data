
subs = {'006', '007', '008', '009', '010', '011', '012', '013', '017', '018', '019', '020', '021', '022'};

res = struct;

for i = 1:numel(subs)

this = struct;

% Load the niis
if strcmp(subs{i},'012') || strcmp(subs{i},'013')
    this.hRaw = spm_vol(['../inputs/raw/sub-', subs{i}, '/ses-002/func/sub-', subs{i}, '_ses-002_task-visualLocalizer_run-001_bold.nii']);
    this.hPre = spm_vol(['../outputs/derivatives/bidspm-preproc/sub-', subs{i}, '/ses-002/func/sub-', subs{i}, '_ses-002_task-visualLocalizer_run-001_space-IXI549Space_desc-preproc_bold.nii.gz']);

else
    this.hRaw = spm_vol(['../inputs/raw/sub-', subs{i}, '/ses-001/func/sub-', subs{i}, '_ses-001_task-visualLocalizer_run-001_bold.nii']);
    this.hPre = spm_vol(['../outputs/derivatives/bidspm-preproc/sub-', subs{i}, '/ses-001/func/sub-', subs{i}, '_ses-001_task-visualLocalizer_run-001_space-IXI549Space_desc-preproc_bold.nii.gz']);
end

% Load the niis
% this.hFmri = spm_vol(['../outputs/derivatives/fmriprep/sub-', subs{i}, '/ses-001/func/sub-', subs{i}, '_ses-001_task-visualLocalizer_run-1_space-MNI152NLin2009cAsym_boldref.nii']);
% this.hStatsPrep = spm_vol(['../outputs/derivatives/bidspm-stats/sub-', subs{i}, '/task-visualLocalizer_space-MNI152NLin2009cAsym_FWHM-6/beta_0001.nii']);
this.hStatsBids = spm_vol(['../outputs/derivatives/bidspm-stats/sub-', subs{i}, '/task-visualLocalizer_space-IXI549Space_FWHM-6/beta_0001.nii']);

this.raw_res = [this.hRaw(1).mat(1,1) this.hRaw(1).mat(2,2) this.hRaw(1).mat(3,3)];
this.preproc_res = [this.hPre(1).mat(1,1) this.hPre(1).mat(2,2) this.hPre(1).mat(3,3)];
% this.fmriprep_res = [this.hFmri.mat(1,1) this.hFmri.mat(2,2) this.hFmri.mat(3,3)];
this.stBids_res = [this.hStatsBids.mat(1,1) this.hStatsBids.mat(2,2) this.hStatsBids.mat(3,3)];
% this.stFmriprep_res = [this.hStatsPrep.mat(1,1) this.hStatsPrep.mat(2,2) this.hStatsPrep.mat(3,3)];

eval(['res.s' subs{i} ' = this;']);

disp(['sub-', subs{i}]);
disp([]);
this

end