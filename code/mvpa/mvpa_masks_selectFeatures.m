function opt = mvpa_masks_selectFeatures(opt)

% Create a report on ROI sizes
opt.roiSizesReport = [];
allRatios = [];

% get how many voxels are active / significant in each ROI
[maskVoxel, opt] = mvpa_masks_calculateSize(opt);

% keep the minimun value of voxels in a ROI as ratio to keep (must be constant)
opt.mvpa.ratioToKeep = min(maskVoxel);

fprintf(['\nWILL USE ', num2str(min(maskVoxel)), ' VOXELS FOR MVPA\n\n']);

end