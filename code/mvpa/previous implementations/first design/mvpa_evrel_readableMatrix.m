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

opt = mvpa_evrel_option();

load(fullfile(opt.dir.cosmo, 'task-visualEventRelated_method-individual-sphere-8mm_condition-all_nbvoxels-50.mat'));
filename = 'task-visualEventRelated_method-individual-sphere-8mm_condition-all_nbvoxels-50';

mvpa_results = [];
mvpa_results = struct ;
mvpa_results.raw = struct;
mvpa_results.raw.together_VWFAfr_beta = []; 
mvpa_results.raw.together_lLO_beta = [];    
mvpa_results.raw.together_lpFS_beta = [];  
mvpa_results.raw.together_rLO_beta = [];  
mvpa_results.raw.together_rpFS_beta = [];  

% create the directory where to store figures, need to do that manually
mkdir(fullfile(opt.dir.cosmo,'figures',filename))

% CASE 'all'
%
% Make it symmetrical, make a lot of NaN where there is no decoding
% (N is a placeholder, if you actually get it as results, it's a problem)

% smallest unit available: one ROI, one image, one subject
% 6 pairwise comparisons * 2 scripts
smallestUnit = 120;

nCond = 16;

for i = 1:smallestUnit:size(accu,2)
    % get chunk
    thisChunk = accu(i:i+smallestUnit-1);

    thisSub = accu(i).subID;
    thisMask = accu(i).mask;

    % save original in corresponding variable
    pathString = ['mvpa_results.raw.sub', thisSub, '_', thisMask '_beta'];

    %save chunk in the right struct place
    eval([pathString ' = thisChunk;']);

    % Modify pathString: from 'raw' to 'mat'
    pathString(14:16) = 'mat';

    % Place every accuracy from struct to NxN matrix
    mvpaMat = mvpa_evrel_getMatrix(thisChunk); % only works with a 8*8 matrix

    eval([pathString ' = mvpaMat;']);

    % show figure as heatmap

    fprintf('\nmaking figures \n');

    % labels
    lab_mvpa = {'fr-balcon', 'fr-vallon', 'fr-cochon', 'fr-faucon', ...
                'fr-chalet', 'fr-sommet', 'fr-poulet', 'fr-roquet', ...
                'br-balcon', 'br-vallon', 'br-cochon', 'br-faucon', ...
                'br-chalet', 'br-sommet', 'br-poulet', 'br-roquet'};

    % start making the figure
    f = figure;
    f.Position = [300 300 890 850];
    f.Visible = 'on';

    % make save name: subXXX_area_image (e.g. sub007_VWFAbr_tmap)
    name = ['sub', thisSub, '_', thisMask, '_beta_htmp'];

    % make figure
    tmp_graphics = heatmap(lab_mvpa, lab_mvpa, mvpaMat, ...
        'CellLabelColor', 'none', ...
        'Colormap', parula, ...
        'GridVisible', 'off', ...
        'FontSize', 20, ...
        'ColorLimits', [0.2 1], ...
        'Units', 'pixels', ...
        'Position',[110 100 670 670]);

    tmp_graphics.Title = ['sub-', thisSub, ': ', thisMask, ' (beta)'];

    % save figure: as variable, as .fig, as .png
    eval(['mvpa_results.fig.' char(name) '= tmp_graphics;']);
    savefig(f, fullfile(opt.dir.cosmo, 'figures', filename, name)); % .fig
    saveas(f, fullfile(opt.dir.cosmo, 'figures', filename, [name,'.png'])); % .png

    % Store the single subject in the right average group, according to the relative area and the image

    eval(['mvpa_results.raw.together_' thisMask '_beta = ' ...
        'horzcat(mvpa_results.raw.together_' thisMask '_beta, thisChunk);']);

end

% Get averages for area/image

fprintf('getting averages \n');

decods = fieldnames(mvpa_results.raw);

for j = 1:numel(decods)
    thisVar = decods{j};
    splitVar = split(thisVar,'_');
    currSub = splitVar{1}; currMask = splitVar{2}; 

    if startsWith(currSub, 'together')
        eval(['currentAccuracies = [mvpa_results.raw.' decods{j} '.accuracy];']);
        nbSubs = size(currentAccuracies,2)/smallestUnit;
        currentAccuracies = reshape(currentAccuracies,smallestUnit,nbSubs);
        meanAccuracies = mean(currentAccuracies,2);

        eval(['temp_struct = rmfield(mvpa_results.raw.sub001_' currMask '_beta, "subID");']);
        for k = 1:smallestUnit
            [temp_struct(k).accuracy] = deal([meanAccuracies(k)]);
        end

        eval(['mvpa_results.raw.average_' currMask '_beta = temp_struct;']);
    end
end

% Get matrices and figures

decods = fieldnames(mvpa_results.raw);

for m = 1:numel(decods)
    if startsWith(decods{m}, 'average')

        % get name parts
        thisVar = decods{m};
        splitVar = split(thisVar,'_');
        thisSub = 'mean'; thisMask = splitVar{2}; 

        % get average stuct
        eval(['tempAverage = [mvpa_results.raw.' decods{m} '];']);

        % get matrix and save it
        tempMat = mvpa_evrel_getMatrix(tempAverage);
        eval(['mvpa_results.mat. ' decods{m} ' = tempMat;']);

        % get graphs and save them
        % RDM
        f = figure;
        f.Position = [300 300 890 850];
        f.Visible = 'on';

        % make save name: subXXX_area_image (e.g. sub007_VWFAbr_tmap)
        name = [thisSub, '_', thisMask, '_beta_htmp'];

        % make figure
        tmp_graphics = heatmap(lab_mvpa, lab_mvpa, tempMat, 'CellLabelColor', 'none', 'Colormap', parula, ...
            'GridVisible', 'off', 'FontSize', 20, 'ColorLimits', [0.2 1], 'Units', 'pixels', 'Position',[110 100 670 670]);
        tmp_graphics.Title = [thisSub, ': ', thisMask, ' (beta)'];

        % save figure: as variable, as .fig, as .png
        eval(['mvpa_results.fig.' name ' = tmp_graphics;']);
        savefig(f, fullfile(opt.dir.cosmo, 'figures', filename, name)); % .fig
        saveas(f, fullfile(opt.dir.cosmo, 'figures', filename, [name,'.png'])); % .png

    end
end

% SAVE SET with original and modified
save([opt.dir.cosmo, '/', filename,'.mat'],'accu','mvpa_results');


%% RE-LOAD MAT FILES TO MAKE JOINED IMAGES

opt = mvpa_option();

% go into derivatives/CoSMoMVPA to see how many decodings we have
filesToProcess = dir('../../outputs/derivatives/CoSMoMVPA/task-wordsDecoding_*.mat');

%
for ftp = 2:2 %length(filesToProcess)

    load(fullfile(filesToProcess(ftp).folder, filesToProcess(ftp).name));
    filename = filesToProcess(ftp).name;
    filename = filename(1:end-4);


    % MAKE CLUSTER FIGURES

    figs = fieldnames(mvpa_results.mat);

    for b = 1:numel(figs)

        figsName = split(figs{b},'_');

        if startsWith(figsName{1}, 'average')
            eval(['temp_' figsName{2} '_' figsName{3} ' = mvpa_results.mat.' figs{b} ';']);

        end
    end

    % betas

    f = figure;
    f.Position = [0 0 1512 832];
    f.Visible = 'on';

    lab_mvpa = {'FRW', 'FPW', 'FNW', 'FFS', 'BRW', 'BPW', 'BNW', 'BFS'};

    % heatmap beta
    grph1 = heatmap(lab_mvpa, lab_mvpa, temp_VWFAfr_beta, 'CellLabelColor', 'none', 'Colormap', parula, 'GridVisible', 'off', 'FontSize', 15, ...
        'ColorLimits', [0.2 1], 'ColorbarVisible','off','Units', 'pixels', 'Position',[100 450 330 330]);
    grph1.Title = ['mean: VWFAfr (beta)'];
    grph2 = heatmap(lab_mvpa, lab_mvpa, temp_VWFAbr_beta, 'CellLabelColor', 'none', 'Colormap', parula, 'GridVisible', 'off', 'FontSize', 15, ...
        'ColorLimits', [0.2 1], 'ColorbarVisible','off', 'Units', 'pixels', 'Position',[600 450 330 330]);
    grph2.Title = ['mean: VWFAbr (beta)'];
    grph3 = heatmap(lab_mvpa, lab_mvpa, temp_lLO_beta, 'CellLabelColor', 'none', 'Colormap', parula, 'GridVisible', 'off', 'FontSize', 15, ...
        'ColorLimits', [0.2 1], 'ColorbarVisible','off', 'Units', 'pixels', 'Position',[1100 450 330 330]);
    grph3.Title = ['mean: lLO (beta)'];
    grph4 = heatmap(lab_mvpa, lab_mvpa, temp_lpFS_beta, 'CellLabelColor', 'none', 'Colormap', parula, 'GridVisible', 'off', 'FontSize', 15, ...
        'ColorLimits', [0.2 1], 'ColorbarVisible','off', 'Units', 'pixels', 'Position',[100 40 330 330]);
    grph4.Title = ['mean: lpFS (beta)'];
    grph5 = heatmap(lab_mvpa, lab_mvpa, temp_rLO_beta, 'CellLabelColor', 'none', 'Colormap', parula, 'GridVisible', 'off', 'FontSize', 15, ...
        'ColorLimits', [0.2 1], 'ColorbarVisible','off', 'Units', 'pixels', 'Position',[600 40 330 330]);
    grph5.Title = ['mean: rLO (beta)'];
    grph6 = heatmap(lab_mvpa, lab_mvpa, temp_rpFS_beta, 'CellLabelColor', 'none', 'Colormap', parula, 'GridVisible', 'off', 'FontSize', 15, ...
        'ColorLimits', [0.2 1], 'ColorbarVisible','on', 'Units', 'pixels', 'Position',[1100 40 330 330]);
    grph6.Title = ['mean: rpFS (beta)'];

    % save joined plots
    mvpa_results.fig.joined_htmp_beta = f;
    savefig(f, fullfile(opt.dir.cosmo, 'figures', filename, 'joined_htmp_beta')); % .fig
    saveas(f, fullfile(opt.dir.cosmo, 'figures', filename, 'joined_htmp_beta.png')); % .png

    % SAVE SET with original and modified
    save([opt.dir.cosmo, '/', filename,'.mat'],'accu','mvpa_results');

end

