function opt = preproc_option()
  %
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.
  %
  % (C) Copyright 2019 Remi Gau

  opt = [];

  % task to analyze
  opt.pipeline.type = 'preproc';
  opt.taskName = {'visualLocalizer'};

  % The directory where the data are located
  opt.dir.root = fullfile(fileparts(mfilename('fullpath')), '..');
  opt.dir.raw = fullfile(opt.dir.root, 'inputs', 'raw');
  opt.dir.derivatives = fullfile(opt.dir.root, 'outputs', 'derivatives');


  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
