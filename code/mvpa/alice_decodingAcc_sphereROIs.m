clear all

%% Define dir&paths
mvpa_dir = fileparts(mfilename('fullpath'));
roi_dir = fullfile(mvpa_dir, 'ROIs', 'expand-withinmask'); %or 'expand-sphere'
output_dir = fullfile(mvpa_dir, 'Decoding_acc');

lipspeech_dir = fullfile(mvpa_dir, '..'); %root dir
bids_dir = fullfile(lipspeech_dir, 'Lip_BIDS');
stats_dir = fullfile(bids_dir, 'derivatives', 'bidspm-stats');

%% Define subjects, ROIs, tasks to work on

sub_all=sub_data; %call function in same dir named sub_data.m - with all info on each subject
nsub_all = length(sub_all);



sub_no = [4:24 26]; %which subjects to analyze ? 
sub_list = sub_all(sub_no);
nsub = length(sub_list);

task_label = {'Vis', 'Aud'}; %'Aud', 'Vis'
model_label = {'Cons'}; %'Cons','Speak','Vowels','Trialbytrial'
roi_label = {'vwfa', 'ppaL'};%, 'ffaR', 'ffaL', 'ppaR', 'ppaL', 'phonoL', 'phonoR'

algo = 'svm'; %'lda' or 'svm'
val = 'beta'; %or 'beta' ?

numFeatures=200; % in decoding, you can take the whole ROI, or a fixed number of voxels. (decoding is affected by the size of the ROI). It will choose the 120 most informative voxels for decoding. 

doPermut = 1; %if you don't want to run permutation part, change to 0
nbIter = 100; % number of iterations for the permutation part

% ext = '.nii';
% ext = '.img';

%% Load data
% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %ROI={'rAngular_aal'};
% % % %ROI={'rROI_V1_prova_MNI'};
% % % %ROI={'rrleftVWFA_Neurosynth'};
% % % %ROI = {'rrV5_Battal'};
% % % ROI = {'rphono_Neurosynth'};
% % % %ROI = {'/Indiv_cluster/lTempCluster-PhonoLoc_tresh-5_sub-04'};
% % % ROI = {'/Indiv_cluster/postSupCluster-PhonoLoc_tresh-5_sub-04'};
% % % %ROI = {'/ROIs_expand/rclusterWord-VisLoc_pt05-unc_sub-04_label-expandVox153_mask'};




%for the moment, one ROI at the time
%but the script is made to run several ROIs with ROI = {'...', '...', '...'};

%data (tmap) to use ? in the directory 4D-files 


%%%To run all the possible pair of binary classification in one loop
for t=1:length(task_label)  
    task = task_label{t};
% %     %% Define data
% %     %config=cosmo_config();
% %     study_path= '/Users/alice/Documents/DATA/LipSpeechPilot_analysis/LipSpeech_mvpa_testsub04';
% %     masks_path = fullfile(study_path,'masks');
    
    for m=1:length(model_label)
        model = model_label{m};
        
        %%% preallocate for saving later
        MEAN_confusion_matrix= zeros(3,3); %if you want something else than binary 
        %decoding, you have to change the matrix (if 6 conditions, matrix 6 by 6)

        Acc_allROIs = zeros(nsub_all, length(roi_label));
        nFeatures_allROIs = zeros(nsub_all, length(roi_label));          
        nullAcc_allROIs = zeros(nbIter, length(roi_label), nsub_all); 
        p_allROIs = zeros(nsub_all, length(roi_label));
        

        for r=1:length(roi_label)
            roi = roi_label{r};
            
            
            for s = sub_no 
                sub_name= (sub_all(s).id);
                
                %in this case (08/10/23) the roi is already resliced and same name for  all sub ! 
                %so skip the step below and just run this line : 
                if strcmp(roi, 'vwfa')
                    file_name = 'rlabel-expandVox200_rvwfa-neurosynthCluster_mask.nii';
                elseif strcmp(roi, 'ppaL')
                    file_name = 'rlabel-expandVox200_Left-cluster_houses-gtothers_pt001-unc_mask.nii';
                end 
                roi_img = fullfile(roi_dir, sub_name, file_name);
                
                
