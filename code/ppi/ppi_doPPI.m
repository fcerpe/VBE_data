%% PPI - PPI analysis
%
% For each subject, create a batch to perform PPI based on the SPM.mat file
% and the VOI extracted in the previous steps of the pipeline.
%
% TO-DO (19/08/2023)
% - add figures to batch

if strcmp(opt.ppi.script, 'french'), opt.ppi.contrast = {'fw-sfw'};
else, opt.ppi.contrast = {'bw-sbw'};
end

switch opt.ppi.step
    case 1
        opt.ppi.contrast = opt.ppi.contrast;
        voiList = {'VWFAfr'};
    case 2
        opt.ppi.contrast = strsplit(opt.ppi.contrast{1},'-');
        voiList = opt.ppi.voiList;
end


for iVoi = 1:numel(voiList)

    for iCon = 1:numel(opt.ppi.contrast)

        % (16/08/2023)
        % Just manual additions hidden from sight. No generalization to
        % different contrasts, area, parrticular cases
        matlabbatch = ppi_fillBatch(opt, 'PPI', voiList{iVoi}, opt.ppi.contrast{iCon});

        % Save and run batch bidspm-style
        batchName = [subName, '_PPI-analysis_task-', char(opt.taskName), ...
                     '_space-', char(opt.space), '_FWHM-', num2str(opt.fwhm.func), 'contrast-' opt.ppi.contrast{iCon}];

        status = saveAndRunWorkflow(matlabbatch, batchName, opt, opt.thisSub);

        %% Move PPI_ file to new folder
        % from bidspm-stats/sub/node to spm-PPI/sub/PPI-analysis
        %
        % Workaround, bidsFFX overwrites a folder if not empty, so doing it sooner
        % would end up in deleted files and errors.
        % Surely there is a better way

        subName = ['sub-' opt.thisSub];

        % If destination folder does not exists, make it
        destinationPath = fullfile(opt.dir.ppi, subName, 'PPI-analysis');
        if ~exist(destinationPath)
            mkdir(destinationPath)
        end

        statsFolder = dir(fullfile(opt.dir.stats, subName, ['*ppiConcatGLM*']));
        filesToMove = dir(fullfile(statsFolder.folder, statsFolder.name,['PPI*']));
        for ftm = 1:numel(filesToMove)
            movefile(fullfile(filesToMove(ftm).folder,filesToMove(ftm).name), fullfile(destinationPath, filesToMove(ftm).name),'f');
        end
    end
end



