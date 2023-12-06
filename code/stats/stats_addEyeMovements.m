% Add Eye Movements to confounds of every run
%
% For each subeject, take the outputs of bidsMReye and add it to the counfounds.tsv 
% of bidspm-preproc.
% Then run a GLM on that
% 
% TO-DO:
% - modify both desc-confounds_timeseries.json and .tsv
% - add all the columns from bidsMReye
% - create eye movements model .json
% - run GLM here / create new options in main

clear;
clc;

warning('off');

% add spm to the path
addpath(fullfile(pwd, '..', 'lib', 'bidspm'));
addpath(fullfile(pwd, '..', 'lib', 'CPP_BIDS'));
bidspm;

% check inside if everything is ok before starting the pipeline
opt = stats_localizer_option();



%% 

for iSub = 1:numel(opt.subjects)

    subName = ['sub-' opt.subjects{iSub}];

    % fecth bidspm-preproc and bidsMReye files
    preprocJsonList = dir(fullfile(opt.dir.preproc, subName, 'ses-00*', 'func', '*_desc-confounds_timeseries.json'));  
    preprocTsvList = dir(fullfile(opt.dir.preproc, subName, 'ses-00*', 'func', '*_desc-confounds_timeseries.tsv'));  
    motionTsvList = dir(fullfile(opt.dir.preproc, subName, 'ses-00*', 'func', '*_desc-stc_motion.tsv'));
    eyeTsvList = dir(fullfile(opt.dir.derivatives, 'bidsMReye', subName, 'ses-00*', 'func', '*space-individual*_desc-bidsmreye_eyetrack.tsv'));

    % for each file, take eyeTsv:
    % - add first row (header) as separate entries in preprocJson
    % - add content in preprocTsv
    for iFile = 1:numel(eyeTsvList)

        % load files
        preprocTsv = readtable(fullfile(preprocTsvList(iFile).folder, preprocTsvList(iFile).name), "FileType","text","Delimiter","\t");
        motionTsv = readtable(fullfile(motionTsvList(iFile).folder, motionTsvList(iFile).name), "FileType","text","Delimiter","\t");
        fid = fopen(fullfile(preprocJsonList(iFile).folder, preprocJsonList(iFile).name),'r+'); 
        raw = fread(fid,inf); 
        str = char(raw');  
        preprocJson = jsondecode(str);
        eyeTsv = readtable(fullfile(eyeTsvList(iFile).folder, eyeTsvList(iFile).name), "FileType","text","Delimiter","\t");

        eyeVarList = eyeTsv.Properties.VariableNames;

        for iVar = 2:size(eyeTsv,2)

            % get the variable to copy
            eyeVar = eyeVarList{iVar};

            % hack: displacement in position 1 is NaN, and that casts
            % everything as cell, cascading errors in GLM. 
            if strcmp(eyeVar, 'displacement')
                eyeTsv.displacement(1) = 0;
            end

            % take the variable name and add it to the json file
            eval(['preprocJson.' eyeVar ' = '''';']);

            % take the values corresponding to the variable and add them to
            % the preprocTsv and motionTsv
            eval(['preprocTsv.' eyeVar ' = eyeTsv.' eyeVar ';']);    
            eval(['motionTsv.' eyeVar ' = eyeTsv.' eyeVar ';']);

        end

        % save each preproc file
        writetable(preprocTsv, fullfile(preprocTsvList(iFile).folder, preprocTsvList(iFile).name), 'filetype','text', 'delimiter','\t');
        writetable(motionTsv, fullfile(motionTsvList(iFile).folder, motionTsvList(iFile).name), 'filetype','text', 'delimiter','\t');
        preprocJson = jsonencode(preprocJson, 'PrettyPrint', true);
        % workaround: save a new file, then rename it
        fclose(fid);
        tempFID = fopen(fullfile(preprocJsonList(iFile).folder, 'temp.json'),'w');
        fwrite(tempFID, preprocJson);
        fclose(tempFID);

        % delete old file, rename new one
        delete(fullfile(preprocJsonList(iFile).folder, preprocJsonList(iFile).name));
        movefile(fullfile(preprocJsonList(iFile).folder, 'temp.json'), fullfile(preprocJsonList(iFile).folder, preprocJsonList(iFile).name));

    end
end















