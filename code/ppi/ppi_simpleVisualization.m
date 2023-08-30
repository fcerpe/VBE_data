% Visualization tool


load(['/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/outputs/derivatives' ...
    '/bidspm-stats/sub-024/task-visualLocalizer_space-IXI549Space_FWHM-6_node-ppiConcatGLM/PPI_physio_vwfa_angg.mat'])

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
