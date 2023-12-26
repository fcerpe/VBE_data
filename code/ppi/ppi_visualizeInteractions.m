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
        plotPPI(vwfaWrd, vwfaScr, areaWrd, areaScr, opt, iSub);

    end

    % Extract slopes of intact and scrambled
    % Save .mat file in spm-PPI/sub/figures to construct averaging analysis

    


end



function plotPPI(area1w, area1s, area2w, area2s, opt, iSub)

% Code from SPM Manual

figure
plot(area1w.PPI.ppi, area2w.PPI.ppi, 'b.', 'MarkerSize', 15);
hold on
plot(area1s.PPI.ppi, area2s.PPI.ppi,'r.', 'MarkerSize', 15);

% Interpolation lines
% For words
x = area1w.PPI.ppi(:);
x = [x, ones(size(x))];
y = area2w.PPI.ppi(:);
B = x\y;
y1 = B(1)*x(:,1)+B(2);
plot(x(:,1),y1,'b-', 'LineWidth', 2);

% For scrambled
x = area1s.PPI.ppi(:);
x = [x, ones(size(x))];
y = area2s.PPI.ppi(:);
B = x\y;
y1 = B(1)*x(:,1)+B(2);
plot(x(:,1),y1,'r-', 'LineWidth', 2);

% Information

% Split names of PPI toget the name of the areas
area1string = strsplit(area1w.PPI.name, {'label-','_x_'});
area1name = area1string{2};

area2string = strsplit(area2w.PPI.name, {'label-','_x_'});
area2name = area2string{2};

legend(area1w.PPI.psy.name{1}, area1s.PPI.psy.name{1})
xlabel([area1name ' activity'])
ylabel([area2name ' response'])
title(['Psychophysiologic Interaction - areas: ' area1name ' and ' area2name ...
        ', contrasts: ' area1w.PPI.psy.name{1} ' and ' area1s.PPI.psy.name{1} ''])


% Save the figure, as both .fig and .png
figPath = fullfile(opt.dir.ppi, ['sub-' opt.subjects{iSub}], 'figures');

% If folder does not exists, make it
if ~exist(figPath)
    mkdir(figPath)
end
figFilename = ['sub-' opt.subjects{iSub} '_PPI_areas-' area1name '-' area2name '_contrasts-' ...
               area1w.PPI.psy.name{1} '&' area1s.PPI.psy.name{1} '_fig'];

savefig(fullfile(figPath, figFilename));
saveas(gcf,[fullfile(figPath, figFilename) '.png']);

end







