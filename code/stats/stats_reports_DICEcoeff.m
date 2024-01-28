%% Calculate DICE coefficients 
%
% DICE coefficient is a measure of overlap between sets (voxels in our
% case). 
% Formula:
% DSC = [2*(X ∩ Y)] / (|X|+|Y|)
%
% For each expert subject, load the two contrasts and apply them to the formula,
% restricting to VWFA mask


% Start a new report - to be transferred to R for data viz
report = {'subject', 'dice'};

% Analysis is only possible on experts
opt.subGroups = ' experts';
opt.subjects = {'006','007','008','009','012','013'};


%% Calculate coefficients and add them to report

for iSub = 1:numel(opt.subjects)

    % get the subject name
    subName = ['sub-' opt.subjects{iSub}];


    % Load all contrasts available
    statsDir = dir(fullfile(opt.dir.stats, subName, ['task-visualLocalizer_space-', opt.space{1}, '_*_node-localizerGLM'])); 
    contrastsDir = dir(fullfile(statsDir.folder, statsDir.name, ...                                
                                [subName, '_*_p-0pt001_*_mask.nii']));

    % Fetch the contrasts of interest:
    % - [FW > SFW] -> frenchGtScrambled
    frPos = find(startsWith({contrastsDir.name}, [subName, '_task-visualLocalizer_space-', opt.space{1}, '_desc-french']));
    frConPath = fullfile(contrastsDir(frPos).folder, contrastsDir(frPos).name);
    
    % - [BW > SBW] -> brailleGtScrambled
    brPos = find(startsWith({contrastsDir.name}, [subName, '_task-visualLocalizer_space-', opt.space{1}, '_desc-braille']));
    brConPath = fullfile(contrastsDir(brPos).folder, contrastsDir(brPos).name);

    % Load contrasts and mask them for VWFA (using neurosynth mask)
    frContrast = load_nii(frConPath);
    brContrast = load_nii(brConPath);

    % Load neurosynth mask
    vwfaMaskDir = dir(fullfile(opt.dir.roi, subName, ['r', subName,  '_*_label-VWFAfr_voxels-*_mask.nii']));
    vwfaMaskPath = fullfile(fullfile(vwfaMaskDir.folder, vwfaMaskDir.name));
    vwfaMask = load_nii(vwfaMaskPath);
    
    % Intersect elements
    [intersection, frMasked, brMasked]  = intersectNiis(frContrast, brContrast, vwfaMask, opt, subName);
    frDouble = double(frMasked.img);
    brDouble = double(brMasked.img);
    intDouble = double(intersection.img);

    % DICE coefficient
    dice = (2*sum(intDouble, 'all')) / (sum(frDouble, 'all') + sum(brDouble, 'all'));

    % Inform the user
    fprintf(['DICE coefficient, ' subName ': ' num2str(dice) '\n']);


    % Add to report
    report = vertcat(report, ...
                     {subName, dice});

    
    % Save intersection masks
    save_nii(frMasked, [frMasked.fileprefix, '.nii']);
    save_nii(brMasked, [brMasked.fileprefix, '.nii']);
    save_nii(intersection, [intersection.fileprefix, '.nii']);
    
    
end 

% Inform the user
fprintf('\nDone. Saving report\n');

% Save report
writecell(report,'reports/stats_DICE_coefficients.txt');






%% Subfunctions

% Make intersection images
% - fr contrast masked by VWFA
% - br contrast masked by VWFA
% - overlap of the two masks
function [int, frMask, brMask] = intersectNiis(fr, br, mask, opt, subName)

% Take one nifti structure as model for intersection
int = fr;

% Modify necessary elements
% - filename
int.fileprefix = fullfile(opt.dir.roi, subName, ['r', subName, '_hemi-L_space-', opt.space{1}, '_atlas-neurosynth_method-contrastsOverlap_label-VWFA_mask']);

% - image
int.img = fr.img == 1 & br.img == 1 & mask.img == 1;
int.img = cast(int.img, 'uint8');

% Intersect images:
% - fr contrast and vwfa mask
frMask = fr;
frMask.fileprefix = fullfile(opt.dir.roi, subName, ['r', subName, '_hemi-L_space-', opt.space{1}, '_method-maskedContrast_label-VWFAfr_mask']);
frMask.img = fr.img == 1 & mask.img == 1;
frMask.img = cast(frMask.img, 'uint8');

% - br contrast and vwfa mask
brMask = br;
brMask.fileprefix = fullfile(opt.dir.roi, subName, ['r', subName, '_hemi-L_space-', opt.space{1}, '_method-maskedContrast_label-VWFAbr_mask']);
brMask.img = br.img == 1 & mask.img == 1;
brMask.img = cast(brMask.img, 'uint8');

end
