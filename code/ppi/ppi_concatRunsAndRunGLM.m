%% PPI - GLM analysis, design setup and estimation
%
% Concatenate runs, and all the necessary support files of visbra_experts
% localizer runs.
%
% For a given subject, get:
% - regressors for run-001 and run-002
% - onsets, durations, names of each event in the runs
%
% TO-DO (15/08/2023)
% - extend to other subjects

% Will use modified versions of bidspm functions
% can be found in ./support_scripts
addpath(genpath(pwd))

% Take the options from ppi_main call for ppi_option()
% Add specific settings for the current stats model 
opt = ppi_concatOption(opt);

    % Get subject number
    subName = ['sub-' opt.thisSub];
    
    % Get folders, to not get lost
    folderGlmPath = fullfile(opt.dir.stats, subName, ...
        ['task-' opt.taskName{1} '_space-IXI549Space_FWHM-' num2str(opt.fwhm.func) '_node-' opt.ppi.dataset 'GLM']);
    ppiGlmPath = fullfile(opt.dir.stats, subName, ...
        ['task-' opt.taskName{1} '_space-IXI549Space_FWHM-' num2str(opt.fwhm.func) '_node-ppiConcatGLM']);            
    spmPpiPath = fullfile(opt.dir.ppi, subName, ['1stLevelConcat_' opt.ppi.dataset]);

    % Get the runs to concatenate
    subRunsDir = dir(fullfile(opt.dir.preproc, subName, 'ses-0*','func', [subName, '_ses-0*_task-' opt.taskName{1}, '_run-0*_space-IXI549Space_desc-smth*_bold.nii']));

    % Concatenate runs and save the number of scans for each runs
    subRuns = {};
    for iSR = 1:numel({subRunsDir.name})
        [pth, basename, ext] = fileparts(fullfile(subRunsDir(iSR).folder, subRunsDir(iSR).name));
        new_vols = cellstr(spm_select('ExtList', pth, [basename, ext]));
        for nw = 1:numel(new_vols)
            new_vols{nw} = fullfile(subRunsDir(iSR).folder, new_vols{nw});
        end
        n_scans(iSR) = numel(new_vols);
        subRuns = cat(1, subRuns, new_vols);
    end
    runs.scans = subRuns;
    runs.nbScans = n_scans;

    % save in a file and as options. If there is no such folder, make it
    if ~exist(fullfile(spmPpiPath))
        mkdir(fullfile(spmPpiPath))
    end

    save(fullfile(spmPpiPath,[subName '_task-' opt.taskName{1} '_concatenated-scans-list.mat']),'runs');
    opt.ppi.concat.runs = runs;
    opt.ppi.concat.runs.filename = fullfile(spmPpiPath,[subName '_task-' opt.taskName{1} '_concatenated-scans-list.mat']);


    % Get the timeseries (a.k.a. motion regressors) 
    subTimeseries = dir(fullfile(folderGlmPath, ...
                                 [subName, '_ses-00*_task-' opt.taskName{1} '_run-0*_desc-confounds_timeseries.mat']));

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
    save(fullfile(spmPpiPath,[subName '_task-' opt.taskName{1} '_motion-regressors.mat']),'R','names');
    opt.ppi.concat.motReg.names = names;
    opt.ppi.concat.motReg.R = R;
    opt.ppi.concat.motReg.filename = fullfile(spmPpiPath,[subName '_task-' opt.taskName{1} '_motion-regressors.mat']);


    % Get onsets, durations, names
    subOnsets = dir(fullfile(folderGlmPath, ...
                             [subName, '_ses-00*_task-' opt.taskName{1} '_run-0*_onsets.mat']));

    % Concatenate onsets, durations, names
    % For durations, add the number of scans (from above) times the TR
    % (fixed for now)
    TR = 1.75;
    allDurations = {};
    allOnsets = {};

    for iCon = 1:numel({subOnsets.name})
        % load onsets, durations, names of events
        load(fullfile(subOnsets(iCon).folder, subOnsets(iCon).name));

        if iCon == 1
            switch opt.ppi.dataset
                case 'mvpa'
                    allConditions = {'frw','fpw','fnw','ffs','brw','bpw','bnw','bfs'};
                    for f = 1:size(durations,2)
                        whereIdx = find(strcmp(names{1,f},allConditions));
                        allDurations{1,whereIdx} = durations{1,f};
                        allOnsets{1,whereIdx} = onsets{1,f};
                    end

                    if whereIdx == 4 % french
                        allDurations{1,5} = zeros(1,12); allOnsets{1,5} = zeros(1,12);
                        allDurations{1,6} = zeros(1,12); allOnsets{1,6} = zeros(1,12);
                        allDurations{1,7} = zeros(1,12); allOnsets{1,7} = zeros(1,12);
                        allDurations{1,8} = zeros(1,12); allOnsets{1,8} = zeros(1,12);
                    else
                        allDurations{1,1} = zeros(1,12); allOnsets{1,1} = zeros(1,12);
                        allDurations{1,2} = zeros(1,12); allOnsets{1,2} = zeros(1,12);
                        allDurations{1,3} = zeros(1,12); allOnsets{1,3} = zeros(1,12);
                        allDurations{1,4} = zeros(1,12); allOnsets{1,4} = zeros(1,12);
                    end
            end
        else
            % Conditions and onsets are already ordered, can be easily concatenated
            for e = 1:size(durations,2)
                switch opt.ppi.dataset
                    case 'mvpa'
                        whereIdx = find(strcmp(names{1,e},allConditions));
                        allDurations{1,whereIdx} = cat(2, allDurations{1,whereIdx}, durations{1,e});

                        onsets{1,e} = onsets{1,e} + (sum(n_scans(1:iCon-1)) * TR);
                        allOnsets{1,whereIdx} = cat(2, allOnsets{1,whereIdx}, onsets{1,e});

                        if ismember(whereIdx, [1 2 3 4]) % french
                            allDurations{1,whereIdx+4} = cat(2, allDurations{1,whereIdx+4}, zeros(1,12));
                            allOnsets{1,whereIdx+4} = cat(2, allOnsets{1,whereIdx+4}, zeros(1,12));
                        else
                            allDurations{1,whereIdx-4} = cat(2, allDurations{1,whereIdx-4}, zeros(1,12));
                            allOnsets{1,whereIdx-4} = cat(2, allOnsets{1,whereIdx-4}, zeros(1,12));
                        end

                    case 'localizer'
                        allDurations{1,e} = cat(2, allDurations{1,e}, durations{1,e});
                        % Even though the loop is suited for any number of runs, the delay is
                        % only valid for the specifics of the visbra_experts localizer task
                        % (358 slices with a TR = 1.75)
                        onsets{1,e} = onsets{1,e} + (n_scans(iCon) * TR + lastOnset + lastDuration);
                        allOnsets{1,e} = cat(2, allOnsets{1,e}, onsets{1,e});
                end
            end  
        end

        [lastOnset, pos] = max([onsets{:}]);
        % bad code to find a position
        switch pos
            case {1,2,3,4,5,6,7,8,9,10,11,12},          posDur = 1;
            case {13,14,15,16,17,18,19,20,21,22,23,24}, posDur = 2;
            case {25,26,27,28,29,30,31,32,33,34,35,36}, posDur = 3;
            case {37,38,39,40,41,42,43,44,45,46,47,48}, posDur = 4;
        end
        lastDuration = durations{posDur}(pos-(12*(posDur-1)));
    end
    
    % Conditions are the same across runs, no need to concatenate anything.
    % Required variable is 'names', already provided by onsets.mat
    % SPM is picky with the names, go back to the original ones
    onsets = allOnsets;
    durations = allDurations; 
    names = unique(allConditions);

    % Save in a file (necessary) and as options
    save(fullfile(spmPpiPath,[subName '_task-' opt.taskName{1} '_multi-conditions.mat']),'onsets','durations','names');
    opt.ppi.concat.cond.filename = fullfile(spmPpiPath,[subName '_task-' opt.taskName{1} '_multi-conditions.mat']);
    opt.ppi.concat.cond.onsets = onsets;
    opt.ppi.concat.cond.durations = durations;
    opt.ppi.concat.cond.names = conditions;
    opt.ppi.concat.TR = TR;
   

    % Create block regressors
    names = {'block1', 'block2', 'block3', 'block4',  'block5',  'block6', ... 
             'block7', 'block8', 'block9', 'block10', 'block11', 'block12'};

    % Complicated part if you do it with 12 runs
    if size(n_scans,2) ~= 0
        R = zeros(sum(n_scans),size(n_scans,2));

        for iRun = 1:size(n_scans,2)

            % how many scans were done before?
            if iRun == 1, prev = 0;
            else, prev = sum(n_scans(1:iRun-1));
            end

            R(prev+1:prev+n_scans(iRun), iRun) = 1;
        end
    else
        % localizer case: we can use only 1 column
        R = vertcat(ones(n_scans(1),1), zeros(n_scans(2),1));
    end

    % Save as file and as options
    save(fullfile(spmPpiPath,[subName '_task-' opt.taskName{1} '_block-regressor.mat']),'R','names');
    opt.ppi.concat.regress.filename = fullfile(spmPpiPath,[subName '_task-' opt.taskName{1} '_block-regressor.mat']);
    opt.ppi.concat.regress.names = names;
    opt.ppi.concat.regress.R = R;


