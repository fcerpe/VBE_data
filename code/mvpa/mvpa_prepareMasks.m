function opt = mvpa_prepareMasks(opt)

%% prepare the rois

opt.unzip.do = false;
opt.save.roi = true;
opt.outputDir = []; % if this is empty new masks are saved in the current directory.
if opt.save.roi
    opt.reslice.do = true;
else
    opt.reslice.do = false;
end

opt = mvpa_chooseMask(opt);

for iSub = 1:numel(opt.subjects)

    for iImage = 1:length(opt.mvpa.map4D)

        dataImage = fullfile(opt.dir.stats, ['sub-',opt.subjects{iSub}], ...
            ['task-', opt.taskName{:}, '_space-', opt.space{:}, '_FWHM-2'], ...
            ['sub-', opt.subjects{iSub}, '_task-', opt.taskName{:}, '_space-', opt.space{:}, '_desc-4D_', opt.mvpa.map4D{iImage}, '.nii']);
        
        roiPath = fullfile(opt.dir.rois, ['sub-',opt.subjects{iSub}]);

        subMasks = opt.maskName(startsWith(opt.maskName, strcat('sub-', opt.subjects{iSub})));

        for iMask = 1:length(subMasks)

            if startsWith(opt.subjects{iSub},'008') && ...
                    (startsWith(subMasks{iMask},'sub-008_space-MNI_trial-IndividualCoords_label-VWFAbr') || ...
                     startsWith(subMasks{iMask},'sub-008_space-MNI_trial-NeurosynthCoords_label-VWFAbr'))
                continue
            end

            mask = fullfile(opt.dir.rois, ['sub-',opt.subjects{iSub}], subMasks{iMask});

            % reslice
            mask = resliceRoiImages(dataImage, mask);

            % get some data from roi
            dataMask = spm_summarise(dataImage, mask);

            %get data from your 4D beta mask
            [~, dimData] = voxelCountAndDimensions(mask);
        end
    end
end

end