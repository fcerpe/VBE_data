
  %% run mvpa 
  
  % use parcels or NS masks?
%   roiSource = 'hmat'; % 'freesurfer', 'neurosynth', ...
%   accuracy = calculateMvpa(opt, roiSource);
    maskVoxel = calculateMaskSize(opt);
    
    % take the most responsive xx nb of voxels
  opt.mvpa.ratioToKeep = 250; %363;%157 for sub-001 and 392 for sub-002 % 100 150 250 350 420
  
%   accuracy = calculateMvpa(opt);
  
  accuracyWithinModality = calculateMvpaWithinModality(opt);
  accuracyCrossModal = calculateMvpaCrossModal(opt);
  
  