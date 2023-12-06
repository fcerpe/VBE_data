% rearrange Filippo's data format for ANOVA

clear data_splitplot_VWFA

% Read data
homedir = '/Users/hansopdebeeck/data/'
dataFile1 = 'decoding-pairwise-within-script_grp-experts_rois-expansionIntersection_nbvoxels-43.csv';
dataFile2 = 'decoding-pairwise-within-script_grp-controls_rois-expansionIntersection_nbvoxels-43.csv';

% Put all data in new data file
data1 = readtable([homedir dataFile1]);
data2 = readtable([homedir dataFile2]);
data1.group = zeros(size(data1,1),1);
data2.group = 1 + zeros(size(data2,1),1);
data_all = [data1;data2];

% Make new matrix for doing splitplot design
% all on beta
% one matrix per ROI
% one row per participant
% first column will be subject number
% between-subject = group variable, will be second column
% within-subject = script x condition, wil be 12 columns

nr_subj_expert = 6;
nr_subj_control = 11;
nr_cond = 12;
variant = 1; % which ROI & beta/t; 1 = VWFAfr & beta 
nr_rows_subj = 72; % how many rows per participant 
data_splitplot_VWFA = table();
for s = 1:nr_subj_expert + nr_subj_control,
    data_splitplot_VWFA.subID(s) = data_all.subID((s-1)*nr_rows_subj + 1);
    data_splitplot_VWFA.group(s) = data_all.group((s-1)*nr_rows_subj + 1);
        data_splitplot_VWFA.frw_v_fpw(s) = data_all.accuracy((s-1)*nr_rows_subj + 1);
        data_splitplot_VWFA.frw_v_fnw(s) = data_all.accuracy((s-1)*nr_rows_subj + 2);
        data_splitplot_VWFA.frw_v_ffs(s) = data_all.accuracy((s-1)*nr_rows_subj + 3);
        data_splitplot_VWFA.fpw_v_fnw(s) = data_all.accuracy((s-1)*nr_rows_subj + 4);
        data_splitplot_VWFA.fpw_v_ffs(s) = data_all.accuracy((s-1)*nr_rows_subj + 5);
        data_splitplot_VWFA.fnw_v_ffs(s) = data_all.accuracy((s-1)*nr_rows_subj + 6);
        data_splitplot_VWFA.brw_v_bpw(s) = data_all.accuracy((s-1)*nr_rows_subj + 7);
        data_splitplot_VWFA.brw_v_bnw(s) = data_all.accuracy((s-1)*nr_rows_subj + 8);
        data_splitplot_VWFA.brw_v_bfs(s) = data_all.accuracy((s-1)*nr_rows_subj + 9);
        data_splitplot_VWFA.bpw_v_bnw(s) = data_all.accuracy((s-1)*nr_rows_subj + 10);
        data_splitplot_VWFA.bpw_v_bfs(s) = data_all.accuracy((s-1)*nr_rows_subj + 11);
        data_splitplot_VWFA.bnw_v_bfs(s) = data_all.accuracy((s-1)*nr_rows_subj + 12);
end;

writetable(data_splitplot_VWFA,[homedir 'data_splitplot_VWFA']);



% data_splitplot_VWFA.frw_v_fpw(s) = data_all.decodingCondition((s-1)*nr_rows_subj + 1);



