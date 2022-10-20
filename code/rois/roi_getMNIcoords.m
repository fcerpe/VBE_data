function mni = roi_getMNIcoords(subs)

% for each subject in subs return the coords

% WRITE-DOWN OF COORDINATES AF FOUND THEM ON SPM (COLLAPSABLE)
%
% sub-001 
% VWFA FRE  -46.8, -70.4, -12.8 
% VWFA BRA  
%  LO LEFT  -46.8, -67.8, 0.2   
% PFS LEFT  -33.8, -57.4, -20.6
%  LO RIGHT  49.4, -62.8, -5     
% PFS RIGHT  36.4, -57.4, -20.6  
% pSTG LEFT -52.0, -34.0, 2.8
%
% sub-002 
% VWFA FRE  -49.4, -57.4, -12.8 
% VWFA BRA
%  LO LEFT  -46.8, -62.6, -7.6  
% PFS LEFT  -46.8, -80.8, -2.4
%  LO RIGHT  46.8, -70.4, -5     
% PFS RIGHT  41.6, -65.2, -15.4  
% pSTG LEFT -49.4, -41.8, 5.4
%
% sub-003 
% VWFA FRE  -49.4, -60, -20.6  
% VWFA BRA
%  LO LEFT  -39, -73, -2.4     
% PFS LEFT  -28.6, -52.2, -15.4
%  LO RIGHT  44.2, -80.8, -5     
% PFS RIGHT  31, -47, -20.6
%
% sub-004 
% VWFA FRE 
% VWFA BRA
%  LO LEFT                     
% PFS LEFT
%  LO RIGHT                    
% PFS RIGHT                     
% pSTG LEFT
%
% sub-005 
% VWFA FRE -49.4, -62.6, -18.0   
% VWFA BRA
%  LO LEFT -44.2, -78.2, -7.6
% PFS LEFT -39.0, -62.6, -12.8 
%  LO RIGHT 36.4, -83.4, -10.2  
% PFS RIGHT 36.4, -52.2, -12.8
%
% sub-006 
% VWFA FRE -46.8, -60, -12.8 
% VWFA BRA -49.4, -62.6, -12.8
%  LO LEFT                     
% PFS LEFT
%  LO RIGHT   39, -67.8, -10.2 
% PFS RIGHT                     
%
% sub-007 
% VWFA FRE -52, -47, -18    
% VWFA BRA -52, -49.6, -18
%  LO LEFT                     
% PFS LEFT
%  LO RIGHT                     
% PFS RIGHT                     
%
% sub-008 
% VWFA FRE -52, -57.4, -20.6 
% VWFA BRA
%  LO LEFT                     
% PFS LEFT
%  LO RIGHT                     
% PFS RIGHT
%
% sub-009 
% VWFA FRE -44.2, -62.6, -15.4 
% VWFA BRA
%  LO LEFT                     
% PFS LEFT
%  LO RIGHT                     
% PFS RIGHT

% mni{sub_number}(contrast number, coordinates)
% e.g. mni{1}= [-46 64 4]
mni = cell(length(subs),1);