%% Create the GLM batches
%
% Uses modified versions of bidsFFX, setBatchSubjectLevelGLMSpec, bidsResults
% from bidspm, until it is integrated in a proper way

% Cheap hack: bidspm functions automatically run through all the subjects
% in 'opt.subjects'. 
% temporarily modify that variable to trick them into running only one
% subject

ppi_bidsFFX('specifyAndEstimate', opt);

ppi_bidsFFX('contrasts', opt);

ppi_bidsResults(opt);

%% Copy .mat and .tsv files
% from spm-PPI/sub/1stLevelConcat to bidspm-stats/sub/node
%
% Workaround, bidsFFX overwrites a folder if not empty, so doing it sooner
% would end up in deleted files and errors.
% Surely there is a better way

filesToMove = dir(fullfile(spmPpiPath,'sub-*'));
for ftm = 1:numel(filesToMove)
    copyfile(fullfile(filesToMove(ftm).folder,filesToMove(ftm).name), fullfile(ppiGlmPath,filesToMove(ftm).name),'f');
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
    'models', ['model-PPI-1stLevelConcat-' opt.ppi.dataset '_smdl.json']);

switch opt.ppi.dataset

    case 'localizer'
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


    case 'mvpa'
        opt.results(1).nodeName = 'subject_level';
        opt.results(1).name = {'frw-ffs'};
        opt.results(1).png = false();   opt.results(1).csv = false();
        opt.results(1).p = 0.001;       opt.results(1).MC = 'none';
        opt.results(1).k = 0;
        opt.results(1).binary = true(); opt.results(1).montage.do = false();
        opt.results(1).nidm = true();   opt.results(1).threshSpm = true(); 

        opt.results(2).nodeName = 'subject_level';
        opt.results(2).name = {'frw-ffs'};
        opt.results(2).png = false();   opt.results(2).csv = false();
        opt.results(2).p = 0.05;        opt.results(2).MC = 'none';
        opt.results(2).k = 0;
        opt.results(2).binary = true(); opt.results(2).montage.do = false();
        opt.results(2).nidm = true();   opt.results(2).threshSpm = true(); 

        opt.results(3).nodeName = 'subject_level';
        opt.results(3).name = {'frw-ffs'};
        opt.results(3).png = false();   opt.results(3).csv = false();
        opt.results(3).p = 0.05;        opt.results(3).MC = 'none';
        opt.results(3).k = 0;
        opt.results(3).binary = true(); opt.results(3).montage.do = false();
        opt.results(3).nidm = true();   opt.results(3).threshSpm = true(); 

end

%% DO NOT TOUCH
opt = checkOptions(opt);
saveOptions(opt);

end

