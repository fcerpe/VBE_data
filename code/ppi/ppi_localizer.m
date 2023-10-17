%% Step by step, follow the manual instructions

for iSub = 1:numel(opt.subjects)

    opt.thisSub = opt.subjects{iSub};

    % Concatenate runs, onsets, durations, motion regressors
    % and save all the outputs in opt.
    % Then, run GLM on the concatenated run
    ppi_concatRunsAndRunGLM;

    % Extract the first VOI to compute interactions
    % First time it only does so in the first area (VWFA)
    % and for the whole contrast (e.g. FW-SFW)
    ppi_extractVOIs;

    % Based on the VOI extracted, perform and visualize the interactions
    ppi_doPPI;

    % Run GLM using the PPI-interaction
    ppi_interactionGLM;

    % Extract VOIs for each area we are interested in
    ppi_extractVOIs;

    % Compute interactions with all the areas, 
    % for all stimuli (FW, SFW, BW, SBW) and all groups
    scripts = {'french','braille'};
    for iScript = 1:numel(scripts)

        opt.ppi.script = scripts{iScript};
        ppi_doPPI;

    end

end

% Visualize the results (on matlab)
ppi_visualizeInteractions;