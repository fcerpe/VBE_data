%% PPI - GLM analysis, design setup and estimation
%
% Concatenate runs, and all the necessary support files of visbra_experts
% localizer runs.
%
% For a given subject, concatenate: 
% - runs, 
% - motion regressors
% - events onsets, durations, and names 

% Will use modified versions of bidspm functions
% can be found in ./support_scripts
addpath(genpath(pwd))

% Load step-specific options 
% - stats model
% - step
opt = ppi_concatOption(opt);

% Get subject and store it in options, will be used many times throughout
% the pipeline
opt.subName = ['sub-', num2str(opt.subjects{1})];

% Get folders, to not get lost
localizerGlmPath = fullfile(opt.dir.stats, opt.subName, ...
                            ['task-',opt.taskName{1},'_space-',opt.space{1},'_FWHM-6_node-localizerGLM']);
ppiGlmPath = fullfile(opt.dir.stats, opt.subName, ...
                      ['task-',opt.taskName{1},'_space-',opt.space{1},'_FWHM-6_node-ppiConcatGLM']);
spmPpiPath = fullfile(opt.dir.ppi, opt.subName, ...
                      '1stLevelConcat');

% Get the runs
subRunsDir = dir(fullfile(opt.dir.preproc, opt.subName, 'ses-*','func', ...
                 [opt.subName,'_ses-00*_task-',opt.taskName{1},'_run-*_space-',opt.space{1}, ...
                  '_desc-smth',num2str(opt.fwhm.func),'_bold.nii']));

% Concatenate runs and save the number of scans for each runs
subRuns = {};
for iSR = 1:numel({subRunsDir.name})
 
    % Extract details from filename 
    [pth, basename, ext] = fileparts(fullfile(subRunsDir(iSR).folder, subRunsDir(iSR).name));
    new_vols = cellstr(spm_select('ExtList', pth, [basename, ext]));

    for nw = 1:numel(new_vols)
        new_vols{nw} = fullfile(subRunsDir(iSR).folder, new_vols{nw});
    end

    % Concatenate volumes and num of scans
    n_scans(iSR) = numel(new_vols);
    subRuns = cat(1, subRuns, new_vols);
end
runs.scans = subRuns;
runs.nbScans = n_scans;

% save in a file and as options. If there is no such folder, make it
if ~exist(fullfile(spmPpiPath))
    mkdir(fullfile(spmPpiPath))
end

save(fullfile(spmPpiPath,[opt.subName '_task-' opt.taskName{1} '_concatenated-scans-list.mat']),'runs');
opt.ppi.concat.runs = runs;
opt.ppi.concat.runs.filename = fullfile(spmPpiPath,[opt.subName '_task-' opt.taskName{1} '_concatenated-scans-list.mat']);


% Get the timeseries (a.k.a. motion regressors) 
subTimeseries = dir(fullfile(localizerGlmPath, ...
                             [opt.subName, '_ses-*_task-',opt.taskName{1},'_run-*_desc-confounds_timeseries.mat']));

