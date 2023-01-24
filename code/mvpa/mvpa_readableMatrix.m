%% Readable Matrix
%
% From huge cosmomvpa output table to nice RDM-like matrices
% Valid for different sizes
% 1. divide table in struct

clear

warning('on')

% add spm to the path
addpath(fullfile(pwd, '..', 'lib', 'bidspm'));
addpath(fullfile(pwd, '..', 'lib', 'CPP_BIDS'));
bidspm;

opt = mvpa_option();

% go into derivatives/CoSMoMVPA to see how many decodings we have
filesToProcess = dir('../../outputs/derivatives/CoSMoMVPA/task-wordsDecoding_*.mat');

%%
for ftp = 1:1 % :length(filesToProcess)

    load(fullfile(filesToProcess(ftp).folder, filesToProcess(ftp).name));
    filename = filesToProcess(ftp).name;
    filename = filename(1:end-4);

    % initialize everything to avoid they get cast as something else
    mvpa_results = [];    mvpa_results = struct;    mvpa_results.raw = struct;
    mvpa_results.raw.together_VWFAfr_beta = []; mvpa_results.raw.together_VWFAfr_tmap = [];
    mvpa_results.raw.together_VWFAbr_beta = []; mvpa_results.raw.together_VWFAbr_tmap = [];
    mvpa_results.raw.together_lLO_beta = [];    mvpa_results.raw.together_lLO_tmap = [];
    mvpa_results.raw.together_lpFS_beta = [];   mvpa_results.raw.together_lpFS_tmap = [];
    mvpa_results.raw.together_rpFS_beta = [];   mvpa_results.raw.together_rpFS_tmap = [];

    avoidRLO = true;
    if not(startsWith(filename, 'task-wordsDecoding_method-anatomy-sphere'))
        avoidRLO = false;
        mvpa_results.raw.together_rLO_beta = [];    mvpa_results.raw.together_rLO_tmap = [];
    end

    % create the directory where to store figures, need to do that manually
    mkdir(fullfile(filesToProcess(ftp).folder,'figures', filename))

    % notify the user
    fprintf('\nprocessing %s \n', filename);

    % CASE 'within_script'
    %  only within language decoding
    %
    % Example:
    %       FRW FPW FNW FFS BRW BPW BNW BFS
    %   FRW  .   N   N   N   .   .   .   .
    %   FPW  N   .   N   N   .   .   .   .
    %   FNW  N   N   .   N   .   .   .   .
    %   FFS  N   N   N   .   .   .   .   .
    %   BRW  .   .   .   .   .   N   N   N
    %   BPW  .   .   .   .   N   .   N   N
    %   BNW  .   .   .   .   N   N   .   N
    %   BFS  .   .   .   .   N   N   N   .
    %
    % Make it symmetrical, make a lot of NaN where there is no decoding
    % (N is a placeholder, if you actually get it as results, it's a problem)

    % smallest unit available: one ROI, one image, one subject
    % 6 pairwise comparisons * 2 scripts
    smallestUnit = 12;

    nCond = 8;

    for i = 1:smallestUnit:size(accu,2)

        % get chunk
        thisChunk = accu(i:i+smallestUnit-1);
        % get identifiers
        thisSub = accu(i).subID;
        thisMask = accu(i).mask;
        thisImage = accu(i).image;

        % save original in corresponding variable and its chunk
        pathString = ['mvpa_results.raw.sub', thisSub, '_', thisMask, '_', thisImage];
        eval([pathString ' = thisChunk;']);

        % Modify pathString: from 'raw' to 'mat'
        pathString(14:16) = 'mat';

        % Place every accuracy from struct to NxN matrix
        mvpaMat = mvpa_getMatrix(thisChunk, 0); 
        mvpaTri = mvpa_getMatrix(thisChunk, 1); % make triangular RDM for visualization
        % save rdm
        eval([pathString ' = mvpaMat;']);

        %% show figures
        
        % notify the user
        fprintf(['\nmaking figures for sub-' thisSub ' ROI-' thisMask ' image-' thisImage '\n']);

        % create labels
        lab_mvpa = {'FRW', 'FPW', 'FNW', 'FFS', 'BRW', 'BPW', 'BNW', 'BFS'};

        % open the figure
        f = figure;        
        f.Position = [300 300 900 1000];        
        f.Visible = 'on';

        % subXXX_area_image (e.g. sub007_VWFAbr_tmap_htmp)
        name = ['sub', thisSub, '_', thisMask, '_', thisImage, '_htmp'];

        % make the actual figure, with title
        tmp_graphics = heatmap(lab_mvpa, lab_mvpa, mvpaMat, 'CellLabelColor', 'none', 'Colormap', parula, ...
            'GridVisible', 'off', 'FontSize', 30, 'ColorLimits', [0.2 1],'ColorbarVisible','off','Units','pixels','Position',[100 60 760 760])
        tmp_graphics.Title = ['sub-', thisSub, ': ', thisMask, ' (', thisImage, ')'];

        % save figure: as variable, as .fig, as .png
        eval(['mvpa_results.fig.' char(name) '= tmp_graphics;']);
        savefig(f, fullfile(opt.dir.cosmo, 'figures', filename, name)); % .fig
        saveas(f, fullfile(opt.dir.cosmo, 'figures', filename, [name,'.png'])); % .png

        % get barplot with accuracy
        % subXXX_area_image_bar
        nameBar = ['sub', thisSub, '_', thisMask, '_', thisImage, '_bar'];

        % get values, labels, and title
        barValues = [thisChunk.accuracy];
        barLabels = {'FRW-FPW','FRW-FNW','FRW-FFS','FPW-FNW','FPW-FFS','FNW-FFS','BRW-BPW','BRW-BNW','BRW-BFS','BPW-BNW','BPW-BFS','BNW-BFS'};
        barTitle = ['sub-', thisSub, ': ', thisMask, ' (', thisImage, ')'];

        % open another figure
        barFigure = figure;        barFigure.Position = [170,116,793,620];        barFigure.Visible = 'on';
        b = bar(barValues,'FaceColor','flat');
        % CPP colors: FR - [1 0.62 0.29] = orange; BR - [0.41 0.67 0.6] = sage green
        b.CData([1 2 3 4 5 6],:) = [1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29];
        b.CData([7 8 9 10 11 12],:) = [0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6];
        % axes (couldn't do it better)
        ax = gca;        ax.FontSize = 20;        ax.Units = 'pixels';
        ax.Position = [74, 134, 706, 480];        xlabel('Conditions'),
        ylabel('Accuracy'),                       ylim([0 1.1])
        xticklabels(barLabels),                   yticks([0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])

        % save figure: as variable, as .fig, as .png
        eval(['mvpa_results.fig.' nameBar '= b;']);
        savefig(barFigure, fullfile(opt.dir.cosmo, 'figures', filename, nameBar)); % .fig
        saveas(barFigure,fullfile(opt.dir.cosmo, 'figures', filename, [nameBar,'.png'])); % .png

        %% Store the single subject in the average group, according to the relative area and the image
        eval(['mvpa_results.raw.together_' thisMask '_' thisImage ' = ' ...
            'horzcat(mvpa_results.raw.together_' thisMask '_' thisImage ', thisChunk);']);

    end

    %% Get averages for area/image
    % notify the user
    fprintf('getting averages \n');

    decodingsToSample = fieldnames(mvpa_results.raw);

    for j = 1:numel(decodingsToSample)
        % split the name to identify which decoding are we working with
        thisVar = decodingsToSample{j};
        splitVar = split(thisVar,'_');
        thisSub = splitVar{1}; thisMask = splitVar{2}; thisImage = splitVar{3};

        if startsWith(thisSub, 'together') 
            eval(['currentAccuracies = [mvpa_results.raw.' decodingsToSample{j} '.accuracy];']);
            nbSubs = size(currentAccuracies,2)/12;
            currentAccuracies = reshape(currentAccuracies,12,nbSubs);
            meanAccuracies = mean(currentAccuracies,2);

            eval(['tempStruct = rmfield(mvpa_results.raw.sub006_' thisMask '_' thisImage ', "subID");']);
            for k = 1:12
                [tempStruct(k).accuracy] = deal([meanAccuracies(k)]);
            end

            eval(['mvpa_results.raw.average_' thisMask '_' thisImage ' = tempStruct;']);

            % get matrix and save it
            tempMat = mvpa_getMatrix(tempStruct, 0);
            tempMatTri = mvpa_getMatrix(tempStruct, 1);
            eval(['mvpa_results.mat.average_' thisMask '_' thisImage ' = tempMat;']);

            % get graphs and save them
            % RDM
            f = figure;
            f.Position = [300 300 900 1000]; 
            f.Visible = 'on';

            % make save name: subXXX_area_image (e.g. sub007_VWFAbr_tmap)
            name = [thisSub, '_', thisMask, '_', thisImage, '_htmp'];

            % make figure
            tmp_graphics = heatmap(lab_mvpa, lab_mvpa, tempMat, 'CellLabelColor', 'none', 'Colormap', parula, ...
            'GridVisible', 'off', 'FontSize', 30, 'ColorLimits', [0.2 1],'ColorbarVisible','off','Units','pixels','Position',[100 60 760 760])
            tmp_graphics.Title = ['mean: ', thisMask, ' (', thisImage, ')'];

            % save figure: as variable, as .fig, as .png
            eval(['mvpa_results.fig.' name ' = tmp_graphics;']);
            savefig(f, fullfile(opt.dir.cosmo, 'figures', filename, name)); % .fig
            saveas(f, fullfile(opt.dir.cosmo, 'figures', filename, [name,'.png'])); % .png

            % Barplot
            nameBar = [thisSub, '_', thisMask, '_', thisImage, '_bar'];

            barValues = [tempStruct.accuracy];
            barLabels = {'FRW-FPW','FRW-FNW','FRW-FFS','FPW-FNW','FPW-FFS','FNW-FFS', ...
                         'BRW-BPW','BRW-BNW','BRW-BFS','BPW-BNW','BPW-BFS','BNW-BFS'};
            barTitle = ['mean: ', thisMask, ' (', thisImage, ')'];

            % open another figure
            barFigure = figure;
            barFigure.Position = [170,116,793,620];
            barFigure.Visible = 'on';
            b = bar(barValues,'FaceColor','flat');
            % CPP colors to distinguish between FR and BR
            b.CData([1 2 3 4 5 6],:) = [1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29];
            b.CData([7 8 9 10 11 12],:) = [0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6];
            % axes (couldn't do it better)
            ax = gca;   ax.FontSize = 20;   ax.Units = 'pixels';    ax.Position = [74, 134, 706, 480];
            xlabel('Conditions'),           ylabel('Accuracy'),     ylim([0 1.1])
            xticklabels(barLabels),         yticks([0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])

            % save figure: as variable, as .fig, as .png
            eval(['mvpa_results.fig.' nameBar '= b;']);
            savefig(barFigure, fullfile(opt.dir.cosmo, 'figures', filename, nameBar)); % .fig
            saveas(barFigure,fullfile(opt.dir.cosmo, 'figures', filename, [nameBar,'.png'])); % .png

        end
    end

    % SAVE SET with original and modified
    save([opt.dir.cosmo, '/', filename,'.mat'],'accu','mvpa_results');

    %% make clustered figures

    figs = fieldnames(mvpa_results.mat);

    for b = 1:numel(figs)
        figsName = split(figs{b},'_');
        if startsWith(figsName{1}, 'average') % take the average single plots
            eval(['temp_' figsName{2} '_' figsName{3} ' = mvpa_results.mat.' figs{b} ';']);
        end
    end

    %% Betas
    
    % Heatmap preparation
    f = figure;    f.Position = [0 0 1512 832];    f.Visible = 'on';
    lab_mvpa = {'FRW', 'FPW', 'FNW', 'FFS', 'BRW', 'BPW', 'BNW', 'BFS'};

    % Heatmaps
    grph1 = heatmap(lab_mvpa, lab_mvpa, temp_VWFAfr_beta, 'CellLabelColor', 'none', 'Colormap', parula, 'GridVisible', 'off', 'FontSize', 15, ...
                    'ColorLimits', [0.2 1], 'ColorbarVisible','off','Units', 'pixels', 'Position',[100 450 330 330]);
    grph1.Title = ['mean: VWFAfr (beta)'];
    grph3 = heatmap(lab_mvpa, lab_mvpa, temp_lLO_beta, 'CellLabelColor', 'none', 'Colormap', parula, 'GridVisible', 'off', 'FontSize', 15, ...
                    'ColorLimits', [0.2 1], 'ColorbarVisible','off', 'Units', 'pixels', 'Position',[1100 450 330 330]);
    grph3.Title = ['mean: lLO (beta)'];
    grph4 = heatmap(lab_mvpa, lab_mvpa, temp_lpFS_beta, 'CellLabelColor', 'none', 'Colormap', parula, 'GridVisible', 'off', 'FontSize', 15, ...
                    'ColorLimits', [0.2 1], 'ColorbarVisible','off', 'Units', 'pixels', 'Position',[100 40 330 330]);
    grph4.Title = ['mean: lpFS (beta)'];
    if not(avoidRLO)
        grph5 = heatmap(lab_mvpa, lab_mvpa, temp_rLO_beta, 'CellLabelColor', 'none', 'Colormap', parula, 'GridVisible', 'off', 'FontSize', 15, ...
                        'ColorLimits', [0.2 1], 'ColorbarVisible','off', 'Units', 'pixels', 'Position',[600 40 330 330]);
        grph5.Title = ['mean: rLO (beta)'];
    end
    grph6 = heatmap(lab_mvpa, lab_mvpa, temp_rpFS_beta, 'CellLabelColor', 'none', 'Colormap', parula, 'GridVisible', 'off', 'FontSize', 15, ...
                    'ColorLimits', [0.2 1], 'ColorbarVisible','on', 'Units', 'pixels', 'Position',[1100 40 330 330]);
    grph6.Title = ['mean: rpFS (beta)'];

    % save joined plots
    mvpa_results.fig.joined_htmp_beta = f;
    savefig(f, fullfile(opt.dir.cosmo, 'figures', filename, 'joined_htmp_beta')); % .fig
    saveas(f, fullfile(opt.dir.cosmo, 'figures', filename, 'joined_htmp_beta.png')); % .png

    % barplot preparations
    f2 = figure;    f2.Position = [0, 0, 1512, 832];    f2.Visible = 'on';
    barLabels = {'FRW-FPW','FRW-FNW','FRW-FFS','FPW-FNW','FPW-FFS','FNW-FFS', 'BRW-BPW','BRW-BNW','BRW-BFS','BPW-BNW','BPW-BFS','BNW-BFS'};

    % Weird order but otherwise some are missing
    subplot(2,3,4)
    barLPFS = bar([mvpa_results.raw.average_lpFS_beta.accuracy],'FaceColor','flat');
    barLPFS.CData([1 2 3 4 5 6],:) = [1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29];
    barLPFS.CData([7 8 9 10 11 12],:) = [0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6];
    axLPFS = gca; axLPFS.FontSize = 15; axLPFS.Units = 'pixels'; axLPFS.Position = [70, 70, 400, 300];
    ylim([0 1.1]), xticklabels(barLabels), yticks([0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])
    title('mean: lpFS (beta)')

    if not(avoidRLO)
        % rLO_beta
        subplot(2,3,5)
        b5 = bar([mvpa_results.raw.average_rLO_beta.accuracy],'FaceColor','flat');
        b5.CData([1 2 3 4 5 6],:) = [1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29];
        b5.CData([7 8 9 10 11 12],:) = [0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6];
        ax5 = gca;  ax5.FontSize = 15;  ax5.Units = 'pixels';   ax5.Position = [585, 70, 400, 300];
        ylim([0 1.1]),                  xticklabels(barLabels), yticks([0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])
        title('mean: rLO (beta)')
    end

    % lLO_beta
    subplot(2,3,3)
    b3 = bar([mvpa_results.raw.average_lLO_beta.accuracy],'FaceColor','flat');
    b3.CData([1 2 3 4 5 6],:) = [1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29];
    b3.CData([7 8 9 10 11 12],:) = [0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6];
    ax3 = gca;  ax3.FontSize = 15;  ax3.Units = 'pixels';   ax3.Position = [1100, 480, 400, 300];
    ylim([0 1.1]),                  xticklabels(barLabels), yticks([0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])
    title('mean: lLO (beta)')

    % VWFAfr_beta
    subplot(2,3,1)
    b1 = bar([mvpa_results.raw.average_VWFAfr_beta.accuracy],'FaceColor','flat');
    b1.CData([1 2 3 4 5 6],:) = [1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29];
    b1.CData([7 8 9 10 11 12],:) = [0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6];
    ax1 = gca; ax1.FontSize = 15; ax1.Units = 'pixels'; ax1.Position = [70, 480, 400, 300];
    ylabel('Accuracy'), ylim([0 1.1]), xticklabels(barLabels), yticks([0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])
    title('mean: VWFAfr (beta)')

    % rpFS_beta
    subplot(2,3,6)
    b6 = bar([mvpa_results.raw.average_rpFS_beta.accuracy],'FaceColor','flat');
    b6.CData([1 2 3 4 5 6],:) = [1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29];
    b6.CData([7 8 9 10 11 12],:) = [0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6];
    ax6 = gca; ax6.FontSize = 15; ax6.Units = 'pixels'; ax6.Position = [1100, 70, 400, 300];
    ylim([0 1.1]), xticklabels(barLabels), yticks([0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])
    title('mean: rpFS (beta)')

    % save
    mvpa_results.fig.joined_bar_beta = f2;
    savefig(f2, fullfile(opt.dir.cosmo, 'figures', filename, 'joined_bar_beta')); % .fig
    saveas(f2,fullfile(opt.dir.cosmo, 'figures', filename, 'joined_bar_beta.png')); % .png

    %% Tmap

    % Heatmap preparation
    f3 = figure;    f3.Position = [0 0 1512 832];   f3.Visible = 'on';

    % heatmap tmaps
    grph7 = heatmap(lab_mvpa, lab_mvpa, temp_VWFAfr_tmap, 'CellLabelColor', 'none', 'Colormap', parula, 'GridVisible', 'off', 'FontSize', 15, ...
                    'ColorLimits', [0.2 1], 'ColorbarVisible','off','Units', 'pixels', 'Position',[100 450 330 330]);
    grph7.Title = ['mean: VWFAfr (tmap)'];
    grph9 = heatmap(lab_mvpa, lab_mvpa, temp_lLO_tmap, 'CellLabelColor', 'none', 'Colormap', parula, 'GridVisible', 'off', 'FontSize', 15, ...
                    'ColorLimits', [0.2 1], 'ColorbarVisible','off', 'Units', 'pixels', 'Position',[1100 450 330 330]);
    grph9.Title = ['mean: lLO (tmap)'];
    grph10 = heatmap(lab_mvpa, lab_mvpa, temp_lpFS_tmap, 'CellLabelColor', 'none', 'Colormap', parula, 'GridVisible', 'off', 'FontSize', 15, ...
                    'ColorLimits', [0.2 1], 'ColorbarVisible','off', 'Units', 'pixels', 'Position',[100 40 330 330]);
    grph10.Title = ['mean: lpFS (tmap)'];
    if not(avoidRLO)
        grph11 = heatmap(lab_mvpa, lab_mvpa, temp_rLO_tmap, 'CellLabelColor', 'none', 'Colormap', parula, 'GridVisible', 'off', 'FontSize', 15, ...
                        'ColorLimits', [0.2 1], 'ColorbarVisible','off', 'Units', 'pixels', 'Position',[600 40 330 330]);
        grph11.Title = ['mean: rLO (tmap)'];
    end
    grph12 = heatmap(lab_mvpa, lab_mvpa, temp_rpFS_tmap, 'CellLabelColor', 'none', 'Colormap', parula, 'GridVisible', 'off', 'FontSize', 15, ...
                    'ColorLimits', [0.2 1], 'ColorbarVisible','on', 'Units', 'pixels', 'Position',[1100 40 330 330]);
    grph12.Title = ['mean: rpFS (tmap)'];

    % save joined plots
    mvpa_results.fig.joined_htmp_tmap = f3;
    savefig(f3, fullfile(opt.dir.cosmo, 'figures', filename, 'joined_htmp_tmap')); % .fig
    saveas(f3, fullfile(opt.dir.cosmo, 'figures', filename, 'joined_htmp_tmap.png')); % .png

    % Barplot
    f4 = figure;    f4.Position = [0, 0, 1512, 832];    f4.Visible = 'on';
    barLabels = {'FRW-FPW','FRW-FNW','FRW-FFS','FPW-FNW','FPW-FFS','FNW-FFS', 'BRW-BPW','BRW-BNW','BRW-BFS','BPW-BNW','BPW-BFS','BNW-BFS'};

    % lpFS_tmap. no clue why here it works
    subplot(2,3,4)
    barRPFS = bar([mvpa_results.raw.average_lpFS_tmap.accuracy],'FaceColor','flat');
    barRPFS.CData([1 2 3 4 5 6],:) = [1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29];
    barRPFS.CData([7 8 9 10 11 12],:) = [0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6];
    axRPFS = gca; axRPFS.FontSize = 15; axRPFS.Units = 'pixels'; axRPFS.Position = [70, 70, 400, 300];
    ylim([0 1.1]), xticklabels(barLabels), yticks([0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])
    title('mean: lpFS (tmap)')

    if not(avoidRLO)
        % rLO_tmap
        subplot(2,3,5)
        b7 = bar([mvpa_results.raw.average_rLO_tmap.accuracy],'FaceColor','flat');
        b7.CData([1 2 3 4 5 6],:) = [1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29];
        b7.CData([7 8 9 10 11 12],:) = [0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6];
        ax7 = gca; ax7.FontSize = 15; ax7.Units = 'pixels'; ax7.Position = [585, 70, 400, 300];
        ylim([0 1.1]), xticklabels(barLabels), yticks([0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])
        title('mean: rLO (tmap)')
    end
    % lLO_tmap
    subplot(2,3,3)
    b8 = bar([mvpa_results.raw.average_lLO_tmap.accuracy],'FaceColor','flat');
    b8.CData([1 2 3 4 5 6],:) = [1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29];
    b8.CData([7 8 9 10 11 12],:) = [0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6];
    ax8 = gca; ax8.FontSize = 15; ax8.Units = 'pixels'; ax8.Position = [1100, 480, 400, 300];
    ylim([0 1.1]), xticklabels(barLabels), yticks([0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])
    title('mean: lLO (tmap)')

    % VWFAfr_tmap
    subplot(2,3,1)
    b9 = bar([mvpa_results.raw.average_VWFAfr_tmap.accuracy],'FaceColor','flat');
    b9.CData([1 2 3 4 5 6],:) = [1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29];
    b9.CData([7 8 9 10 11 12],:) = [0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6];
    ax9 = gca; ax9.FontSize = 15; ax9.Units = 'pixels'; ax9.Position = [70, 480, 400, 300];
    ylabel('Accuracy'), ylim([0 1.1]), xticklabels(barLabels), yticks([0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])
    title('mean: VWFAfr (tmap)')

    % rpFS_tmap
    subplot(2,3,6)
    b11 = bar([mvpa_results.raw.average_rpFS_tmap.accuracy],'FaceColor','flat');
    b11.CData([1 2 3 4 5 6],:) = [1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29];
    b11.CData([7 8 9 10 11 12],:) = [0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6];
    ax11 = gca; ax11.FontSize = 15; ax11.Units = 'pixels'; ax11.Position = [1100, 70, 400, 300];
    ylim([0 1.1]), xticklabels(barLabels), yticks([0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])
    title('mean: rpFS (tmap)')

    % save
    mvpa_results.fig.joined_bar_tmap = f4;
    savefig(f4, fullfile(opt.dir.cosmo, 'figures', filename, 'joined_bar_tmap')); % .fig
    saveas(f4,fullfile(opt.dir.cosmo, 'figures', filename, 'joined_bar_tmap.png')); % .png

    % SAVE SET with original and modified
    save([opt.dir.cosmo, '/', filename,'.mat'],'accu','mvpa_results');

end
