%% PPI - visualize interactions 
% 
% For eachsubject / condition / area, visualize the interaction between
% VWFA and a target area (each of the Fedorenko's ROIs)
%
% Uses plot commands from SPM manual, it's intended as a starting point for 
% nicer R visualizations
%
% TO DO:
% - average values, if neuroscientifically possible 

opt.ppi.script = {'french','braille'};

% Initialize report - start a new report
opt.report = {'subject','group','script','condition','slope','intercept'};
opt.table = {'subject','condition','cluster','x','y'};

for iScript = 1:numel(opt.ppi.script)

    if strcmp(opt.ppi.script{iScript}, 'french')
        opt.ppi.contrast = {'fw','sfw'};
        opt.subjects = {'006', '007', '008', '009', '010', '011', '013', '018', '019', '020', '021', '022', '023', '024', '027'};
    else
        opt.ppi.contrast = {'bw','sbw'};
        opt.subjects = {'006', '007', '008', '009', '013'};
    end


    for iSub = 1:numel(opt.subjects)

        subName = ['sub-' opt.subjects{iSub}];

        % Load first PPI (VWFA) for both contrasts
        % Find the folder
        ppiFolder = dir(fullfile(opt.dir.ppi, subName, 'PPI-analysis'));

        % Find the file for the intact stimuli (either FW or BW)
        vwfaWrdName = ['PPI_' subName '_hemi-L_label-VWFAfr_x_(' opt.ppi.contrast{1} ').mat'];
        vwfaWrdIdx = find(strcmp({ppiFolder.name}, vwfaWrdName));

        % Find the file for the scrambled stimuli (either SFW or SBW)
        vwfaScrName = ['PPI_' subName '_hemi-L_label-VWFAfr_x_(' opt.ppi.contrast{2} ').mat'];
        vwfaScrIdx = find(strcmp({ppiFolder.name}, vwfaScrName));

        % Load the files
        vwfaWrd = load(fullfile(ppiFolder(vwfaWrdIdx).folder, ppiFolder(vwfaWrdIdx).name));
        vwfaScr = load(fullfile(ppiFolder(vwfaScrIdx).folder, ppiFolder(vwfaScrIdx).name));

        % Iterate through all the other areas
        for iVoi = 2:numel(opt.ppi.voiList)

            % Get the area name
            thisVoi = opt.ppi.voiList{iVoi};
            parseVoi = strsplit(thisVoi,'_');
            voiName = parseVoi{2};

            % Find the file for the intact stimuli (either FW or BW)
            areaWrdName = ['PPI_' subName '_hemi-L_label-' voiName '_x_(' opt.ppi.contrast{1} ').mat'];
            areaWrdIdx = find(strcmp({ppiFolder.name}, areaWrdName));

            % Find the file for the scrambled stimuli (either SFW or SBW)
            areaScrName = ['PPI_' subName '_hemi-L_label-' voiName '_x_(' opt.ppi.contrast{2} ').mat'];
            areaScrIdx = find(strcmp({ppiFolder.name}, areaScrName));

            % Load the files
            areaWrd = load(fullfile(ppiFolder(areaWrdIdx).folder, ppiFolder(areaWrdIdx).name));
            areaScr = load(fullfile(ppiFolder(areaScrIdx).folder, ppiFolder(areaScrIdx).name));

            % Visualize the interaction between variables
            % Plot code as a separate function
            opt = plotPPI(vwfaWrd, vwfaScr, areaWrd, areaScr, opt, iSub, iScript);

        end

    end

end

% save report
writecell(opt.report,'slopesReport.txt');

% save table with all the datapoints
writecell(opt.table,'datapointsPPI.txt');



%% PLOT FUNCTION
function opt = plotPPI(area1intact, area1scrambled, area2intact, area2scrambled, opt, iSub, iScript)

% Code from SPM Manual

figure
plot(area1intact.PPI.ppi, area2intact.PPI.ppi, 'b.', 'MarkerSize', 15);
hold on
plot(area1scrambled.PPI.ppi, area2scrambled.PPI.ppi,'r.', 'MarkerSize', 15);

% Interpolation lines
% For words
xIntact = area1intact.PPI.ppi(:);
xIntact = [xIntact, ones(size(xIntact))];
yIntact = area2intact.PPI.ppi(:);
bIntact = xIntact \ yIntact;
y1Intact = bIntact(1) * xIntact(:,1) + bIntact(2);
plot(xIntact(:,1), y1Intact, 'b-', 'LineWidth', 2);

% For scrambled
xScrambled = area1scrambled.PPI.ppi(:);
xScrambled = [xScrambled, ones(size(xScrambled))];
yScrambled = area2scrambled.PPI.ppi(:);
bScrambled = xScrambled \ yScrambled;
y1Scrambled = bScrambled(1) * xScrambled(:,1) + bScrambled(2);
plot(xScrambled(:,1), y1Scrambled, 'r-', 'LineWidth', 2);

% Information

% Split names of PPI toget the name of the areas
area1string = strsplit(area1intact.PPI.name, {'label-','_x_'});
area1name = area1string{2};

area2string = strsplit(area2intact.PPI.name, {'label-','_x_'});
area2name = area2string{2};

legend(area1intact.PPI.psy.name{1}, area1scrambled.PPI.psy.name{1})
xlabel([area1name ' activity'])
ylabel([area2name ' response'])
title(['Psychophysiologic Interaction - areas: ' area1name ' and ' area2name ...
        ', contrasts: ' area1intact.PPI.psy.name{1} ' and ' area1scrambled.PPI.psy.name{1} ''])


% Save the figure, as both .fig and .png
figPath = fullfile(opt.dir.ppi, ['sub-' opt.subjects{iSub}], 'figures');

% If folder does not exists, make it
if ~exist(figPath)
    mkdir(figPath)
end
figFilename = ['sub-' opt.subjects{iSub} '_PPI_areas-' area1name '-' area2name '_contrasts-' ...
               area1intact.PPI.psy.name{1} '&' area1scrambled.PPI.psy.name{1} '_fig'];

savefig(fullfile(figPath, figFilename));
saveas(gcf,[fullfile(figPath, figFilename) '.png']);
% Save .mat file in spm-PPI/sub/figures to construct averaging analysis
save([fullfile(figPath, figFilename) '_creation.mat']);

% Report: add data
switch opt.subjects{iSub}(end-1:end)
    case {'06', '07','08','09','12','13'}
        group = 'expert';
        cluster = [opt.ppi.script{iScript} '_expert'];
    otherwise
        group = 'control';
        cluster = [opt.ppi.script{iScript} '_control'];
end
% add intact
opt.report = vertcat(opt.report,...
                     {['sub-' opt.subjects{iSub}], group, opt.ppi.script{iScript}, ...
                     area1intact.PPI.psy.name{1}, bIntact(1), bIntact(2)});
% add scrambled
opt.report = vertcat(opt.report,...
                     {['sub-' opt.subjects{iSub}], group, opt.ppi.script{iScript}, ...
                     area1scrambled.PPI.psy.name{1}, bScrambled(1), bScrambled(2)});

% table: add data
for iXI = 1:size(xIntact,1)
    opt.table = vertcat(opt.table,{opt.subjects{iSub}, ...
                                   area1intact.PPI.psy.name{1}, ...
                                   cluster, ...
                                   xIntact(iXI,1), ...
                                   yIntact(iXI)});
end
for iXS = 1:size(xScrambled,1)
    opt.table = vertcat(opt.table,{opt.subjects{iSub}, ...
                                   area1scrambled.PPI.psy.name{1}, ...
                                   cluster, ...
                                   xScrambled(iXS,1), ...
                                   yScrambled(iXS)});
end

end







