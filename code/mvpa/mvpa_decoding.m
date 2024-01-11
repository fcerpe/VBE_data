function [pairwise, multiclass, cross, opt] = mvpa_decoding(opt)
% Perform all the types of decoding used in these analyses:
% - pairwise comparisons within script
% - multiclass decoding within script
% - pairwise comparison cross-script
%
% Before running also performs feature selection on the nb of voxels

% Features selection: pick the smallest voxel size to perform mvpa
opt = mvpa_masks_selectFeatures(opt);

% Manual fix: in early visual area, although sub-006's mask is 108 voxels,
% the valuable ones are 81. 
if strcmp(opt.roiMethod, 'earlyVisual')

    % Manually cast feature selection to 81 voxels
    opt.mvpa.ratioToKeep = 81;
end


% Pairwise decoding within script 
pairwise = mvpa_decoding_pairwise(opt);

% Non-parametric stats on decoding permutations
mvpa_stats_nonParamteric(opt, 'pairwise');


% Multiclass decoding
opt.decodingCondition = 'multiclass';
opt.mvpa.permutate = 1;

multiclass = mvpa_decoding_multiclass(opt);

% Non-parametric stats on decoding permutations
mvpa_stats_nonParamteric(opt, 'mulitclass');


% Cross-script decoding
% Change parameters to specify the new analysis needed
opt.subjects = opt.subGroups.experts;
opt.groupName = 'experts';
opt.decodingCondition = 'pairwise';
opt.decodingModality = 'cross';
opt.mvpa.permutate = 0;

cross = mvpa_decoding_cross(opt);

end