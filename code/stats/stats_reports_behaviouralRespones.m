
%% STATS - Extract behavioural responses for the decoding task

% Initialize report
% Start a new report
report = {'subject','trial_type','response_type','stim','run'};

for iSub = 1:numel(opt.subjects)

    subName = ['sub-' opt.subjects{iSub}];

    % fecth events
    eventsDir = dir(fullfile(opt.dir.raw, subName, 'ses-00*', 'func', [subName '_ses-00*_task-wordsDecoding_run-0*_events.tsv']));  

    % for each event, lookup 'target' and 'response' events to identify:
    % - correct responses
    % - false positives
    % - misses
    for iEvent = 1:numel(eventsDir)

        % load events.tsv file
        thisEvent = readtable(fullfile(eventsDir(iEvent).folder, eventsDir(iEvent).name), "FileType","text","Delimiter","\t");
        thisEvent.Properties.VariableNames = {'onset', 'duration', 'trial_type', 'stim', 'target', 'rest', 'does', 'not', 'matter'};

        for rowEv = 1:size(thisEvent,1)-1

            % because matlab tables are tricky to deal with, pre-extract
            % trial_type
            thisTrial = thisEvent{rowEv, 'trial_type'};

            % If it's a target, look what happens next
            if strcmp(thisTrial{1}, 'target')

                % if there's a response to the target
                nextTrial = thisEvent{rowEv+1, 'trial_type'};

                prevStim = thisEvent{rowEv-1, 'stim'};
                prevTrial = thisEvent{rowEv-1, 'trial_type'};
                if (startsWith(prevTrial,'res'))
                    prevStim = thisEvent{rowEv-2, 'stim'};
                    prevTrial = thisEvent{rowEv-2, 'trial_type'};
                end

                if strcmp(nextTrial{1}, 'response')

                    % congrats, it's correct
                    report = vertcat(report, ...
                            {subName, prevTrial{1}, 'correct', prevStim{1}, iEvent});
                else
                    % if there's no response, too bad it's a miss
                    report = vertcat(report, ...
                            {subName, prevTrial{1}, 'miss', prevStim{1}, iEvent});
                end

            % Also check for spontaneous responses
            % if there was not a target before, it's a false positive
            elseif strcmp(thisTrial{1}, 'response')
                
                % fetch what is there before
                % if target, ignore 
                % if response, ignore
                % if event, false positive
                prevTrial = thisEvent{rowEv-1, 'trial_type'};
                prevStim = thisEvent{rowEv-1, 'stim'};

                if ~strcmp(prevTrial{1}, 'target') && ~strcmp(prevTrial{1}, 'response')

                     % false positive
                     report = vertcat(report, ...
                            {subName, prevTrial{1}, 'false_positive', prevStim{1}, iEvent});
                end
            end
        end
    end
end

% save report
writecell(report,'reports/behaviouralReport.txt');














