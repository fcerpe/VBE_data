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

% VWFA = -44 -56 -16, keyword: visual words
%    lLO  = -47 -70 -5
%    rLO  =  47 -70 -5, keyword: objects

% mni{sub_number}(contrast number, coordinates)
% e.g. mni{1}= [-46 64 4]
mni = cell(length(subs),1);

for i = 1:length(subs)

    switch subs{i}
        case '001' % SUB-001
            mni{i}(1, 1:3) = [-46.80000, -7.040000, -1.280000]; % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];                     % VWFA BRA
            mni{i}(3, 1:3) = [-4.680000, -6.780000,  0.020000]; %  LO LEFT
            mni{i}(4, 1:3) = [ 4.940000, -6.280000, -0.500000]; %  LO RIGHT

        case '002' % SUB-002
            mni{i}(1, 1:3) = [-4.940000, -57.40000, -12.80000]; % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];                     % VWFA BRA
            mni{i}(3, 1:3) = [-46.80000, -62.60000, -7.60000];  % LO LEFT
            mni{i}(4, 1:3) = [ 46.80000, -70.40000, -5.00000];  % LO RIGHT

        case '003' % SUB-003
            mni{i}(1, 1:3) = [-49.40000, -60.00000, -20.60000]; % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];                     % VWFA BRA
            mni{i}(3, 1:3) = [-39.00000, -73.00000, -2.40000];  % LO LEFT
            mni{i}(4, 1:3) = [ 44.20000, -80.80000, -5.00000];  % LO RIGHT

        case '004' % SUB-004
            mni{i}(1, 1:3) = [NaN NaN NaN];  % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];  % VWFA BRA
            mni{i}(3, 1:3) = [NaN NaN NaN];  % LO LEFT
            mni{i}(5, 1:3) = [NaN NaN NaN];  % LO RIGHT

        case '005' 
            mni{i}(1, 1:3) = [-65.00000, -41.80000,  5.40000];  % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];                     % VWFA BRA
            mni{i}(3, 1:3) = [-44.20000, -78.20000, -7.60000];  % LO LEFT
            mni{i}(4, 1:3) = [ 36.40000, -83.40000, -10.20000]; % LO RIGHT

        case '006'
            mni{i}(1, 1:3) = [-46.80000 -60.00000 -12.80000];  % VWFA FRE
            mni{i}(2, 1:3) = [-49.40000 -62.60000 -12.80000];  % VWFA BRA
            mni{i}(3, 1:3) = [-52.00000 -65.20000 -00.20000];  % LO LEFT
            mni{i}(4, 1:3) = [ 39.00000 -67.80000 -10.20000];  % LO RIGHT

        case '007'
            mni{i}(1, 1:3) = [-52.00000 -49.60000 -18.00000];  % VWFA FRE
            mni{i}(2, 1:3) = [-52.00000 -49.60000 -18.00000];  % VWFA BRA
            mni{i}(3, 1:3) = [-44.20000 -65.20000 -12.80000];  % LO LEFT
            mni{i}(4, 1:3) = [ 46.80000 -78.20000  00.20000];  % LO RIGHT

        case '008'
            mni{i}(1, 1:3) = [-52.00000 -54.80000 -18.00000];  % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];                    % VWFA BRA
            mni{i}(3, 1:3) = [-41.60000 -78.20000 -02.40000];  % LO LEFT
            mni{i}(4, 1:3) = [ 44.20000 -78.20000 -07.60000];  % LO RIGHT

        case '009'
            mni{i}(1, 1:3) = [-44.20000 -62.60000 -12.80000];  % VWFA FRE
            mni{i}(2, 1:3) = [-41.60000 -62.60000 -10.20000];  % VWFA BRA
            mni{i}(3, 1:3) = [-49.40000 -78.20000 -02.40000];  % LO LEFT
            mni{i}(4, 1:3) = [ 36.40000 -70.40000 -12.80000];  % LO RIGHT

        case '010' 
            mni{i}(1, 1:3) = [-44.20000 -62.60000 -12.80000];  % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];                    % VWFA BRA
            mni{i}(3, 1:3) = [-49.40000 -75.60000  00.20000];  % LO LEFT
            mni{i}(4, 1:3) = [ 49.40000 -65.20000 -05.00000];  % LO RIGHT

        case '011' 
            mni{i}(1, 1:3) = [-49.40000 -60.00000 -10.20000];  % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];                    % VWFA BRA
            mni{i}(3, 1:3) = [-39.00000 -73.00000 -10.20000];  % LO LEFT
            mni{i}(4, 1:3) = [ 44.20000 -65.20000 -10.20000];  % LO RIGHT

        case '012'
            mni{i}(1, 1:3) = [-44.20000 -60.00000 -15.40000];  % VWFA FRE
            mni{i}(2, 1:3) = [-44.20000 -57.40000 -18.00000];  % VWFA BRA
            mni{i}(3, 1:3) = [-49.40000 -75.60000 -05.00000];  % LO LEFT
            mni{i}(4, 1:3) = [ 49.40000 -73.00000 -10.20000];  % LO RIGHT

        case '013'
            mni{i}(1, 1:3) = [-44.20000 -60.00000 -12.80000];  % VWFA FRE
            mni{i}(2, 1:3) = [-46.80000 -62.60000 -15.40000];  % VWFA BRA
            mni{i}(3, 1:3) = [-49.40000 -78.20000 -02.40000];  % LO LEFT
            mni{i}(4, 1:3) = [ 49.40000 -67.80000 -12.80000];  % LO RIGHT

        case '015' 
            mni{i}(1, 1:3) = [NaN NaN NaN];  % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];  % VWFA BRA
            mni{i}(3, 1:3) = [NaN NaN NaN];  % LO LEFT
            mni{i}(4, 1:3) = [NaN NaN NaN];  % LO RIGHT

        case '017' 
            mni{i}(1, 1:3) = [-62.40000 -47.00000 -12.80000];  % VWFA FRE
            mni{i}(2, 1:3) = [-62.40000 -47.00000 -12.80000];  % VWFA BRA
            mni{i}(3, 1:3) = [-49.40000 -75.60000 -07.60000];  % LO LEFT
            mni{i}(4, 1:3) = [ 52.00000 -65.20000 -10.20000];  % LO RIGHT

        case '018' 
            mni{i}(1, 1:3) = [-46.80000 -54.80000 -07.60000];  % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];                    % VWFA BRA
            mni{i}(3, 1:3) = [-46.80000 -73.00000 -05.00000];  % LO LEFT
            mni{i}(4, 1:3) = [ 44.20000 -70.40000 -10.20000];  % LO RIGHT

        case '019' 
            mni{i}(1, 1:3) = [-46.80000 -47.00000 -20.60000];  % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];                    % VWFA BRA
            mni{i}(3, 1:3) = [-41.60000 -78.20000 -05.00000];  % LO LEFT
            mni{i}(4, 1:3) = [ 44.20000 -73.00000 -07.60000];  % LO RIGHT

        case '020' 
            mni{i}(1, 1:3) = [-44.20000 -57.4000 -20.60000];  % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];                    % VWFA BRA
            mni{i}(3, 1:3) = [-49.40000 -78.20000 -05.00000];  % LO LEFT
            mni{i}(4, 1:3) = [ 44.20000 -65.20000 -12.80000];  % LO RIGHT

        case '021' 
            mni{i}(1, 1:3) = [-46.80000 -49.60000 -23.20000];  % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];                    % VWFA BRA
            mni{i}(3, 1:3) = [-46.80000 -65.20000 -12.80000];  % LO LEFT
            mni{i}(4, 1:3) = [ 49.40000 -67.80000 -07.60000];  % LO RIGHT

        case '022' 
            mni{i}(1, 1:3) = [-47.70000 -64.90000 -18.00000];  % VWFA FRE
            mni{i}(2, 1:3) = [NaN NaN NaN];                    % VWFA BRA
            mni{i}(3, 1:3) = [-42.50000 -75.30000 -10.20000];  % LO LEFT
            mni{i}(4, 1:3) = [ 49.20000 -67.50000 -10.20000];  % LO RIGHT

    end
end

end