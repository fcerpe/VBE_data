% Make ROIs of the face and voice loc overlap
%
% Takes individual peak coordinates (from getOption function) 
% To create individual region masks with min 150vx (see nrVoxels arg)
%
% contrast faces > objects and voices > objects

% nrVoxels = [150];
% 
% for voxNr = 1:length(nrVoxels)

opt = designtwo_getOption_overlap;

% Loop through subjects to create individual ROIs
for roi = 1:length(opt.rois)
    
    % where do you want to save the new mask
    outputDir = strcat(opt.maskPath,'/label-intersection/');
        
        % select MNI coordinates of current roi
        opt.sphere.location = opt.sphere.allLocations{roi};        
            
            % where is the beta image to use as reference space
            betaImage = opt.betaPath; 
            
            % where is the cluster binary mask (overlap between the 2 localizers - contains 4+ clusters of interest that I am trying to separate) %
            clusterMask = {strcat(opt.maskPath,'/localizersOverlap',opt.rois{roi},'.nii')};
            
            % when wanting to cross an expanding sphere with a cluster
            % cluster and sphere together in a struct
            specification  = struct( ...
                'mask1', clusterMask, ...
                'mask2', opt.sphere);
            

             mask = createRoi('expand', specification, betaImage, outputDir, opt.saveImg);
   

    
end
    
%end

function opt = designtwo_getOption_overlap


% opt.sphere.radius = 4; % starting radius for 'expand'
% opt.sphere.maxNbVoxels = 300;

% Smoothing level of localizer and data respectively
opt.locFWHM = 6;
opt.eventFWHM = 2;

%opt.locPath = '/Users/falagiarda/project-combiemo-playaround/only_localizers_analyses/derivatives-face/derivatives/cpp_spm/';
%opt.maskPath = '/stats/ffx_task-facelocalizerCombiemo/ffx_space-MNI_FWHM-';

opt.maskPath = '/Users/falagiarda/project-combiemo-playaround/design-two/localizers_individual_area/localizers_overlap';

opt.dataPath = '/Users/falagiarda/project-combiemo-playaround/design-two/derivatives/cpp_spm/';
opt.betaForSphere = '/Users/falagiarda/project-combiemo-playaround/design-two/localizers_individual_area/beta0001.nii';

opt.saveImg = 1;

end