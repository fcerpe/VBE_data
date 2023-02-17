function [deco, condNb, decoNbs] = mvpa_assignDecodingConditions(opt)
    % assign the decoding conditions
    % a.k.a. create a cell array with the decoding based on the choice made
    % in mvpa_blockMvpa_otion
    %
    % INPUTS: 
    % * opt, contains opt.decodingCondition, which can be:
    %   french_v_braille: simple investigation of FR and BR, high decodings
    %                     ahead
    %
    %   within script: compares each condition against all the others of the
    %                  same script
    %
    %   all: compares each condition against all the others, regardless the
    %        script. Probably useless
    %
    % OUTPUTS:
    % * deco: the decodingCondition names
    % * condNb: the number of each condition, based on the type of decoding
    
    switch opt.decodingCondition{1}

        case 'all'
            deco = {
                'fBA_v_fVA','fBA_v_fCO','fBA_v_fFA','fBA_v_fCH','fBA_v_fSO','fBA_v_fPO','fBA_v_fRO','fBA_v_bBA','fBA_v_bVA','fBA_v_bCO','fBA_v_bFA','fBA_v_bCH','fBA_v_bSO','fBA_v_bPO','fBA_v_bRO',...
                'fVA_v_fCO','fVA_v_fFA','fVA_v_fCH','fVA_v_fSO','fVA_v_fPO','fVA_v_fRO','fVA_v_bBA','fVA_v_bVA','fVA_v_bCO','fVA_v_bFA','fVA_v_bCH','fVA_v_bSO','fVA_v_bPO','fVA_v_bRO',...
                'fCO_v_fFA','fCO_v_fCH','fCO_v_fSO','fCO_v_fPO','fCO_v_fRO','fCO_v_bBA','fCO_v_bVA','fCO_v_bCO','fCO_v_bFA','fCO_v_bCH','fCO_v_bSO','fCO_v_bPO','fCO_v_bRO',...
                'fFA_v_fCH','fFA_v_fSO','fFA_v_fPO','fFA_v_fRO','fFA_v_bBA','fFA_v_bVA','fFA_v_bCO','fFA_v_bFA','fFA_v_bCH','fFA_v_bSO','fFA_v_bPO','fFA_v_bRO',...
                'fCH_v_fSO','fCH_v_fPO','fCH_v_fRO','fCH_v_bBA','fCH_v_bVA','fCH_v_bCO','fCH_v_bFA','fCH_v_bCH','fCH_v_bSO','fCH_v_bPO','fCH_v_bRO',...
                'fSO_v_fPO','fSO_v_fRO','fSO_v_bBA','fSO_v_bVA','fSO_v_bCO','fSO_v_bFA','fSO_v_bCH','fSO_v_bSO','fSO_v_bPO','fSO_v_bRO',...
                'fPO_v_fRO','fPO_v_bBA','fPO_v_bVA','fPO_v_bCO','fPO_v_bFA','fPO_v_bCH','fPO_v_bSO','fPO_v_bPO','fPO_v_bRO',...
                'fRO_v_bBA','fRO_v_bVA','fRO_v_bCO','fRO_v_bFA','fRO_v_bCH','fRO_v_bSO','fRO_v_bPO','fRO_v_bRO',...
                'bBA_v_bVA','bBA_v_bCO','bBA_v_bFA','bBA_v_bCH','bBA_v_bSO','bBA_v_bPO','bBA_v_bRO',...
                'bVA_v_bCO','bVA_v_bFA','bVA_v_bCH','bVA_v_bSO','bVA_v_bPO','bVA_v_bRO',...
                'bCO_v_bFA','bCO_v_bCH','bCO_v_bSO','bCO_v_bPO','bCO_v_bRO',...
                'bFA_v_bCH','bFA_v_bSO','bFA_v_bPO','bFA_v_bRO',...
                'bCH_v_bSO','bCH_v_bPO','bCH_v_bRO',...
                'bSO_v_bPO','bSO_v_bRO',...
                'bPO_v_bRO',...
                    };
            condNb = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16];
            decoNbs = [1 2;   1 3;    1 4;  1 5;   1 6;   1 7;   1 8;  1 9;  1 10; 1 11; 1 12; 1 13; 1 14; 1 15; 1 16; ...
                       2 3;   2 4;    2 5;  2 6;   2 7;   2 8;   2 9;  2 10; 2 11; 2 12; 2 13; 2 14; 2 15; 2 16;...
                       3 4;   3 5;    3 6;  3 7;   3 8;   3 9;   3 10; 3 11; 3 12; 3 13; 3 14; 3 15; 3 16;...
                       4 5;   4 6;    4 7;  4 8;   4 9;   4 10;  4 11; 4 12; 4 13; 4 14; 4 15; 4 16;...
                       5 6;   5 7;    5 8;  5 9;   5 10;  5 11;  5 12; 5 13; 5 14; 5 15; 5 16;...
                       6 7;   6 8;    6 9;  6 10;  6 11;  6 12;  6 13; 6 14; 6 15; 6 16;...
                       7 8;   7 9;    7 10; 7 11;  7 12;  7 13;  7 14; 7 15; 7 16;...
                       8 9;   8 10;   8 11; 8 12;  8 13;  8 14;  8 15; 8 16; ...
                       9 10;  9 11;   9 12; 9 13;  9 14;  9 15;  9 16; ...
                       10 11; 10 12; 10 13; 10 14; 10 15; 10 16; ...
                       11 12; 11 13; 11 14; 11 15; 11 16; ...
                       12 13; 12 14; 12 15; 12 16; ...
                       13 14; 13 15; 13 16; ...
                       14 15; 14 16; ...
                       15 16; ...
                       ];
    end
end




