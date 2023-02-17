%% Readable Matrix
%
% From huge cosmomvpa output table to nice RDM-like matrices
% Valid for different sizes
% 1. divide table in struct

clear

warning('on')

% add spm to the path
addpath(fullfile(pwd, '..', 'lib', 'bidspm'));
addpath(fullfile(pwd, '..', 'lib', 'CPP_BIDS'));
bidspm;

opt = mvpa_option();

% go into derivatives/CoSMoMVPA to see how many decodings we have
filesToProcess = dir('../../outputs/derivatives/CoSMoMVPA/mvpa-pairwiseDecoding_task-wordsDecoding_method-ns-expansionIntersection_condition-pairwise_within_nbvoxels-*.mat');

%%
% 3 files: 85vx, 70vx, 50 vx
for ftp = 1:1 % :length(filesToProcess)

    load(fullfile(filesToProcess(ftp).folder, filesToProcess(ftp).name));
    filename = filesToProcess(ftp).name;
    filename = filename(1:end-4);

    % initialize everything to avoid they get cast as something else
    mvpa_results = [];    
    mvpa_results = struct;    
    mvpa_results.raw = struct;
    mvpa_results.raw.combined_VWFAfr_beta = []; 
    mvpa_results.raw.combined_VWFAfr_tmap = [];
    mvpa_results.raw.mean_VWFAfr_beta = []; 
    mvpa_results.raw.mean_VWFAfr_tmap = [];
    
    % create the directory where to store figures, need to do that manually
    mkdir(fullfile(filesToProcess(ftp).folder,'figures', filename))

    % notify the user
    fprintf('\nprocessing %s \n', filename);

    % CASE 'within_script'
    %  only within language decoding
    %
    % Example:
    %       FRW FPW FNW FFS BRW BPW BNW BFS
    %   FRW  .   N   N   N   .   .   .   .
    %   FPW  N   .   N   N   .   .   .   .
    %   FNW  N   N   .   N   .   .   .   .
    %   FFS  N   N   N   .   .   .   .   .
    %   BRW  .   .   .   .   .   N   N   N
    %   BPW  .   .   .   .   N   .   N   N
    %   BNW  .   .   .   .   N   N   .   N
    %   BFS  .   .   .   .   N   N   N   .
    %
    % Make it symmetrical, make a lot of NaN where there is no decoding
    % (N is a placeholder, if you actually get it as results, it's a problem)

    % smallest unit available: one ROI, one image, one subject
    % 6 pairwise comparisons * 2 scripts
    smallestUnit = 12;

    nCond = 8;

    for i = 1:smallestUnit:size(accu,2)

        % get chunk
        thisChunk = accu(i:i+smallestUnit-1);
        % get identifiers
        thisSub = accu(i).subID;
        thisMask = accu(i).mask;
        thisImage = accu(i).image;

        % save original in corresponding variable and its chunk
        pathString = ['mvpa_results.raw.sub', thisSub, '_', thisMask, '_', thisImage];
        eval([pathString ' = thisChunk;']);

        % Modify pathString: from 'raw' to 'mat'
        pathString(14:16) = 'mat';

        % Place every accuracy from struct to NxN matrix
        mvpaMat = mvpa_getMatrix(thisChunk, 0); 
        mvpaTri = mvpa_getMatrix(thisChunk, 1); % make triangular RDM for visualization
        % save rdm
        eval([pathString ' = mvpaMat;']);

        % Store the single subject in the average group, according to the relative area and the image
        eval(['mvpa_results.raw.combined_' thisMask '_' thisImage ' = horzcat(mvpa_results.raw.combined_' thisMask '_' thisImage ', thisChunk);']);

    end

    %% Get averages for area/image
    % notify the user
    fprintf('getting averages \n');

    decodingsToSample = fieldnames(mvpa_results.raw);

    eval(['templateStructure = [mvpa_results.raw.' decodingsToSample{end} '];']);
    fieldsToRemove = {'prediction','maskVoxNb','ffxSmooth','roiSource','decodingCondition','permutation','imagePath'};
    templateStructure = rmfield(templateStructure, fieldsToRemove);

    for j = 1:numel(decodingsToSample)
        % split the name to identify which decoding are we working with
        thisVar = decodingsToSample{j};
        splitVar = split(thisVar,'_');
        thisSub = splitVar{1}; thisMask = splitVar{2}; thisImage = splitVar{3};

        if startsWith(thisSub, 'combined') 

            eval(['currentAccuracies = [mvpa_results.raw.' decodingsToSample{j} '.accuracy];']);
            nbSubs = size(currentAccuracies,2)/12;
            currentAccuracies = reshape(currentAccuracies,12,nbSubs);
            meanAccuracies = mean(currentAccuracies,2);

            eval(['tempStruct = rmfield(mvpa_results.raw.sub006_' thisMask '_' thisImage ', "subID");']);
            for k = 1:12, [tempStruct(k).accuracy] = deal([meanAccuracies(k)]);
            end

            eval(['mvpa_results.raw.mean_' thisMask '_' thisImage ' = tempStruct;']);

            % get matrix and save it
            tempMat = mvpa_getMatrix(tempStruct, 0);
            tempMatTri = mvpa_getMatrix(tempStruct, 1);
            eval(['mvpa_results.mat.mean_' thisMask '_' thisImage ' = tempMat;']);

        else

            % 'mean' is before 'subXXX', we can do this in one single loop
            % take info from decodingsToSample and put them in templateStructure
            eval(['tempStruct = [mvpa_results.raw.' decodingsToSample{j} '];']);
            
            templateStructure(j-2).subID = thisSub;
            templateStructure(j-2).mask = tempStruct(1).mask;
            templateStructure(j-2).accuracy = mean([tempStruct.accuracy]);
            templateStructure(j-2).choosenVoxNb = tempStruct(1).choosenVoxNb;
            templateStructure(j-2).image = tempStruct(1).image;

        end


    end

    % save new means to the matrix
    mvpa_results.means = templateStructure;

    % SAVE SET with original and modified
    save([opt.dir.cosmo, '/', filename,'.mat'],'accu','mvpa_results');

end
