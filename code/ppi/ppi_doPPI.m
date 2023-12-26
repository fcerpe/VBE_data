%% PPI - PPI analysis
%
% For a given subject, create a batch to perform PPI based on the SPM.mat file
% and the VOI extracted in the previous steps of the pipeline.


for iVoi = 1:numel(voiList)

    for iCon = 1:numel(opt.ppi.contrast)

        % fillBatch manually adds all the necessary information to perform the right batch command
        % In this case, 'PPI' batch needs to be prepared, around the
        % selected VOI and for the specific contrast / condition
        matlabbatch = ppi_fillBatch(opt, 'PPI', voiList{iVoi}, opt.ppi.contrast{iCon});

        % Save the batch with a bids-like name
        batchName = [opt.subName, '_PPI-analysis_task-', char(opt.taskName), ...
                     '_space-', char(opt.space), '_FWHM-', num2str(opt.fwhm.func), 'contrast-' opt.ppi.contrast{iCon}];

        % Run it via bidspm
        status = saveAndRunWorkflow(matlabbatch, batchName, opt, opt.subjects{1});


        %% Move PPI_ file to new folder
        % from bidspm-stats/sub/node to spm-PPI/sub/PPI-analysis

        % If destination folder does not exists, make it
        destinationPath = fullfile(opt.dir.ppi, opt.subName, 'PPI-analysis');
        if ~exist(destinationPath)
            mkdir(destinationPath)
        end

        % Select folders and move files
        statsFolder = dir(fullfile(opt.dir.stats, opt.subName, ['*ppiConcatGLM*']));
        filesToMove = dir(fullfile(statsFolder.folder, statsFolder.name,['PPI*']));

        for ftm = 1:numel(filesToMove)
            movefile(fullfile(filesToMove(ftm).folder,filesToMove(ftm).name), ...
                     fullfile(destinationPath, filesToMove(ftm).name),'f');
        end
    end
end





