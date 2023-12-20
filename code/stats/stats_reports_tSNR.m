% Compute the temporal signal-to-noise ratio (tSNR) of the acquired raw data 
%
% For each subject, acquisiton, mask option (VWFA; whole-brain), compute
% the average tSNR for both localizer and mvpa runs

% add spm to the path
addpath(fullfile(pwd, '..', 'lib', 'bidspm'));
addpath(fullfile(pwd, '..', 'lib', 'CPP_BIDS'));
bidspm;

% Start a new report - to be transferred to R for data viz
report = {'subject', 'task', 'mask', 'tSNR'};

%%

for iSub = 1:numel(opt.subjects)

    % get the subject ID
    subName = ['sub-' opt.subjects{iSub}];

    % tell the user
    fprintf(['- processing ' subName '\n']);

    % get the complete lists of masks for a given subject
    % Dir should look like this: 
    % ../../inputs/raw/sub-*/ses-*/func
    maskPath = dir(fullfile(opt.dir.raw, subName, ['ses-*'], 'func', [subName,'*_task-*_bold.nii'])); 

    for iMask = 1:numel(maskPath)

        % Extract the task of the mask
        maskName = strsplit(maskPath(iMask).name, {'task-','_run'});
        maskTask = maskName{2};
    
        thisMask = fullfile(maskPath(iMask).folder, maskPath(iMask).name);

        % Compute tSNR for the bold image 
        [tSNRimage, tSNRvol] = computeTsnr(thisMask);
    
        % Report average whole-brain tSNR and add it to the final report
        report = vertcat(report, ...
                                 {subName, maskTask, 'whole', mean(tSNRvol,'all','omitnan')});


    end

end
% inform the user
fprintf(['\nDone. Saving report\n']);

% save report
writecell(report,'reports/stats_compute_tSNR.txt');



