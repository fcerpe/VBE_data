%% Create ROIs based on peak coordinates from thesingle subjects
%
% Script from Iqra: tmpCreateROIs and marsbar_create_ROIs merged together
%
% Steps:
% 1 - open bspmview Manually get the peak coordinates in each subject for each ROI
% 2 - load sub-XXX_contrast_spmT.nii
% 3 - go near your ROI and right-click to "nearest peak"
% 3B- for LOC and pFS, applied coordinates from Neurosynth and
%     chose the highest peak 
%     * (LOC: -46 -70 -5  and 42 -50 -20)
%     * (pFS: -40 -54 -18 and 42 -50 -20)
% 4 - save coordinates below
% 5 - run section-by-section
%
% sub-001
% vwfa  [-46.8  -70.4   -12.8]
% LOC-L [-46.8  -67.8    0.2]
% PFS-L [-33.8  -57.4   -20.6]
% LOC-R [ 49.4  -62.8   -5]
% PFS-R [ 36.4  -57.4   -20.6] 
%
% sub-002
% vwfa  [-49.4  -57.4   -12.8]
% LOC-L [-46.8  -62.6   -7.6]
% PFS-L [-46.8  -80.8   -2.4]
% LOC-R [ 46.8  -70.4   -5]
% PFS-R [ 41.6  -65.2   -15.4]
%
% sub-003
% vwfa  [-49.4  -60     -20.6]
% LOC-L [-39    -73     -2.4] 
% PFS-L [-28.6  -52.2   -15.4] 
% LOC-R [ 44.2  -80.8   -5]    
% PFS-R [ 31    -47     -20.6]
%
% mni{sub_number}(contrast number, coordinates)
% mni{1}= [-46 64 4]

%% clear
clear;
clc;
%% visual Localizer
% LO1 and LO2 come from: Larsson and Heeger, 2006 (jneurosci)
%                        Sayres and Grill-Spector, 2008 (jnp)
%
% SUB-001
mni{1}(1,1:3)= [-4.680000e+01, -7.040000e+01, -1.280000e+01];  % VWFA
mni{1}(2,1:3)= [-4.680000e+01, -6.780000e+01,  0.020000e+01];  % LOC LEFT
mni{1}(3,1:3)= [-3.380000e+01, -5.740000e+01, -2.060000e+01];  % PFS LEFT
mni{1}(4,1:3)= [ 4.940000e+01, -6.280000e+01, -0.500000e+01];  % LOC RIGHT
mni{1}(5,1:3)= [ 3.640000e+01, -5.740000e+01, -2.060000e+01];  % PFS RIGHT

% SUB-002
mni{2}(1,1:3)= [-4.940000e+01, -5.740000e+01, -1.280000e+01];  % VWFA
mni{2}(2,1:3)= [-4.680000e+01, -6.260000e+01, -0.760000e+01];  % LOC LEFT
mni{2}(3,1:3)= [-4.680000e+01, -8.080000e+01, -0.240000e+01];  % PFS LEFT
mni{2}(4,1:3)= [ 4.680000e+01, -7.040000e+01, -0.500000e+01];  % LOC RIGHT
mni{2}(5,1:3)= [ 4.160000e+01, -6.520000e+01, -1.540000e+01];  % PFS RIGHT

% SUB-003
mni{3}(1,1:3)= [-4.940000e+01, -6.000000e+01, -2.060000e+01];  % VWFA
mni{3}(2,1:3)= [-3.900000e+01, -7.300000e+01, -0.240000e+01];  % LOC LEFT
mni{3}(3,1:3)= [-2.860000e+01, -5.220000e+01, -1.540000e+01];  % PFS LEFT
mni{3}(4,1:3)= [ 4.420000e+01, -8.080000e+01, -0.500000e+01];  % LOC RIGHT
mni{3}(5,1:3)= [ 3.100000e+01, -4.700000e+01, -2.060000e+01];  % PFS RIGHT


ROI_name_list = {'VWFA-Left','LOC-Left','PFS-Left','LOC-Right','PFS-Right'};

save('visROI_mni_coordinates.mat','ROI_name_list','mni')

%% MarsBar
% warning('off');
% addpath(genpath('/Users/battal/Documents/MATLAB/spm12'));
% bspm fmri
% addpath(genpath('/Users/shahzad/Documents/MATLAB/bspmview'));


% add cpp repo
run ../lib/CPP_SPM/initCppSpm.m;

% Radius of the sphere around the peak
radius = 10; % mm, to confirm with Hans e Oli

% Another manual step, apparently it does not work well code-wise
% In casewe want to give it a shot, run these:
% MARS.OPTIONS.spacebase.fname =  fullfile(pwd,'template.nii');
% MARS.OPTIONS.spacebase.fname =  t-contrast image

marsbar

%% Get the ROIs (actually just the spheres)

for iSub = 1:length(mni)
    
    % Get subject name, in our single ROI is the row with the coordinates
    subName = ['sub-00',num2str(iSub)];
    
    % If there is actually something there
    if ~isnan(mni{iSub})
        
        for iReg = 1:size(mni{iSub},1) % for each region this subject has
            % Get the center
            ROI_center = mni{iSub}(iReg,:);
                       
            switch iReg
                case 1
                    regHemi = 'L';
                    regName = 'VWFA';
                case 2
                    regHemi = 'L';
                    regName = 'LOC';
                case 3
                    regHemi = 'L';
                    regName = 'pFS';
                case 4
                    regHemi = 'R';
                    regName = 'LOC';
                case 5
                    regHemi = 'R';
                    regName = 'pFS';
            end
             
            % Set up bids-like name
            % ROI_save_name = [subName,'_', regionName,'_',num2str(radius),'mm'];
            ROI_save_name = [subName,'_','hemi-',regHemi,'_','space-MNI','_','label-',regName,'_','radius-',num2str(radius),'mm','_mask'];
            
            % create the sphere with marsbar and save it
            params = struct('centre', ROI_center , 'radius', radius);
            roi = maroi_sphere(params);
            saveroi(roi, [ROI_save_name,'.mat']);
            mars_rois2img([ROI_save_name,'.mat'],[ROI_save_name,'.nii'])
            
            % Delete .mat files, not necessary
            delete([ROI_save_name,'_labels.mat']);
            delete([ROI_save_name,'.mat'])
            
        end
    end
end

% end

%sub-01_space-individual_hemi-L_label-V1d_desc-wang_mask.nii


