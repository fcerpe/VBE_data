%% Intra-brain RSA
%
% #   For CoSMoMVPA's copyright information and license terms,   #
% #   see the COPYING file distributed with CoSMoMVPA.           #

clear;
clc;

% cosmo
cosmo = '~/Applications/CoSMoMVPA';
addpath(genpath(cosmo));
cosmo_warning('once');

% libsvm
libsvm = '~/Applications/libsvm';
addpath(genpath(libsvm));

% verify it worked
cosmo_check_external('libsvm');

% add bidspm repo
addpath '../lib/bidspm'
bidspm;

% Get options
opt = mvpa_option();

%% Define subjects, ROIs, tasks to work on
% subjects to analyze
subID = '006';

subList = opt.subjects{subID};

taskLabel = {'wordsDecoding'}; %'Aud', 'Vis'
modelLabel = {'Cons'}; %'Cons','Speak','Vowels','trialbytrial'
roiLabel = {'VWFAfr'};%, 'ppaL'}; --> at the moment just one roi : we'll see what it gives. %, 'ffaR', 'ffaL', 'ppaR', 'ppaL', 'phonoL', 'phonoR'

for iRoi = 1:length(roiLabel)

    roi = roiLabel{iRoi};
    model = modelLabel{1};
    task = taskLabel{1};

    for iSub = numel(subList)

        subID = ['sub-', subList{iSub}];

        % get 4D file
        data_img = fullfile(opt.dir.stats, subID, 'task-wordsDecoding_space-IXI549Space_FWHM-2_node-mvpaGLM', ...
                            strcat(subID, '_task-', taskLabel, '_space-IXI549Space_desc-4D_beta.nii'));

        % Pick ROI
        if strcmp(roi, 'VWFAfr')
            D = fullfile(opt.dir.rois, subID, ['r' subID '*_method-expansionIntersection_label-' roi '_mask.nii']);

        end

        % Get the path and name of this mask to use in the function getDataFromExpansion
        roi_img = fullfile(D.folder, D.name);

        % prepare the structure of the dataset
        % for cons/speak/vow
        targets1M = repmat(1:3, 1, str2num(sub_all(iSub).Nrun))'; %there are 3 consonants (mean value for the 9 iteration of the cons), and each is repeated in each run.
        targets1M = sort(targets1M);
        targets = cat(1, targets1M, targets1M);

        chunks1M = repmat(1:str2num(sub_all(iSub).Nrun), 1, 3)';
        chunks2M = repmat((1:str2num(sub_all(iSub).Nrun))+str2num(sub_all(iSub).Nrun), 1, 3)';
        chunks = cat(1, chunks1M, chunks2M); %changed here last time !!!!

        modality = repmat(1:2, 1, str2num(sub_all(iSub).Nrun)*3)'; %There are 2 modalities (Aud AND Vis), and we have to repeat this *3(for each cons) and *Nrun for each run (usually 19 or 20) = usually 114 or 120
        modality = sort(modality);


        data_img1 = '/Volumes/T7 Shield/DATA_HD/LipSpeech/Lip_BIDS/derivatives/bidspm-stats/sub-27/task-MVPAAud_space-IXI549Space_FWHM-2_node-MVPAAudCons/sub-27_task-MVPAAud_space-IXI549Space_desc-4D_beta.nii';
        data_img2 = '/Volumes/T7 Shield/DATA_HD/LipSpeech/Lip_BIDS/derivatives/bidspm-stats/sub-27/task-MVPAVis_space-IXI549Space_FWHM-2_node-MVPAVisCons/sub-27_task-MVPAVis_space-IXI549Space_desc-4D_beta.nii';
        ds1 = cosmo_fmri_dataset(data_img1, 'mask', roi_img);
        ds2 = cosmo_fmri_dataset(data_img2, 'mask', roi_img);

        ds = cosmo_fmri_dataset(data_img, ...
            'mask', roi_img,...
            'chunks', chunks, ...
            'targets',targets);

        ds.samples = [ds1.samples; ds2.samples];

        %% IF I WANT TO PUT ALL SAME RUNS FOLLOWING EACH OTHERS, I NEED TO DO IT WITH THIS
        n_run  = str2num(sub_all(iSub).Nrun);
        idx_RUN1=(1:n_run:length(targets1M));
        idx_RUN2=(2:n_run:length(targets1M));
        idx_RUN3=(3:n_run:length(targets1M));
        idx_RUN4=(4:n_run:length(targets1M));
        idx_RUN5=(5:n_run:length(targets1M));
        idx_RUN6=(6:n_run:length(targets1M));
        idx_RUN7=(7:n_run:length(targets1M));
        idx_RUN8=(8:n_run:length(targets1M));
        idx_RUN9=(9:n_run:length(targets1M));
        idx_RUN10=(10:n_run:length(targets1M));
        idx_RUN11=(11:n_run:length(targets1M));
        idx_RUN12=(12:n_run:length(targets1M));
        idx_RUN13=(13:n_run:length(targets1M));
        idx_RUN14=(14:n_run:length(targets1M));
        idx_RUN15=(15:n_run:length(targets1M));
        idx_RUN16=(16:n_run:length(targets1M));
        idx_RUN17=(17:n_run:length(targets1M));
        idx_RUN18=(18:n_run:length(targets1M));
        idx_RUN19=(19:n_run:length(targets1M));
        idx_RUN20=(20:n_run:length(targets1M));
        idx_RUN21=(61:n_run:length(targets1M)+60);
        idx_RUN22=(62:n_run:length(targets1M)+60);
        idx_RUN23=(63:n_run:length(targets1M)+60);
        idx_RUN24=(64:n_run:length(targets1M)+60);
        idx_RUN25=(65:n_run:length(targets1M)+60);
        idx_RUN26=(66:n_run:length(targets1M)+60);
        idx_RUN27=(67:n_run:length(targets1M)+60);
        idx_RUN28=(68:n_run:length(targets1M)+60);
        idx_RUN29=(69:n_run:length(targets1M)+60);
        idx_RUN30=(70:n_run:length(targets1M)+60);
        idx_RUN31=(71:n_run:length(targets1M)+60);
        idx_RUN32=(72:n_run:length(targets1M)+60);
        idx_RUN33=(73:n_run:length(targets1M)+60);
        idx_RUN34=(74:n_run:length(targets1M)+60);
        idx_RUN35=(75:n_run:length(targets1M)+60);
        idx_RUN36=(76:n_run:length(targets1M)+60);
        idx_RUN37=(77:n_run:length(targets1M)+60);
        idx_RUN38=(78:n_run:length(targets1M)+60);
        idx_RUN39=(79:n_run:length(targets1M)+60);
        idx_RUN40=(80:n_run:length(targets1M)+60);

        idx_ALL=[idx_RUN1,idx_RUN2,idx_RUN3,idx_RUN4,idx_RUN5,idx_RUN6,idx_RUN7,idx_RUN8,idx_RUN9,idx_RUN10,idx_RUN11,idx_RUN12,idx_RUN13,idx_RUN14,idx_RUN15,idx_RUN16,idx_RUN17,idx_RUN18,idx_RUN19,idx_RUN20, ...
            idx_RUN21,idx_RUN22,idx_RUN23,idx_RUN24,idx_RUN25,idx_RUN26,idx_RUN27,idx_RUN28,idx_RUN29,idx_RUN30,idx_RUN31,idx_RUN32,idx_RUN33,idx_RUN34,idx_RUN35,idx_RUN36,idx_RUN37,idx_RUN38,idx_RUN39,idx_RUN40];

        %traspose from row to col
        idx_ALL=idx_ALL';

        %here create the new order of ds.samples based on the indexes
        new_samples_order=ds.samples(idx_ALL,:);

        %swap the old samples with the new onces
        ds.samples=new_samples_order;

        %% If need compute average for each unique run, so that the dataset has only 20 val
        % samples - one for each chunk
        % ds=cosmo_fx(ds, @(x)mean(x,1), 'chunks', 1);

        % remove constant features
        ds=cosmo_remove_useless_data(ds);

        %% Set labels
        % for labels with 3 targets from 1 run averaged
        A = repmat(('Arun-' + string(1:str2num(sub_all(iSub).Nrun))), 3, 1);
        A = A(:)';
        V = repmat(('Vrun-' + string(1:str2num(sub_all(iSub).Nrun))), 3, 1);
        V = V(:)';
        labels = [A V];

        % for labels with targets not averaged
        % F = ('f' + string(1:str2num(sub_all(s).Nrun)));
        % L = ('l' + string(1:str2num(sub_all(s).Nrun)));
        % P = ('p' + string(1:str2num(sub_all(s).Nrun)));
        % labels = [F L P];


        % simple sanity check to ensure all attributes are set properly
        cosmo_check_dataset(ds);

        samples=ds.samples;
        % comment the line under here if you don't want to subtract the mean
        %samples=bsxfun(@minus,samples,mean(samples,1));


        % Use pdist (or cosmo_pdist) with 'correlation' distance to get DSMs
        % in vector form.
        % dsm = pdist(samples, 'euclidean');
        dsm = pdist(samples, 'spearman');
        NORMdsm=mat2gray(dsm);
        %NORMdsm=dsm;

        %% save outputs
        %save (strcat(sub(isub).id(end-3:end),'_brainDSM_all.mat'), 'dsm','NORMdsm');
        %end

        % cd (output_path)
        %
        %
        % %%Save the mat fil with all the C1B's brain DSMs
        % meanC1B_dsm = mean(C1B_vec); %create a mean vector of all the sub values
        % meanVEC= meanC1B_dsm;
        % meanC1B_dsm = squareform (meanC1B_dsm); %give the matrix form to the mean vector
        %save ((strcat('C1B_',masks{mask_num},'_dsm.mat')),'C1B_vec','meanC1B_dsm','meanVEC');
        %
        % %%Save the mat fil with all the Groups brain DSMs
        % save ((strcat('ALL_',masks{mask_num},'_dsm.mat')),'all_VEC');
        % cd (study_path)


        %% Plot the mean DSM

        figure();
        % % % % subplot(2,5,s);
        %suptitle(masks(mask_num));
        set(gcf,'color','w');
        %subplot(2,2,mask_num);
        imagesc(squareform(NORMdsm));  title (subID); %colorbar;
        set(gca, 'YTick',(1:length(targets)),'YTickLabel',labels);
        set(gca, 'XTick',(1:length(targets)),'XTickLabel',labels);
        xtickangle(90);
        ax=gca;
        set(ax,'FontName','Avenir','FontSize',8, 'FontWeight','bold',...
            'LineWidth',2.5,'TickDir','out', 'TickLength', [0,0]);

        % NORMdsm_all(isub,:)=NORMdsm;
    end
end
