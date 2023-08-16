%% PPI - Extracction of VOIs from PPI-GLM Results
%
% For each subject and area (only VWFA), will extract a VOI_VWFA_1.mat file
% that contains the time course of BOLD reponse in that area.
% Uses peak coordinates identified manually and masks created around those
% coordinates and used in MVPA
%
% For a given subject, get:
% - open the results
% - navigate to coordinates
% - eignevariate around peak
% - apply mask
%
% TO-DO (16/08/2023)
% - finish the batch
% - find out which spmt contrast to use, neuroscientific problem

% get the subject's files

% peak vwfa coord(s)

% A copy of peaks for each sub / area is stored 'roi_geMNIcoords'
% for roi creation purposes. Fetch the scripts
addpath('../rois');

% Get the peaks for all the subs
mni = roi_getMNIcoords(opt.subjects);

% TL;DR
% For each subject, load the peak for VWFA (defined by FW-SFW)
for iSub = 1:numel(opt.subjects)

    % (16/08/2023)
    % Just manual additions hidden from sight. No generalization to
    % different contrasts, area, parrticular cases
    matlabbatch = ppi_customizeBatch(opt, iSub);

    % Save and run batch bidspm-style
    batchName = ['VOI-extraction_ffx_task-', strjoin(opt.taskName, ''), ...
                 '_space-', char(opt.space), ...
                 '_FWHM-', num2str(opt.fwhm.func)];
    status = saveAndRunWorkflow(matlabbatch, batchName, opt, opt.subjects{iSub});
end
