%% Readable Matrix
%
% From huge cosmomvpa output table to nice RDM-like matrices
% Valid for different sizes
% 1. divide table in struct

clear

warning('on')

addpath '/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/code'

mvpa_results = struct;
mvpa_results.raw = struct;
mvpa_results.raw.together_VWFAfr_beta = []; mvpa_results.raw.together_VWFAfr_tmap = [];
mvpa_results.raw.together_VWFAbr_beta = []; mvpa_results.raw.together_VWFAbr_tmap = [];
mvpa_results.raw.together_lLO_beta = [];    mvpa_results.raw.together_lLO_tmap = [];
mvpa_results.raw.together_lpFS_beta = [];   mvpa_results.raw.together_lpFS_tmap = [];
mvpa_results.raw.together_rLO_beta = [];    mvpa_results.raw.together_rLO_tmap = [];
mvpa_results.raw.together_rpFS_beta = [];   mvpa_results.raw.together_rpFS_tmap = [];

opt = mvpa_option();

filename = 'task-wordsDecoding_condition-within_script_nbvoxels-50';
load(fullfile(opt.dir.cosmo, [filename,'.mat']));

%% CASE 'within_script'
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

    thisSub = accu(i).subID;
    thisMask = accu(i).mask;
    thisImage = accu(i).image;

    % save original in corresponding variable
    pathString = ['mvpa_results.raw.sub', thisSub, '_', thisMask, '_', thisImage];

    %save chunk in the right struct place
    eval([pathString ' = thisChunk;']);

    % Modify pathString: from 'raw' to 'mat'
    pathString(14:16) = 'mat';

    % Place every accuracy from struct to NxN matrix
    mvpaMat = mvpa_getMatrix(thisChunk); % only works with a 8*8 matrix

    eval([pathString ' = mvpaMat;']);

    %% show figure as heatmap

    % labels
    lab_mvpa = {'FRW', 'FPW', 'FNW', 'FFS', 'BRW', 'BPW', 'BNW', 'BFS'};

    % start making the figure
    f = figure;
    f.Position = [300 300 740 700];
    f.Visible = 'off';

    % make save name: subXXX_area_image (e.g. sub007_VWFAbr_tmap)
    name = ['sub', thisSub, '_', thisMask, '_', thisImage, '_htmp'];

    % make figure
    tmp_graphics = heatmap(lab_mvpa, lab_mvpa, mvpaMat, ...
        'CellLabelColor', 'none', ...
        'Colormap', parula, ...
        'GridVisible', 'off', ...
        'FontSize', 20, ...
        'ColorLimits', [0.2 1], ...
        'Units', 'pixels', ...
        'Position',[70 40 600 600]);

    tmp_graphics.Title = ['sub-', thisSub, ': ', thisMask, ' (', thisImage, ')'];

    % save figure: as variable, as .fig, as .png
    eval(['mvpa_results.fig.' char(name) '= tmp_graphics;']);
    savefig(f, fullfile(opt.dir.cosmo, 'figures', filename, name)); % .fig
    saveas(f, fullfile(opt.dir.cosmo, 'figures', filename, [name,'.png'])); % .png

    %% get barplot with accuracy

    nameBar = ['sub', thisSub, '_', thisMask, '_', thisImage, '_bar'];

    barValues = [thisChunk.accuracy];
    barLabels = {'FRW-FPW','FRW-FNW','FRW-FFS','FPW-FNW','FPW-FFS','FNW-FFS', ...
        'BRW-BPW','BRW-BNW','BRW-BFS','BPW-BNW','BPW-BFS','BNW-BFS'};
    barTitle = ['sub-', thisSub, ': ', thisMask, ' (', thisImage, ')'];

    % open another figure
    barFigure = figure;
    barFigure.Position = [170,116,793,620];
    barFigure.Visible = 'off';
    b = bar(barValues,'FaceColor','flat');
    % CPP colors to distinguish between FR and BR
    % [1    0.62 0.29] = orange
    % [0.41 0.67 0.6 ] = sage green
    b.CData([1 2 3 4 5 6],:) = [1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29; 1 0.62 0.29];
    b.CData([7 8 9 10 11 12],:) = [0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6; ...
        0.41 0.67 0.6; 0.41 0.67 0.6; 0.41 0.67 0.6];
    % axes (couldn't do it better)
    ax = gca;
    ax.FontSize = 20;
    ax.Units = 'pixels';
    ax.Position = [74, 134, 706, 480];
    xlabel('Conditions')
    ylabel('Accuracy')
    ylim([0 1.1])
    xticklabels(barLabels)
    yticks([0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])

    % save figure: as variable, as .fig, as .png
    eval(['mvpa_results.fig.' nameBar '= b;']);
    savefig(barFigure, fullfile(opt.dir.cosmo, 'figures', filename, nameBar)); % .fig
    saveas(barFigure,fullfile(opt.dir.cosmo, 'figures', filename, [nameBar,'.png'])); % .png

    %% Store the single subject in the right average group, according to the relative area and the image

    eval(['mvpa_results.raw.together_' thisMask '_' thisImage ' = ' ...
        'horzcat(mvpa_results.raw.together_' thisMask '_' thisImage ', thisChunk);']);

end

%% Get averages for area/image

decods = fieldnames(mvpa_results.raw);

for j = 1:numel(decods)
    thisVar = decods{j};
    splitVar = split(thisVar,'_');
    currSub = splitVar{1}; currMask = splitVar{2}; currImage = splitVar{3};

    if startsWith(currSub, 't')
        eval(['currentAccuracies = [mvpa_results.raw.' decods{j} '.accuracy];']);
        nbSubs = size(currentAccuracies,2)/12;
        currentAccuracies = reshape(currentAccuracies,nbSubs,12);
        meanAccuracies = mean(currentAccuracies,1);

        eval(['temp_struct = rmfield(mvpa_results.raw.sub006_' currMask '_' currImage ', "subID");']);
        for k = 1:12
            [temp_struct(k).accuracy] = deal([meanAccuracies(k)]);
        end

        eval(['mvpa_results.raw.average_' currMask '_' currImage ' = temp_struct;']);
    end
end

%% Get matrices and figures

decods = fieldnames(mvpa_results.raw);

for m = 1:numel(decods)
    if startsWith(decods{m}, 'average')

        % get name parts
        thisVar = decods{m};
        splitVar = split(thisVar,'_');
        thisSub = 'mean'; thisMask = splitVar{2}; thisImage = splitVar{3};

        % get average stuct
        eval(['tempAverage = [mvpa_results.raw.' decods{m} '];']);

        % get matrix and save it
        tempMat = mvpa_getMatrix(tempAverage);
        eval(['mvpa_results.mat. ' decods{m} ' = tempMat;']);

        % get graphs and save them
        % RDM
        f = figure;
        f.Position = [300 300 740 700];
        f.Visible = 'off';

        % make save name: subXXX_area_image (e.g. sub007_VWFAbr_tmap)
        name = [thisSub, '_', thisMask, '_', thisImage, '_htmp'];

        % make figure
        tmp_graphics = heatmap(lab_mvpa, lab_mvpa, tempMat, 'CellLabelColor', 'none', 'Colormap', parula, ...
            'GridVisible', 'off', 'FontSize', 20, 'ColorLimits', [0.2 1], 'Units', 'pixels', 'Position',[70 40 600 600]);
        tmp_graphics.Title = [thisSub, ': ', thisMask, ' (', thisImage, ')'];

        % save figure: as variable, as .fig, as .png
        eval(['mvpa_results.fig.' name ' = tmp_graphics;']);
        savefig(f, fullfile(opt.dir.cosmo, 'figures', filename, name)); % .fig
        saveas(f, fullfile(opt.dir.cosmo, 'figures', filename, [name,'.png'])); % .png

        % Barplot
        nameBar = [thisSub, '_', thisMask, '_', thisImage, '_bar'];

        barValues = [tempAverage.accuracy];
        barLabels = {'FRW-FPW','FRW-FNW','FRW-FFS','FPW-FNW','FPW-FFS','FNW-FFS', ...
                     'BRW-BPW','BRW-BNW','BRW-BFS','BPW-BNW','BPW-BFS','BNW-BFS'};
        barTitle = [thisSub, ': ', thisMask, ' (', thisImage, ')'];

        % open another figure
        barFigure = figure;
        barFigure.Position = [170,116,793,620];
        barFigure.Visible = 'off';
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

%% SAVE SET with original and modified

save([filename,'.mat'],'accu','mvpa_results');