% %                 %see if roi image already resliced or not
% %                 lookfor = dir(fullfile(roi_dir, sub_name,['r', roi, '*']));
% %                 if isfile(fullfile(roi_dir, sub_name, lookfor.name))
% %                     %if yes, take this resliced image
% %                     roi_img = fullfile(roi_dir, sub_name, lookfor.name);
% %                 else 
% %                     %if no, reslice roi image
% %                     roifile = dir(fullfile(roi_dir, sub_name,[roi, '*']));
% %                     imageToCheck = fullfile(roi_dir, sub_name, roifile(2).name);              
% %                     referenceImage = fullfile(mvpa_dir, 'ROIs/Masks/reference_image_for_reslice.nii'); % choose any image from the scanner that will be used with the mask.
% %                     roi_img = resliceRoiImages(referenceImage, imageToCheck, 0);
% %                 end 
                
                
                working_on=strcat('best', num2str(numFeatures), ...
                    '_', algo, '_MVPA', task, '_', model); %we usually use 2-3 types of classifiers (lda, svm -which takes more time, not ideal for searchlight-). It changes the way the algorithm works, but we don't go in the detail of that. 
        
                disp(strcat(sub_name, '___DECODING IN:', roi, '___FOR:', working_on));
                
                %load 4D file
                data_img=fullfile(stats_dir, sub_name, ...
                    strcat('/task-MVPA', task, '_space-IXI549Space_FWHM-2_node-MVPA', task, model), ...
                    strcat(sub_name, '_task-MVPA', task, '_space-IXI549Space_desc-4D_', val, '.nii'));
                

                % !!!! very important part of the script !! 
                % is based on the tsv file that you get in the folder BIDS
                % derivatives/stats/sub-XX/ ...._labelfold.tsv
                % it gives the order of the chunks and targets for the matrix after. 
                % 
                %prepare the targets 
                targets=repmat(1:3,1,str2num(sub_all(s).Nrun))'; %there are 3 consonants (mean value for the 9 iteration of the cons), and each is repeated in each run. 
                targets= sort(targets); %comment this line if want to see a "random" decoding - labels will not correspond anymore


                chunks = repmat(1:str2num(sub_all(s).Nrun), 1, 3)';
                ds = cosmo_fmri_dataset(data_img, ... 
                                                'mask', roi_img,...
                                                'targets',targets, ...
                                                'chunks',chunks); %uses target and chunk structure that we just did


                % remove constant features (due to liberal masking)
                ds=cosmo_remove_useless_data(ds); %removes voxels that have constant values (e.g. outside the brain, white matter, csf etc)

                measure= @cosmo_crossvalidation_measure;

                % Make a struct containing the arguments for the measure:
                args=struct();
                
                %choose classifier to use. Default is lda
                if strcmp(algo, 'svm') 
                    args.child_classifier = @cosmo_classify_svm;
                else 
                    args.child_classifier = @cosmo_classify_lda; 
                end  

                args.output='predictions'; %output results : how they are classified or not
                args.normalization = 'zscore';%'demean'; %we decided in the lab to normalize in zscore and not demean. 
                args.feature_selector=@cosmo_anova_feature_selector; %it will select the most informative voxels (features = voxels)

             % if not enough voxels (=features), the script gives an error. so here under, if the ROI is smaller than it will take all the voxels.     
                n=size(ds.samples);
                n_features=n(2);
                if  n_features<numFeatures
                 args.feature_selection_ratio_to_keep =  n_features;
                else
                args.feature_selection_ratio_to_keep = numFeatures;% thats for the feature selection
                end
                disp('Num features used :'); %to have a feedback in case there is a bug 
                disp(args.feature_selection_ratio_to_keep);
                %args.max_feature_count=6000; %automatycallly Cosmo set the limit at 5000,
                %open if your ROI is bigger
                partitions = cosmo_nfold_partitioner(ds); %how to divide the runs ??? we can do even and odd but it gives only 1 result. But what we prefer to do is to do run 1-against all, run 2-against all, run 3-against all etc. and then mean the 12 results. 

                % Apply the measure to ds, with args as second argument. Assign the result
                % to the variable 'ds_accuracy'.
                ds_accuracy = cosmo_crossvalidate(ds,@cosmo_meta_feature_selection_classifier,partitions,args);
                ds_accuracy = reshape(ds_accuracy', 1, []);
                ds_accuracy = ds_accuracy(~isnan(ds_accuracy))';
                %ds_accuracy is a list of each target (in the order defined by
                %label_fold.tsv) and the result of the classifier for each target. For
                %example, target one has been classified as a condition "2"
                %(uncorrect, it is a condition 1). 

                cosmo_warning('off');
                %if sub(isub).Nrun=='4'
                %ds_accuracy =[ds_accuracy(1:12,1);ds_accuracy(13:24,2);ds_accuracy(25:36,3);ds_accuracy(37:48,4)];
                %else
                %ds_accuracy =[ds_accuracy(1:12,1);ds_accuracy(13:24,2);ds_accuracy(25:36,3);ds_accuracy(37:48,4);ds_accuracy(49:60,5)];
                %end
                confusion_matrix=cosmo_confusion_matrix(targets,ds_accuracy); 
                %we take the ds_accuracy vector and put the results in a vector: how
                %many targets of condition 1 where classified as condition 1, as
                %cdition 2 and as condition 3 ... then same for targets of cdtion 2 and
                %3. 


                %confusion_matrix=cosmo_confusion_matrix(ds_accuracy.sa.targets,ds_accuracy.samples);
                sum_diag=sum(diag(confusion_matrix));
                sum_total=sum(confusion_matrix(:));
                accuracy=sum_diag/sum_total; %general accuracy of decoding is calculated like that !! sum_diag/sum_total
                disp(strcat ('Accuracy:',num2str(accuracy)));
                
                 %% Run permutation part (from Jacek https://github.com/JacMatu/ReadSpeech_MVPA/blob/main/code/src/cosmo-mpva/cosmomvpaRoiCrossValidation_ReadSpeech.m)
                
                %% PERMUTATION PART
                if doPermut  == 1

                    % allocate space for permuted accuracies
                    nullAcc = zeros(nbIter, 1);

                    % make a copy of the dataset for null distribution
                    ds0 = ds;

                    % for *nbIter* iterations, reshuffle the labels and compute accuracy
                    for k = 1:nbIter
                        % shuffle with function cosmo_randomize_targets
                        ds0.sa.targets = cosmo_randomize_targets(ds);
  
                          %let's start random decoding
                          [~, nullAcc(k)] = cosmo_crossvalidate(ds0, ...
                                                         @cosmo_meta_feature_selection_classifier, ...
                                                         partitions, args);
                    end

                    % sum(A<B) calculates how many times B (vector) is greater than A (number)
                    p = sum(accuracy < nullAcc) / nbIter;
                    fprintf('%d permutations: accuracy=%.3f, p=%.4f\n', nbIter, accuracy, p);
  

                
                end

                %% save results
                Acc_allROIs(s,r)=accuracy;
                nFeatures_allROIs(s,r) = args.feature_selection_ratio_to_keep; 
                if doPermut ==1
                    nullAcc_allROIs(:,r, s) = nullAcc;
                    p_allROIs(s,r) = p;
                end
                
                

                % print classification accuracy in terminal window
            %    fprintf('%s\n',desc);
                % Show the result
                %fprintf('\nOutput dataset (with classification accuracy)\n');
                % Show the contents of 'ds_accuracy' using 'cosmo_disp'
                %cosmo_disp(ds_accuracy);

                MEAN_confusion_matrix=MEAN_confusion_matrix + confusion_matrix; %add the new confusion matrix to the other ones. It is a sum, so after that you need to divide by the number of subjects to get the mean. 

                
            end 
            save(strcat(output_dir, '/', model, '/NEW--mask-200vx_decoding_', working_on, val), ...
                'Acc_allROIs', 'nFeatures_allROIs', 'MEAN_confusion_matrix', 'roi_label', 'nullAcc_allROIs', 'p_allROIs');%, 
%             csvwrite(strcat(output_dir, '/', model, '/decoding_', working_on),Acc_all)
        end 
    end

    %%%% NEEDS TO BE ADAPTED WHEN I WILL HAVE SEVERAL SUBJECTS AND WILL WANT TO
    %%%% SEE THE MEAN MATRICES
    %for the moment, keep it like that & I will see later how it works. 

    % %%To create the group mean matrices
    % HNS_MEAN_confusion_matrix=HNS_MEAN_confusion_matrix/1 %averaging all the
    % matrices that were put together and plot it. 
    % HLS_MEAN_confusion_matrix=HLS_MEAN_confusion_matrix/1 %divided it by num of CAT
    %HES_MEAN_confusion_matrix=HES_MEAN_confusion_matrix/1 %divided it by num of C1B

    % %%visualize the  mean matrices
    % HNS_sum_diag=sum(diag(HNS_MEAN_confusion_matrix));
    % HNS_sum_total=sum(HNS_MEAN_confusion_matrix(:));
    % HNS_accuracy=HNS_sum_diag/HNS_sum_total;
    % 
    % HNS_percMEAN_DSM= (HNS_MEAN_confusion_matrix).*100./24 %%24 is the total number of repetition for each category item (e.g. 24 faces)!!!!!!TO BE CHECKED!!!!!
    % figure();
    % subplot(1,4,1);
    % imagesc(HNS_percMEAN_DSM)
    % classifier_name='svm'; % no underscores
    % desc=sprintf('CON  %s: accuracy %.1f%%', classifier_name, HNS_accuracy*100);
    % title(desc)
    % nclasses=numel(classes);
    % set(gca,'XTick',1:nclasses,'XTickLabel',classes);
    % set(gca,'YTick',1:nclasses,'YTickLabel',classes);
    % ylabel('target');
    % xlabel('predicted');
    % colorbar


    % HLS_sum_diag=sum(diag(HLS_MEAN_confusion_matrix));
    % HLS_sum_total=sum(HLS_MEAN_confusion_matrix(:));
    % HLS_accuracy=HLS_sum_diag/HLS_sum_total;
    % 
    % HLS_percMEAN_DSM= (HLS_MEAN_confusion_matrix).*100./(length(ds.sa.targets)/2) %%24 is the total number of repetiiton for each category item (e.g. 24 birds)
    % 
    % subplot(1,4,2);
    % imagesc(HLS_percMEAN_DSM)
    % classifier_name='lda'; % no underscores
    % desc=sprintf('CAT  %s: accuracy %.1f%%', classifier_name, HLS_accuracy*100);
    % title(desc)
    % 
    % nclasses=numel(classes);
    % set(gca,'XTick',1:nclasses,'XTickLabel',classes);
    % set(gca,'YTick',1:nclasses,'YTickLabel',classes);
    % ylabel('target');
    % xlabel('predicted');
    % colorbar
    % 
    % C1B_sum_diag=sum(diag(HES_MEAN_confusion_matrix));
    % C1B_sum_total=sum(HES_MEAN_confusion_matrix(:));
    % C1B_accuracy=C1B_sum_diag/C1B_sum_total;
    % 
    % C1B_percMEAN_DSM= (HES_MEAN_confusion_matrix).*100./(length(ds.sa.targets)/2) %%24 is the total number of repetiiton for each category item (e.g. 24 birds)
    % 
    % subplot(1,4,3);
    % imagesc(C1B_percMEAN_DSM)
    % classifier_name='lda'; % no underscores
    % desc=sprintf('C1B  %s: accuracy %.1f%%', classifier_name, C1B_accuracy*100);
    % title(desc)
    % 
    % nclasses=numel(classes);
    % set(gca,'XTick',1:nclasses,'XTickLabel',classes);
    % set(gca,'YTick',1:nclasses,'YTickLabel',classes);
    % ylabel('target');
    % xlabel('predicted');
    % colorbar
    % 
    % HNS_accuracy= HNS_all_accuracy(1:17);
    % HLS_accuracy = HLS_all_accuracy(18:32);
    % C1B_accuracy = HES_all_accuracy(33:46);
    % meanALLgr= [mean(HNS_accuracy), mean(HLS_accuracy),mean(C1B_accuracy)];
    % subplot(1,4,4); bar(meanALLgr); 
    % labels={'CON','CAT','C1B'};
    % set(gca,'xticklabel',labels)
    % 
    % suptitle(ROIs_name);
    % 
    % all_accuracy =[HNS_all_accuracy;HLS_all_accuracy];
    % save(strcat(study_path,'/MVPA_ROI/results_2CAT_Neurocat3/',ROIs_name));
end%%for iroi