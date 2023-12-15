function [pairwise, multiclass, cross, opt] = mvpa_decoding(opt)
% Perform all the types of decoding used in these analyses:
% - pairwise comparisons within script
% - multiclass decoding within script
% - pairwise comparison cross-script
%
% Before running also performs feature selection on the nb of voxels

% Features selection: pick the smallest voxel size to perform mvpa
opt = mvpa_masks_selectFeatures(opt);

% Pairwise decoding within script 
pairwise = mvpa_decoding_pairwise(opt);

% Multiclass decoding
opt.decodingCondition = 'multiclass';
multiclass = mvpa_decoding_multiclass(opt);

% Cross-script decoding
% Change parameters to specify the new analysis needed
opt.subjects = opt.subGroups.experts;
opt.groupName = 'experts';
opt.decodingCondition = 'pairwise';
opt.decodingModality = 'cross';

cross = mvpa_decoding_cross(opt);

end