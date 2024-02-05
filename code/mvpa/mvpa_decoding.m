function [pairwise, multiclass, cross, opt] = mvpa_decoding(opt)
% Perform all the types of decoding used in these analyses:
% - pairwise comparisons within script
% - multiclass decoding within script
% - pairwise comparison cross-script
%
% Before running also performs feature selection on the nb of voxels


% Manual fix: in early visual area, although sub-006's mask is 108 voxels,
% the valuable ones are 81. 
if strcmp(opt.roiMethod, 'earlyVisual')
    % Manually cast feature selection to 81 voxels
    opt.mvpa.ratioToKeep = 81;
else
    % Features selection: pick the smallest voxel size to perform mvpa
    opt = mvpa_masks_selectFeatures(opt);
end


% Pairwise decoding within script 
pairwise = mvpa_decoding_pairwise(opt);

% RSA and relative non-parametric stats
mvpa_stats_RSA(opt);


% Multiclass decoding
opt.decodingCondition = 'multiclass';
opt.mvpa.permutate = 1;

multiclass = mvpa_decoding_multiclass(opt);

% Non-parametric stats on decoding permutations
mvpa_stats_nonParametric(opt);


% Cross-script decoding
% Change parameters to specify the new analysis needed
opt.subjects = opt.subGroups.experts;
opt.groupName = 'experts';
opt.decodingCondition = 'pairwise';
opt.decodingModality = 'cross';
opt.mvpa.permutate = 1;

cross = mvpa_decoding_cross(opt);

% RSA and relative non-parametric stats
% mvpa_stats_nonParametric(opt);

end