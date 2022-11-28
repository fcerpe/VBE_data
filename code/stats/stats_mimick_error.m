

% So can you try to run it on its own by running the bit of code below to see it you can reproduce the error.

%% TO DO
opt = stats_localizer_option();

opt.model.file = fullfile(opt.dir.root, 'code', ...
    'models', 'model-visualLocalizerUnivariate_smdl.json');

%% TO RUN
opt.model.bm = BidsModel('file', opt.model.file);

listNodeNames = {};

for iRes = 1:numel(opt.results)
  if ~isempty(opt.results(iRes).nodeName)
    node = opt.model.bm.Nodes('Name',  opt.results(iRes).nodeName);
    listNodeNames{iRes} = node.Name;
  end
end

