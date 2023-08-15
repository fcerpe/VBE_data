%% PPI - GLM analysis, design setup and estimation
% First part of the PPI analysis following SPM Manual, chapter 37
% Applied to visbra_experts data, must be adapted in case of new application
%
% For a given subject, get:
% - regressors for run-001 and run-002
% - onsets, durations, names of each event in the runs
%
% TO-DO (14/08/2023)
% - improve documentation
% - add batch editing
% - integrate with bidspm

addpath(genpath(pwd))

opt = ppi_option();

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
    runs.sess = n_scans;

    % Get the timeseries (a.k.a. motion regressors) 
    subTimeseries = dir(fullfile(opt.dir.stats, subName, 'task-visualLocalizer_space-IXI549Space_FWHM-6', ...
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
    motRegNames = names;

    % Get onsets, durations, names
    subOnsets = dir(fullfile(opt.dir.stats, subName, 'task-visualLocalizer_space-IXI549Space_FWHM-6', ...
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
                onsets{1,e} = onsets{1,e} + (runs.sess(iCon) * TR * (iCon-1)); 
                allOnsets{1,e} = cat(2, allOnsets{1,e}, onsets{1,e});
            end
        end
    end
    
    % Conditions are the same across runs, no need to concatenate anything.
    % Required variable is 'names', already provided by onsets.mat
    % SPM is picky with the names, go back to the original ones
    onsets = allOnsets;
    durations = allDurations; 
   
    % Create block regressors
    R = kron([1 0]',ones(358,1));
    R(:,2) = R(end:-1:1);
    
    % Save all the necessay .mat files to be reused
    save(fullfile(opt.dir.ppi, subName, '1stLevel-concat',[subName '_concatenated-scans-list.mat']),'runs','TR');
    save(fullfile(opt.dir.ppi, subName, '1stLevel-concat',[subName '_multi-conditions.mat']),'onsets','durations','names');
    save(fullfile(opt.dir.ppi, subName, '1stLevel-concat',[subName '_block-regressor.mat']),'R')

    % Rename variables accordingly
    R = motReg;
    names = motRegNames;
    save(fullfile(opt.dir.ppi, subName, '1stLevel-concat',[subName '_motion-regressors.mat']),'R','names');

    % Store everything in the options as well
    opt.concat = struct;
    opt.concat.onsetsFilename = fullfile(opt.dir.ppi, subName, '1stLevel-concat',[subName '_multi-conditions.mat']);
    opt.concat.runs = runs;
    opt.concat.TR = TR;
    opt.concat.motRegFilename = fullfile(opt.dir.ppi, subName, '1stLevel-concat',[subName '_motion-regressors.mat']);
    opt.concat.R = R;

% Set up batch 
% Custom method (very raw) - needs to be integrated with bidspm functions
% It's just that they are difficult to read

end

%% 


ppi_bidsFFX('specify', opt);


%% 
ppi_bidsFFX('contrasts', opt);

bidsResults(opt);


%% Remi's guidelines

% specify as usual, take batch and concatenate all
% 
%
%

bidsFFX('specify', opt);

% take the batch and modify it 

bidsFFX('estimate',opt);