for i = 1:length(subs)

    switch subs{i}
        case '001' % SUB-001
            mni{i}(1, 1:3) = [-4.680000e+01, -7.040000e+01, -1.280000e+01];  % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];                                  % VWFA BRA
            mni{i}(3, 1:3) = [-4.680000e+01, -6.780000e+01,  0.020000e+01];  %  LO LEFT
            mni{i}(4, 1:3) = [-3.380000e+01, -5.740000e+01, -2.060000e+01];  % PFS LEFT
            mni{i}(5, 1:3) = [4.940000e+01, -6.280000e+01, -0.500000e+01];  %  LO RIGHT
            mni{i}(6, 1:3) = [3.640000e+01, -5.740000e+01, -2.060000e+01];  % PFS RIGHT

        case '002' % SUB-002
            mni{i}(1, 1:3) = [-4.940000e+01, -5.740000e+01, -1.280000e+01];  % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];                                  % VWFA BRA
            mni{i}(3, 1:3) = [-4.680000e+01, -6.260000e+01, -0.760000e+01];  %  LO LEFT
            mni{i}(4, 1:3) = [-4.680000e+01, -8.080000e+01, -0.240000e+01];  % PFS LEFT
            mni{i}(5, 1:3) = [4.680000e+01, -7.040000e+01, -0.500000e+01];  %  LO RIGHT
            mni{i}(6, 1:3) = [4.160000e+01, -6.520000e+01, -1.540000e+01];  % PFS RIGHT

        case '003' % SUB-003
            mni{i}(1, 1:3) = [-4.940000e+01, -6.000000e+01, -2.060000e+01];  % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];                                  % VWFA BRA
            mni{i}(3, 1:3) = [-3.900000e+01, -7.300000e+01, -0.240000e+01];  %  LO LEFT
            mni{i}(4, 1:3) = [-2.860000e+01, -5.220000e+01, -1.540000e+01];  % PFS LEFT
            mni{i}(5, 1:3) = [4.420000e+01, -8.080000e+01, -0.500000e+01];  %  LO RIGHT
            mni{i}(6, 1:3) = [3.100000e+01, -4.700000e+01, -2.060000e+01];  % PFS RIGHT

        case '004' % SUB-004
            mni{i}(1, 1:3) = [NaN NaN NaN];  % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];  % VWFA BRA
            mni{i}(3, 1:3) = [NaN NaN NaN];  %  LO LEFT
            mni{i}(4, 1:3) = [NaN NaN NaN];  % PFS LEFT
            mni{i}(5, 1:3) = [NaN NaN NaN];  %  LO RIGHT
            mni{i}(6, 1:3) = [NaN NaN NaN];  % PFS RIGHT

        case '005' 
            mni{i}(1, 1:3) = [-6.500000e+01, -4.180000e+01,  0.540000e+01];  % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];                                  % VWFA BRA
            mni{i}(3, 1:3) = [-4.420000e+01, -7.820000e+01, -0.760000e+01];  %  LO LEFT
            mni{i}(4, 1:3) = [-3.900000e+01, -6.260000e+01, -1.280000e+01];  % PFS LEFT
            mni{i}(5, 1:3) = [ 3.640000e+01, -8.340000e+01, -1.020000e+01];  %  LO RIGHT
            mni{i}(6, 1:3) = [ 3.640000e+01, -5.220000e+01, -1.280000e+01];  % PFS RIGHT

        case '006'
            mni{i}(1, 1:3) = [-4.680000e+01 -6.000000e+01 -1.280000e+01];  % VWFA FRE
            mni{i}(2, 1:3) = [-4.940000e+01 -6.260000e+01 -1.280000e+01];  % VWFA BRA
            mni{i}(3, 1:3) = [-5.200000e+01 -6.520000e+01 -0.020000e+01];  %  LO LEFT
            mni{i}(4, 1:3) = [-4.420000e+01 -6.000000e+01 -1.280000e+01];  % PFS LEFT
            mni{i}(5, 1:3) = [ 3.900000e+01 -6.780000e+01 -1.020000e+01];  %  LO RIGHT
            mni{i}(6, 1:3) = [ 3.640000e+01 -4.700000e+01 -2.320000e+01];  % PFS RIGHT

        case '007'
            mni{i}(1, 1:3) = [-5.200000e+01 -4.700000e+01 -1.800000e+01];  % VWFA FRE
            mni{i}(2, 1:3) = [-5.200000e+01 -4.960000e+01 -1.800000e+01];  % VWFA BRA
            mni{i}(3, 1:3) = [-4.420000e+01 -6.520000e+01 -1.280000e+01];  %  LO LEFT
            mni{i}(4, 1:3) = [-3.640000e+01 -4.700000e+01 -2.320000e+01];  % PFS LEFT
            mni{i}(5, 1:3) = [ 4.680000e+01 -7.820000e+01  0.020000e+01];  %  LO RIGHT
            mni{i}(6, 1:3) = [ 3.900000e+01 -5.220000e+01 -2.060000e+01];  % PFS RIGHT

        case '008'
            mni{i}(1, 1:3) = [-5.200000e+01 -4.740000e+01 -2.060000e+01];  % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];                                % VWFA BRA
            mni{i}(3, 1:3) = [-4.160000e+01 -7.820000e+01 -0.240000e+01];  %  LO LEFT
            mni{i}(4, 1:3) = [-3.640000e+01 -5.480000e+01 -2.060000e+01];  % PFS LEFT
            mni{i}(5, 1:3) = [ 4.420000e+01 -7.820000e+01 -0.760000e+01];  %  LO RIGHT
            mni{i}(6, 1:3) = [ 3.640000e+01 -4.960000e+01 -2.320000e+01];  % PFS RIGHT

        case '009'
            mni{i}(1, 1:3) = [-4.420000e+01 -6.260000e+01 -1.540000e+01];  % VWFA FRE
            mni{i}(2, 1:3) = [-4.160000e+01 -6.260000e+01 -1.020000e+01];  % VWFA BRA
            mni{i}(3, 1:3) = [-4.940000e+01 -7.820000e+01 -0.240000e+01];  %  LO LEFT
            mni{i}(4, 1:3) = [-4.680000e+01 -4.960000e+01 -1.800000e+01];  % PFS LEFT
            mni{i}(5, 1:3) = [ 3.640000e+01 -8.600000e+01 -0.500000e+01];  %  LO RIGHT
            mni{i}(6, 1:3) = [ 3.900000e+01 -5.740000e+01 -1.540000e+01];  % PFS RIGHT

    end
end

end