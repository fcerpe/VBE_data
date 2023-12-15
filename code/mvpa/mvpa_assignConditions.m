function [conditionLabels, decodingName, conditionNumbers, decodingNumbers, modalityLabels, modalityNumbers, modalityList] = mvpa_assignConditions(opt)
    % assign the decoding conditions
    % a.k.a. create a cell array with the decoding based on the choice made
    % in mvpa_blockMvpa_otion
    %
    % INPUTS: 
    % * opt. Contains 
    %   - opt.decodingCondition
    %      > pairwise
    %      > multiclass
    %
    %   - opt.decodingModality:
    %      > within
    %      > cross
    %
    % OUTPUTS:
    % * deco: the decodingCondition names
    % * condNb: the number of each condition, based on the type of decoding
    
    % First look at the modality, if it's cross-script decoding, only
    % option is pairwise comparisons
    if strcmp(opt.decodingModality, 'cross')
        
            conditionNumbers = [1 2 3 4 1 2 3 4];
            conditionLabels = {'frw','fpw','fnw','ffs','brw','bpw','bnw','bfs'};
            modalityList = {'tr-braille_te-french', 'tr-french_te-braille', 'both'};
            modalityNumbers = [1 1 1 1 2 2 2 2];
            modalityLabels = {'french','french','french','french','braille','braille','braille','braille'};
            decodingNumbers = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];
            decodingName = {'rw_v_pw', 'rw_v_nw', 'rw_v_fs', 'pw_v_nw', 'pw_v_fs', 'nw_v_fs'};

    else
        % switch between pairwise and multiclass
        switch opt.decodingCondition

            case 'pairwise'
                decodingName = {'frw_v_fpw', 'frw_v_fnw', 'frw_v_ffs', 'fpw_v_fnw', 'fpw_v_ffs', 'fnw_v_ffs', ...
                    'brw_v_bpw', 'brw_v_bnw', 'brw_v_bfs', 'bpw_v_bnw', 'bpw_v_bfs', 'bnw_v_bfs'};
                conditionLabels = {'frw','fpw','fnw','ffs','brw','bpw','bnw','bfs'};
                conditionNumbers = [1 2 3 4 5 6 7 8];
                decodingNumbers = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4; 5 6; 5 7; 5 8; 6 7; 6 8; 7 8];

            case 'multiclass'
                decodingName = {'frw_v_fpw_v_fnw_v_ffs', 'brw_v_bpw_v_bnw_v_bfs'};
                conditionLabels = {'frw','fpw','fnw','ffs','brw','bpw','bnw','bfs'};
                conditionNumbers = [1 2 3 4 5 6 7 8];
                decodingNumbers = [1 2 3 4; 5 6 7 8];

            % little easter egg, we can try to decode every comparison
            % possible, regardless of script.
            % Pointless from a neruoscientific perspective, nice
            % computational exercise
            case 'all'
                decodingName = {'frw_v_fpw', 'frw_v_fnw', 'frw_v_ffs', 'frw_v_brw', 'frw_v_bpw', 'frw_v_bnw', 'frw_v_bfs', ...
                                'fpw_v_fnw', 'fpw_v_ffs', 'fpw_v_brw', 'fpw_v_bpw', 'fpw_v_bnw', 'fpw_v_bfs', ...
                                'fnw_v_ffs', 'fnw_v_brw', 'fnw_v_bpw', 'fnw_v_bnw', 'fnw_v_bfs', ...
                                'ffs_v_brw', 'frw_v_bpw', 'frw_v_bnw', 'frw_v_bfs', ...
                                'brw_v_bpw', 'brw_v_bnw', 'brw_v_bfs', ...
                                'bpw_v_bnw', 'bpw_v_bfs', ...
                                'bnw_v_bfs'};
                conditionLabels = {'frw','fpw','fnw','ffs','brw','bpw','bnw','bfs'};
                conditionNumbers = [1 2 3 4 5 6 7 8];
                decodingNumbers = [1 2; 1 3; 1 4; 1 5; 1 6; 1 7; 1 8; 2 3; 2 4; 2 5; 2 6; 2 7; 2 8; ...
                                   3 4; 3 5; 3 6; 3 7; 3 8; 4 5; 4 6; 4 7; 4 8; 5 6; 5 7; 5 8; 6 7; 6 8; 7 8];
        end
    end
end