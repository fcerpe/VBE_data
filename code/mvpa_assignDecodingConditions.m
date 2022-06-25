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

        case 'french_v_braille'
            deco = {'french_v_braille'};
            condNb = [1 1 1 1 2 2 2 2];
            decoNbs = [1 2];

        case 'within_script'
            deco = {'frw_v_fpw', 'frw_v_fnw', 'frw_v_ffs', 'fpw_v_fnw', 'fpw_v_ffs', 'fnw_v_ffs', ...
                    'brw_v_bpw', 'brw_v_bnw', 'brw_v_bfs', 'bpw_v_bnw', 'bpw_v_bfs', 'bnw_v_bfs'};           
            condNb = [1 2 3 4 5 6 7 8];
            decoNbs = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4; 5 6; 5 7; 5 8; 6 7; 6 8; 7 8];

        case 'all'
            deco = {'frw_v_fpw', 'frw_v_fnw', 'frw_v_ffs', 'frw_v_brw', 'frw_v_bpw', 'frw_v_bnw', 'frw_v_bfs', ...
                    'fpw_v_fnw', 'fpw_v_ffs', 'fpw_v_brw', 'fpw_v_bpw', 'fpw_v_bnw', 'fpw_v_bfs', ...
                    'fnw_v_ffs', 'fnw_v_brw', 'fnw_v_bpw', 'fnw_v_bnw', 'fnw_v_bfs', ...
                    'ffs_v_brw', 'frw_v_bpw', 'frw_v_bnw', 'frw_v_bfs', ...
                    'brw_v_bpw', 'brw_v_bnw', 'brw_v_bfs', ...
                    'bpw_v_bnw', 'bpw_v_bfs', ...
                    'bnw_v_bfs'};
            condNb = [1 2 3 4 5 6 7 8];
            decoNbs = [1 2; 1 3; 1 4; 1 5; 1 6; 1 7; 1 8; 2 3; 2 4; 2 5; 2 6; 2 7; 2 8; ...
                       3 4; 3 5; 3 6; 3 7; 3 8; 4 5; 4 6; 4 7; 4 8; 5 6; 5 7; 5 8; 6 7; 6 8; 7 8];
    end
end