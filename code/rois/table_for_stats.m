%% table_for_stats
%
% Create a table of the VWFA coords of each expert and constrast (FR/BR)
% to be imported into R for stats on the position of those peaks

% Get the coords
subjects = {'006','007','008','009','012','013','017'};
coords = roi_getMNIcoords(subjects);

% prepare the table
stats_table = table('Size',[14, 5],'VariableTypes',{'char','char','double','double','double'},...
    'VariableNames',{'ID','Area','X','Y','Z'});

% Sort them in a nice way
for i = 1:size(coords,1)
    thisSub = coords{i};

    % assign values to the corresponding cells, 
    % for both FR and BR defined VWFA
    % ID 
    stats_table.ID{i} = ['sub-', subjects{i}];
    stats_table.ID{i+7} = ['sub-', subjects{i}];
    % Area
    stats_table.Area{i} = 'VWFA FR';
    stats_table.Area{i+7} = 'VWFA BR';
    % Coords
    stats_table.X(i) = thisSub(1,1);   stats_table.Y(i) = thisSub(1,2);   stats_table.Z(i) = thisSub(1,3);
    stats_table.X(i+7) = thisSub(2,1); stats_table.Y(i+7) = thisSub(2,2); stats_table.Z(i+7) = thisSub(2,3);

end

writetable(stats_table, '../stats/experts_vwfa_coordinates.xlsx')