function opt = visbra_getOption_stats_evrel()
    %
    % returns a structure that contains the options chosen by the user to run
    % slice timing correction, pre-processing, FFX, RFX.
    %
    % (C) Copyright 2019 Remi Gau

    opt = [];

    opt.subjects = {'001'};

    % task to analyze
    opt.taskName = 'visualEventRelated';
    opt.verbosity = 1;

    opt.desc = 'glm';

    % The directory where the data are located
    WD = 'C:\Users\filip\Documents\Gin\VisualBraille\analysis';

    opt.dir.raw = fullfile(WD, 'inputs', 'raw');
    opt.dir.derivatives = fullfile(WD, 'outputs', 'derivatives');
    opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');
    opt.dir.input = opt.dir.preproc;
    opt.dir.roi = fullfile(opt.dir.derivatives, 'cpp_spm-roi');
    opt.dir.stats = fullfile(opt.dir.derivatives, 'cpp_spm-stats');

    opt.pipeline.type = 'stats';

    opt.space = {'MNI'};

    opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                              'models', 'model-visualEventRelated_smdl.json');
    % to add the hrf temporal derivative = [1 0]
    % to add the hrf temporal and dispersion derivative = [1 1]
    % opt.model.hrfDerivatives = [0 0];

    % Specify the result to compute
    opt.result.Nodes(1) = returnDefaultResultsStructure();

    opt.result.Nodes(1).Level = 'subject';

    % For each contrats, you can adapt:
    %  - voxel level (p)
    %  - cluster (k) level threshold
    %  - type of multiple comparison:
    %    - 'FWE' is the defaut
    %    - 'FDR'
    %    - 'none'
    opt.result.Nodes(1).Contrasts(1).Name = 'words_gt_blanks';
    opt.result.Nodes(1).Contrasts(1).MC =  'none';
    opt.result.Nodes(1).Contrasts(1).p = 0.001;
    opt.result.Nodes(1).Contrasts(1).k = 0;

    opt.result.Nodes(1).Contrasts(2).Name = 'braille_gt_french';
    opt.result.Nodes(1).Contrasts(2).MC =  'none';
    opt.result.Nodes(1).Contrasts(2).p = 0.001;
    opt.result.Nodes(1).Contrasts(2).k = 0;

    opt.result.Nodes(1).Contrasts(3).Name = 'french_gt_braille';
    opt.result.Nodes(1).Contrasts(3).MC =  'none';
    opt.result.Nodes(1).Contrasts(3).p = 0.001;
    opt.result.Nodes(1).Contrasts(3).k = 0;

    % Specify how you want your output (all the following are on false by default)
    opt.result.Nodes(1).Output.png = true();
    opt.result.Nodes(1).Output.csv = true();
    opt.result.Nodes(1).Output.thresh_spm = true();
    opt.result.Nodes(1).Output.binary = true();

    % MONTAGE FIGURE OPTIONS
    opt.result.Nodes(1).Output.montage.do = true();
    opt.result.Nodes(1).Output.montage.slices = -16:2:0; % in mm
    % axial is default 'sagittal', 'coronal'
    opt.result.Nodes(1).Output.montage.orientation = 'axial';
    % will use the MNI T1 template by default but the underlay image can be changed.
    opt.result.Nodes(1).Output.montage.background = ...
        fullfile(spm('dir'), 'canonical', 'avg152T1.nii,1');

    opt.result.Nodes(1).Output.NIDM_results = true();

    %   % in GLM analysis of event related tasks, smoothing is 2mm.
    %   % so
    %   opt.query.desc = 'smth2';

    %% DO NOT TOUCH
    opt = checkOptions(opt);
    saveOptions(opt);

end
