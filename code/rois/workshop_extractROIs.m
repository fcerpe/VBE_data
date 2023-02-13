% (C) Copyright 2022 Remi Gau


raw_dir = fullfile(fileparts(mfilename('fullpath')), '..', '..');
addpath(fullfile(raw_dir, 'lib', 'bidspm'));
bidspm init;

bids_dir = fullfile(raw_dir, 'inputs', 'raw');
output_dir = fullfile(raw_dir, 'outputs');
preproc_dir = fullfile(output_dir, 'derivatives', 'bidspm-preproc');
roi_dir = fullfile(output_dir, 'derivatives', 'bidspm-roi');

model_file = fullfile(raw_dir, 'models', 'model-defaultSESS01_smdl.json');

bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'create_roi', ...
       'participant_label', {'008'}, ...
       'verbosity', 2, ...
       'roi_atlas', 'visfatlas', ...
       'roi_name', {'OTS', 'ITG', 'MTG', 'LOS', 'pOTS', 'IOS'}, ...
       'space', {'IXI549Space', 'individual'}, ...
       'preproc_dir', preproc_dir);

opt = roi_option();
opt.roi.atlas = 'visfatlas';
opt.roi.name = {'OTS', 'ITG', 'MTG', 'LOS', 'pOTS', 'IOS'};
opt.roi.space = {'IXI549Space', 'individual'};
opt.dir.stats = fullfile(opt.dir.raw, '..', 'derivatives', 'bidspm-stats');
opt.subjects = {'008'};

roiImage = extractRoiFromAtlas(output_dir, opt.roi.atlas, 'OTS', 'L');
roiImage = extractRoiFromAtlas(output_dir, opt.roi.atlas, 'ITG', 'L');
roiImage = extractRoiFromAtlas(output_dir, opt.roi.atlas, 'MTG', 'L');
roiImage = extractRoiFromAtlas(output_dir, opt.roi.atlas, 'LOS', 'L');
roiImage = extractRoiFromAtlas(output_dir, opt.roi.atlas, 'pOTS', 'L');
roiImage = extractRoiFromAtlas(output_dir, opt.roi.atlas, 'IOS', 'L');




