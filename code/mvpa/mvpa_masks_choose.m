function [opt] = mvpa_masks_choose(opt)

opt.maskName = [];

for iSub = 1:numel(opt.subjects)

    subID = opt.subjects{iSub};

    % default one is expansion then intersected with neurosynth
    if isempty(opt.roiMethod)
        opt.roiMethod = 'expansion';
    end

    % Take the required ROIs based on the type of analysis we are 
    % performing. 
    % fedorenko: VWFA + AntTemp, PosTemp, AngG, IFG, IFGorb, MFG. All both
    %            Left and Right
    % vwfaSplit: takes the splitted VWFAs based on the raw chopping of the
    %            ROI in half
    % vwfaSplitAtlas: uses VWFA splitted according to atlas (undefined)
    switch opt.roiMethod

        % VWFA, lLO, rLO
        case 'expansion' 

            % get the actual filename (may change is numVoxels is specified in the name)
            atlas_filename = [opt.dir.rois, '/sub-',num2str(subID),...
                              '/rsub-',num2str(subID),'_hemi-*_space-',opt.space{1},'_atlas-neurosynth_method-expansionIntersection*.nii'];
            atlas_files = dir(atlas_filename);
            opt.maskName = horzcat(opt.maskName, {atlas_files.name});
            
            opt.maskLabel = {'VWFAfr', 'lLO', 'rLO'};

        % VWFA and Fedorenko areas:
        % - L and R, AntTemp, PosTemp, AngG, IFG, IFGorb, MFG
        case 'language'
            atlas_filename = [opt.dir.rois, '/sub-',num2str(subID),...
                              '/rsub-',num2str(subID),'_hemi-*_space-',opt.space{1},'_atlas-language_contrast-french*.nii'];
            atlas_files = dir(atlas_filename);
            
            % Check that, among all the fedorenko masks,
            % we only add those relevant for the analyses
            opt.maskLabel = {'lPosTemp'};
            okArea = [];
    
            % get hemispheres and masks allowed
            for ml = 1:numel(opt.maskLabel)
                okArea = horzcat(okArea, {upper(opt.maskLabel{ml}(1)), opt.maskLabel{ml}(2:end)});
            end

            for af = 1:numel(atlas_files)
                parseFile = strsplit(atlas_files(af).name, {'hemi-','_space','label-','_mask'});
                parseHemi = parseFile{2};
                parseArea = parseFile{4};

                okIdx = 1;
                notMatched = true;
                while notMatched && okIdx <= size(okArea,1)
                    if strcmp(parseHemi, okArea{okIdx,1}) && strcmp(parseArea, okArea{okIdx,2})
                        opt.maskName = horzcat(opt.maskName, {atlas_files(af).name});
                        notMatched = false;
                    else
                        okIdx = okIdx +1;
                    end
                end
            end

        % V1
        case 'earlyVisual'
            atlas_filename = [opt.dir.rois, '/sub-',num2str(subID),...
                              '/rsub-',num2str(subID),'_hemi-*_space-',opt.space{1},'_atlas-jubrain_contrast-allFrench_label-V1*.nii'];
            atlas_files = dir(atlas_filename);
            opt.maskName = horzcat(opt.maskName, {atlas_files.name});

            opt.maskLabel = {'v1'};   

        % Neurosynth analysis for reviews
        case 'neurosynth'
            atlas_filename = [opt.dir.rois, '/sub-',num2str(subID),...
                              '/rsub-',num2str(subID),'_hemi-L_space-',opt.space{1},'_atlas-neurosynth_label-visualWords_vox-100*.nii'];
            atlas_files = dir(atlas_filename);
            opt.maskName = horzcat(opt.maskName, {atlas_files.name});

            opt.maskLabel = {'VWFAfr'};   

    end
end

end
