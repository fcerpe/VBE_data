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
% - move from 1 sub at the time to all of them step-by-step
%   (will need to specify paths for regressors, onsets, etc)

% Will use modified versions of bidspm functions
% can be found in ./support_scripts
addpath(genpath(pwd))

% If you're looking for opt = ppi_option(); 
% look in ppi_main. This script should ideally be called only from main, to
% ease the number of steps in a utopic ever-working pipeline
% (I know, it'll never happen)

% Works subject by subject
for iSub = 1:numel(opt.subjects)

    % Get subject number
    subName = ['sub-', num2str(opt.subjects{iSub})];
    

    % Get the runs to concatenate
    % Static script: only visualLocalizer runs 1 and 2
    subRunsDir = dir(fullfile(opt.dir.preproc, subName, 'ses-00*','func', ...
                                 [subName, '_ses-00*_task-visualLocalizer_run-00*_space-IXI549Space_desc-smth6_bold.nii']));

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

    % save in a file and as options
    save(fullfile(opt.dir.ppi, subName, '1stLevel-concat',[subName '_concatenated-scans-list.mat']),'runs');
    opt.concat.runs = runs;
    opt.concat.runs.filename = fullfile(opt.dir.ppi, subName, '1stLevel-concat',[subName '_concatenated-scans-list.mat']);


    % Get the timeseries (a.k.a. motion regressors) 
    subTimeseries = dir(fullfile(opt.dir.stats, subName, 'task-visualLocalizer_space-IXI549Space_FWHM-6_node-localizerGLM', ...
                                 [subName, '_ses-00*_task-visualLocalizer_run-00*_desc-confounds_timeseries.mat']));

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
    save(fullfile(opt.dir.ppi, subName, '1stLevel-concat',[subName '_motion-regressors.mat']),'R','names');
    opt.concat.motReg.names = names;
    opt.concat.motReg.R = R;
    opt.concat.motReg.filename = fullfile(opt.dir.ppi, subName, '1stLevel-concat',[subName '_motion-regressors.mat']);


    % Get onsets, durations, names
    subOnsets = dir(fullfile(opt.dir.stats, subName, 'task-visualLocalizer_space-IXI549Space_FWHM-6_node-localizerGLM', ...
                             [subName, '_ses-00*_task-visualLocalizer_run-00*_onsets.mat']));

    % Concatenate onsets, durations, names
    % For durations, add the number of scans (from above) times the TR
    % (fixed for now)
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
    
                % Even though the loop is suited for any number of runs, the delay is
                % only valid for the specifics of the visbra_experts localizer task
                % (358 slices with a TR = 1.75)
                % % iCon -1 is an attempt at generalization, valid if all
                % runs have the same number of scans
                onsets{1,e} = onsets{1,e} + (opt.concat.runs.nbScans(iCon) * TR * (iCon-1)); 
                allOnsets{1,e} = cat(2, allOnsets{1,e}, onsets{1,e});
            end
        end
    end
    
    % Conditions are the same across runs, no need to concatenate anything.
    % Required variable is 'names', already provided by onsets.mat
    % SPM is picky with the names, go back to the original ones
    onsets = allOnsets;
    durations = allDurations; 

    % Save in a file (necessary) and as options
    save(fullfile(opt.dir.ppi, subName, '1stLevel-concat',[subName '_multi-conditions.mat']),'onsets','durations','names');
    opt.concat.cond.filename = fullfile(opt.dir.ppi, subName, '1stLevel-concat',[subName '_multi-conditions.mat']);
    opt.concat.cond.onsets = onsets;
    opt.concat.cond.durations = durations;
    opt.concat.cond.names = names;
    opt.concat.TR = TR;
   

    % Create block regressors
    names = {'block1','block2'};
    R = kron([1 0]',ones(358,1));
    R(:,2) = R(end:-1:1);
    
    % Save as file and as options
    save(fullfile(opt.dir.ppi, subName, '1stLevel-concat',[subName '_block-regressor.mat']),'R','names');
    opt.concat.regress.filename = fullfile(opt.dir.ppi, subName, '1stLevel-concat',[subName '_block-regressor.mat']);
    opt.concat.regress.names = names;
    opt.concat.regress.R = R;

end

%% Create the GLM batches 
%
% Uses modified versions of bidsFFX, setBatchSubjectLevelGLMSpec, bidsResults
% from bidspm, until it is integrated in a proper way

ppi_bidsFFX('specifyAndEstimate', opt);

ppi_bidsFFX('contrasts', opt);

ppi_bidsResults(opt);



