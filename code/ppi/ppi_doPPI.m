%% PPI - PPI analysis
%
% For each subject, create a batch to perform PPI based on the SPM.mat file
% and the VOI extracted in the previous steps of the pipeline.
%
% TO-DO (19/08/2023)
% - add figures to batch

switch opt.ppi.step
    case 1
        voiList = {'VWFAfr'};
    case 2
        voiList = opt.ppi.voiList;
end


for iSub = 1:numel(opt.subjects)

    for iVoi = 1:numel(voiList)

        for iCon = 1:numel(opt.ppi.contrast)

            % (16/08/2023)
            % Just manual additions hidden from sight. No generalization to
            % different contrasts, area, parrticular cases
            matlabbatch = ppi_fillBatch(opt, iSub, 'PPI', voiList{iVoi}, opt.ppi.contrast{iCon});

            % Save and run batch bidspm-style
            batchName = [subName, '_PPI-analysis_task-', char(opt.taskName), ...
                         '_space-', char(opt.space), '_FWHM-', num2str(opt.fwhm.func), 'contrast-' opt.ppi.contrast{iCon}];

            status = saveAndRunWorkflow(matlabbatch, batchName, opt, opt.subjects{iSub});

            %% Move PPI_ file to new folder
            % from bidspm-stats/sub/node to spm-PPI/sub/PPI-analysis
            %
            % Workaround, bidsFFX overwrites a folder if not empty, so doing it sooner
            % would end up in deleted files and errors.
            % Surely there is a better way

            subName = ['sub-' opt.subjects{iSub}];

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
end