% Concatenate timeseries 
% Redundant, but it allows to save the motion regressors names
% (they'll be overwritten by 'names' of the conditions)
motReg = {};
for iMR = 1:numel({subTimeseries.name})

    % load the motion regressors: names and R
    load(fullfile(subTimeseries(iMR).folder, subTimeseries(iMR).name));  

    if isempty(motReg)
    motReg = R;
    else
        motReg = cat(1, motReg, R);
    end
end

% Rename variables to SPM-firendly names 
R = motReg;

% Save them as both file and options
save(fullfile(spmPpiPath,[opt.subName '_task-' opt.taskName{1} '_motion-regressors.mat']),'R','names');
opt.ppi.concat.motReg.names = names;
opt.ppi.concat.motReg.R = R;
opt.ppi.concat.motReg.filename = fullfile(spmPpiPath, ...
                                          [opt.subName '_task-' opt.taskName{1} '_motion-regressors.mat']);


% Get onsets, durations, names
subOnsets = dir(fullfile(localizerGlmPath, ...
                         [opt.subName, '_ses-*_task-',opt.taskName{1},'_run-*_onsets.mat']));

% Concatenate onsets, durations, names
% TR is fixed, could not pinpoint it in opt
TR = 1.75;
allDurations = {};
allOnsets = {};

for iCon = 1:numel({subOnsets.name})

    % load onsets, durations, names of events
    load(fullfile(subOnsets(iCon).folder, subOnsets(iCon).name));
    
    if isempty(allDurations)
        allDurations = durations;
        allOnsets = onsets; 
    else
        % Conditions and onsets are already ordered, can be easily concatenated 
        for e = 1:size(durations,2)
            allDurations{1,e} = cat(2, allDurations{1,e}, durations{1,e});

            % Loop accomodates any number of runs, delay is valid only for 
            % 358 slices with a TR = 1.75
            onsets{1,e} = onsets{1,e} + (opt.ppi.concat.runs.nbScans(iCon) * TR * (iCon-1)); 
            allOnsets{1,e} = cat(2, allOnsets{1,e}, onsets{1,e});
        end
    end
end

% Conditions are the same across runs, no need to concatenate anything.
% Required variable is 'names', already provided by onsets.mat
onsets = allOnsets;
durations = allDurations;

% Save in a file (necessary) and as options
save(fullfile(spmPpiPath,[opt.subName '_task-' opt.taskName{1} '_multi-conditions.mat']), ...
              'onsets','durations','names');
opt.ppi.concat.cond.filename = fullfile(spmPpiPath,[opt.subName '_task-' opt.taskName{1} '_multi-conditions.mat']);
opt.ppi.concat.cond.onsets = onsets;
opt.ppi.concat.cond.durations = durations;
opt.ppi.concat.cond.names = names;
opt.ppi.concat.TR = TR;


% Create block regressors
% Static code, only viable for 2 runs
names = {'block1'};
R = vertcat(ones(n_scans(1),1), zeros(n_scans(2),1));

% Save as file and as options
save(fullfile(spmPpiPath,[opt.subName '_task-' opt.taskName{1} '_block-regressor.mat']),'R','names');
opt.ppi.concat.regress.filename = fullfile(spmPpiPath, ...
                                           [opt.subName '_task-' opt.taskName{1} '_block-regressor.mat']);
opt.ppi.concat.regress.names = names;
opt.ppi.concat.regress.R = R;


%% Create the GLM batches
% Uses modified versions of bidsFFX, setBatchSubjectLevelGLMSpec, bidsResults
% from bidspm, until it is integrated in a proper way
ppi_bidsFFX('specifyAndEstimate', opt);

ppi_bidsFFX('contrasts', opt);

ppi_bidsResults(opt);


%% Copy .mat and .tsv files
% from spm-PPI/sub/1stLevelConcat to bidspm-stats/sub/node
filesToMove = dir(fullfile(spmPpiPath,'sub-*'));

for ftm = 1:numel(filesToMove)
    copyfile(fullfile(filesToMove(ftm).folder,filesToMove(ftm).name), ...
             fullfile(ppiGlmPath,filesToMove(ftm).name),'f');
end




%% Step-specific options

function opt = ppi_concatOption(opt)  

% if there is already a model and results information, delete them to avoid
% overlapping
opt.model = [];
opt.results = [];

% Specify the GLM step we are performing, to add the correct regressors
opt.ppi.step = 1;

% Model specifies all the contrasts
opt.model.file = fullfile(opt.dir.root, 'code', ...
    'models', 'model-PPI-1stLevelConcat-localizer_smdl.json');

% nodeName = name of the Node in the BIDS stats model
opt.results(1).nodeName = 'subject_level';
% name of the contrast in the BIDS stats model
opt.results(1).name = {'fw-sfw'};
% Specify how you want your output (all the following are on false by default)
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

opt.results(3).nodeName = 'subject_level';
opt.results(3).name = {'fw-sfw'};
opt.results(3).png = false();   opt.results(3).csv = false();
opt.results(3).p = 0.01;        opt.results(3).MC = 'none';
opt.results(3).k = 0;
opt.results(3).binary = true(); opt.results(3).montage.do = false();
opt.results(3).nidm = true();   opt.results(3).threshSpm = true();

opt.results(4).nodeName = 'subject_level';
opt.results(4).name = {'fw-sfw'};
opt.results(4).png = false();   opt.results(4).csv = false();
opt.results(4).p = 0.05;        opt.results(4).MC = 'none';
opt.results(4).k = 0;
opt.results(4).binary = true(); opt.results(4).montage.do = false();
opt.results(4).nidm = true();   opt.results(4).threshSpm = true();

opt.results(5).nodeName = 'subject_level';
opt.results(5).name = {'bw-sbw'};
opt.results(5).png = false();   opt.results(5).csv = false();
opt.results(5).p = 0.01;        opt.results(5).MC = 'none';
opt.results(5).k = 0;
opt.results(5).binary = true(); opt.results(5).montage.do = false();
opt.results(5).nidm = true();   opt.results(5).threshSpm = true();

opt.results(6).nodeName = 'subject_level';
opt.results(6).name = {'bw-sbw'};
opt.results(6).png = false();   opt.results(6).csv = false();
opt.results(6).p = 0.05;        opt.results(6).MC = 'none';
opt.results(6).k = 0;
opt.results(6).binary = true(); opt.results(6).montage.do = false();
opt.results(6).nidm = true();   opt.results(6).threshSpm = true();


% Standard bidspm checks
opt = checkOptions(opt);
saveOptions(opt);

end

