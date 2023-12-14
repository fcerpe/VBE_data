function stats_run(opt)

% This script will run the FFX and contrasts on it, specified in a given
% model file
%
% Results might be a bit different from those in the manual as some
% default options are slightly different in this pipeline
% (e.g use of FAST instead of AR(1), motion regressors added)
%
% (C) Copyright 2023 Remi Gau 

%% Stats based on .json model file
% check stats_localizer_option for details
% It uses the 'old' bidspm method, with different functions for the
% different steps, can be then ran separately

bidsFFX('specifyAndEstimate', opt);
 
bidsFFX('contrasts', opt);
 
bidsResults(opt);

% In the case of 'wordsDecoding' task, we also need to concatenate the betas into 4D images
% To perform second level analyses (more in code/mvpa)
if strcmp(opt.taskName{1}, 'wordsDecoding')

    bidsConcatBetaTmaps(opt, 0);
end

% If needed, suggestions of code for group analysis
% (not implemented in this project) 
% 
% bidsRFX('smoothContrasts', opt);
% bidsRFX('RFX', opt);

end
